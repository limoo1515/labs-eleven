import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../config/app_config.dart';
import '../models/voice.dart';
import '../models/tts_settings.dart';

/// Custom exception for ElevenLabs API errors.
class ElevenLabsException implements Exception {
  final String message;
  final int? statusCode;
  final String? userMessage;

  const ElevenLabsException(this.message, {this.statusCode, this.userMessage});

  @override
  String toString() => message;
}

/// Service for interacting with the ElevenLabs API.
/// 
/// Responsibilities:
/// - Fetch available voices
/// - Generate TTS audio
/// - Handle API errors with user-friendly messages
/// - Manage audio responses
class ElevenLabsService {
  final http.Client _client;
  final String _baseUrl;
  final String? _apiKey;

  ElevenLabsService({
    http.Client? client,
    String? baseUrl,
    String? apiKey,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.elevenLabsBaseUrl,
        _apiKey = apiKey ?? ApiKeys.elevenLabsApiKey;

  /// Check if the service is properly configured.
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  /// Get headers for API requests.
  Map<String, String> get _headers => {
    'xi-api-key': _apiKey!,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Fetch all available voices from ElevenLabs.
  Future<List<Voice>> getVoices() async {
    _ensureConfigured();
    
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/voices'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final voicesList = data['voices'] as List<dynamic>? ?? [];
        return voicesList
            .map((v) => Voice.fromJson(v as Map<String, dynamic>))
            .toList();
      } else {
        _handleErrorResponse(response);
      }
    } on SocketException {
      throw const ElevenLabsException(
        'Network error',
        userMessage: 'Impossible de se connecter à ElevenLabs. Vérifiez votre connexion Internet.',
      );
    } on ElevenLabsException {
      rethrow;
    } catch (e) {
      throw ElevenLabsException(
        'Failed to fetch voices: $e',
        userMessage: 'Impossible de récupérer les voix. Réessayez plus tard.',
      );
    }
  }

  /// Generate TTS audio from text.
  /// 
  /// Returns the audio file path where the result is saved.
  Future<String> generateTTS({
    required String text,
    required String voiceId,
    String? modelId,
    TTSSettings? settings,
    void Function(double progress)? onProgress,
  }) async {
    _ensureConfigured();
    
    final effectiveModelId = modelId ?? AppConfig.defaultModelId;
    final effectiveSettings = settings ?? TTSSettings.defaults;

    try {
      onProgress?.call(0.1);

      final requestBody = jsonEncode({
        'text': text,
        'model_id': effectiveModelId,
        'voice_settings': effectiveSettings.toJson(),
      });

      onProgress?.call(0.2);

      final response = await _client.post(
        Uri.parse('$_baseUrl/text-to-speech/$voiceId'),
        headers: {
          ..._headers,
          'Accept': 'audio/mpeg',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 120));

      onProgress?.call(0.8);

      if (response.statusCode == 200) {
        // Save audio to temporary file
        final tempDir = await Directory.systemTemp.createTemp('eleven_studio_');
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${tempDir.path}/tts_$timestamp.mp3';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        onProgress?.call(1.0);
        return filePath;
      } else {
        _handleErrorResponse(response);
      }
    } on SocketException {
      throw const ElevenLabsException(
        'Network error',
        userMessage: 'Impossible de se connecter à ElevenLabs. Vérifiez votre connexion Internet.',
      );
    } on ElevenLabsException {
      rethrow;
    } catch (e) {
      throw ElevenLabsException(
        'TTS generation failed: $e',
        userMessage: 'Impossible de générer l\'audio. Vérifiez votre connexion ou votre configuration ElevenLabs.',
      );
    }
  }

  /// Get voice details by ID.
  Future<Voice?> getVoiceById(String voiceId) async {
    _ensureConfigured();
    
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/voices/$voiceId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Voice.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        _handleErrorResponse(response);
      }
      // Unreachable: _handleErrorResponse always throws
    } on ElevenLabsException {
      rethrow;
    } catch (e) {
      throw ElevenLabsException(
        'Failed to get voice: $e',
        userMessage: 'Impossible de récupérer les détails de la voix.',
      );
    }
  }

  /// Ensure API key is configured.
  void _ensureConfigured() {
    if (!isConfigured) {
      throw const ElevenLabsException(
        'API key not configured',
        userMessage: 'Clé API ElevenLabs manquante. Configurez votre clé dans les paramètres.',
      );
    }
  }

  /// Handle error responses with user-friendly messages.
  Never _handleErrorResponse(http.Response response) {
    final statusCode = response.statusCode;
    String userMessage;

    switch (statusCode) {
      case 401:
        userMessage = 'Clé API invalide. Vérifiez votre configuration ElevenLabs.';
        break;
      case 402:
        userMessage = 'Quota dépassé. Vérifiez votre abonnement ElevenLabs.';
        break;
      case 404:
        userMessage = 'Voix ou modèle introuvable.';
        break;
      case 422:
        userMessage = 'Paramètres invalides. Vérifiez votre texte et vos paramètres.';
        break;
      case 429:
        userMessage = 'Trop de requêtes. Attendez un moment avant de réessayer.';
        break;
      case 500:
      case 502:
      case 503:
        userMessage = 'Serveur ElevenLabs indisponible. Réessayez plus tard.';
        break;
      default:
        userMessage = 'Erreur inattendue ($statusCode). Réessayez plus tard.';
    }

    throw ElevenLabsException(
      'API error $statusCode: ${response.body}',
      statusCode: statusCode,
      userMessage: userMessage,
    );
  }

  /// Dispose resources.
  void dispose() {
    _client.close();
  }
}
