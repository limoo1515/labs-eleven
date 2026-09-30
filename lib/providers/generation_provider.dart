import 'package:flutter/foundation.dart';
import '../models/generation.dart';
import '../models/tts_settings.dart';
import '../models/voice.dart';
import '../services/eleven_labs_service.dart';
import '../services/storage_service.dart';

/// Provider for TTS generation management.
class GenerationProvider extends ChangeNotifier {
  final ElevenLabsService _elevenLabsService;
  final StorageService _storageService;

  List<Generation> _history = [];
  bool _isGenerating = false;
  double _generationProgress = 0.0;
  String? _error;
  String? _selectedVoiceId;
  String? _selectedModelId;
  TTSSettings _settings = TTSSettings.defaults;
  String? _lastGeneratedAudioPath;

  GenerationProvider({
    required ElevenLabsService elevenLabsService,
    required StorageService storageService,
  })  : _elevenLabsService = elevenLabsService,
        _storageService = storageService;

  // Getters
  List<Generation> get history => _history;
  bool get isGenerating => _isGenerating;
  double get generationProgress => _generationProgress;
  String? get error => _error;
  String? get selectedVoiceId => _selectedVoiceId;
  String? get selectedModelId => _selectedModelId;
  TTSSettings get settings => _settings;
  String? get lastGeneratedAudioPath => _lastGeneratedAudioPath;

  /// Initialize provider with saved data.
  Future<void> init() async {
    _history = await _storageService.getHistory();
    _selectedModelId = await _storageService.getSelectedModel();
    notifyListeners();
  }

  /// Set the selected voice.
  void selectVoice(String voiceId) {
    _selectedVoiceId = voiceId;
    _error = null;
    notifyListeners();
  }

  /// Set the selected model.
  Future<void> selectModel(String modelId) async {
    _selectedModelId = modelId;
    await _storageService.saveSelectedModel(modelId);
    notifyListeners();
  }

  /// Update TTS settings.
  void updateSettings(TTSSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  /// Generate TTS audio.
  Future<String?> generateTTS({
    required String text,
    required Voice voice,
  }) async {
    if (text.trim().isEmpty) {
      _error = 'Le texte est vide. Écrivez du texte pour générer la voix.';
      notifyListeners();
      return null;
    }

    if (text.length > 5000) {
      _error = 'Le texte est trop long (max 5000 caractères).';
      notifyListeners();
      return null;
    }

    _isGenerating = true;
    _generationProgress = 0.0;
    _error = null;
    _lastGeneratedAudioPath = null;
    notifyListeners();

    try {
      final audioPath = await _elevenLabsService.generateTTS(
        text: text,
        voiceId: voice.id,
        modelId: _selectedModelId,
        settings: _settings,
        onProgress: (progress) {
          _generationProgress = progress;
          notifyListeners();
        },
      );

      _lastGeneratedAudioPath = audioPath;

      // Save to history
      final generation = Generation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        voiceId: voice.id,
        voiceName: voice.name,
        createdAt: DateTime.now(),
        audioFilePath: audioPath,
        modelId: _selectedModelId,
      );

      await _storageService.addToHistory(generation);
      _history = await _storageService.getHistory();

      return audioPath;
    } on ElevenLabsException catch (e) {
      _error = e.userMessage ?? e.message;
      return null;
    } catch (e) {
      _error = 'Impossible de générer l\'audio. Vérifiez votre connexion ou votre configuration ElevenLabs.';
      return null;
    } finally {
      _isGenerating = false;
      _generationProgress = 0.0;
      notifyListeners();
    }
  }

  /// Delete a generation from history.
  Future<void> deleteGeneration(String generationId) async {
    final generation = _history.firstWhere(
      (g) => g.id == generationId,
      orElse: () => throw Exception('Generation not found'),
    );

    // Delete audio file if exists
    if (generation.audioFilePath != null) {
      await _storageService.deleteAudioFile(generation.audioFilePath!);
    }

    await _storageService.removeFromHistory(generationId);
    _history = await _storageService.getHistory();
    notifyListeners();
  }

  /// Clear all history.
  Future<void> clearHistory() async {
    await _storageService.clearHistory();
    _history = [];
    notifyListeners();
  }

  /// Clear error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
