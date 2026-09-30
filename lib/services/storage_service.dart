import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/generation.dart';

/// Service for local data persistence.
/// 
/// Handles:
/// - Generation history (JSON file)
/// - Favorite voices (SharedPreferences)
/// - TTS settings (SharedPreferences)
class StorageService {
  static const String _historyKey = 'generation_history';
  static const String _favoritesKey = 'favorite_voices';
  static const String _modelKey = 'selected_model';
  static const int _maxHistoryItems = 100;

  SharedPreferences? _prefs;

  /// Initialize the storage service.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get the app's documents directory.
  Future<Directory> get _documentsDir async {
    final dir = await getApplicationDocumentsDirectory();
    final historyDir = Directory('${dir.path}/eleven_studio');
    if (!await historyDir.exists()) {
      await historyDir.create(recursive: true);
    }
    return historyDir;
  }

  // ==================== HISTORY ====================

  /// Get all generations from history.
  Future<List<Generation>> getHistory() async {
    final dir = await _documentsDir;
    final file = File('${dir.path}/$_historyKey.json');
    
    if (!await file.exists()) return [];
    
    try {
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList
          .map((j) => Generation.fromJson(j as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  /// Add a generation to history.
  Future<void> addToHistory(Generation generation) async {
    final history = await getHistory();
    history.insert(0, generation);
    
    // Keep only the most recent items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    await _saveHistory(history);
  }

  /// Remove a generation from history.
  Future<void> removeFromHistory(String generationId) async {
    final history = await getHistory();
    history.removeWhere((g) => g.id == generationId);
    await _saveHistory(history);
  }

  /// Clear all history.
  Future<void> clearHistory() async {
    final dir = await _documentsDir;
    final file = File('${dir.path}/$_historyKey.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _saveHistory(List<Generation> history) async {
    final dir = await _documentsDir;
    final file = File('${dir.path}/$_historyKey.json');
    final jsonList = history.map((g) => g.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  // ==================== FAVORITES ====================

  /// Get favorite voice IDs.
  Future<Set<String>> getFavoriteVoiceIds() async {
    _prefs ??= await SharedPreferences.getInstance();
    final List<String> favorites = _prefs!.getStringList(_favoritesKey) ?? [];
    return favorites.toSet();
  }

  /// Toggle favorite status for a voice.
  Future<bool> toggleFavorite(String voiceId) async {
    _prefs ??= await SharedPreferences.getInstance();
    final favorites = await getFavoriteVoiceIds();
    
    if (favorites.contains(voiceId)) {
      favorites.remove(voiceId);
    } else {
      favorites.add(voiceId);
    }
    
    await _prefs!.setStringList(_favoritesKey, favorites.toList());
    return favorites.contains(voiceId);
  }

  /// Check if a voice is favorited.
  Future<bool> isFavorite(String voiceId) async {
    final favorites = await getFavoriteVoiceIds();
    return favorites.contains(voiceId);
  }

  // ==================== SETTINGS ====================

  /// Get the selected model ID.
  Future<String?> getSelectedModel() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(_modelKey);
  }

  /// Save the selected model ID.
  Future<void> saveSelectedModel(String modelId) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_modelKey, modelId);
  }

  // ==================== AUDIO FILES ====================

  /// Get the audio files directory.
  Future<Directory> getAudioDirectory() async {
    final dir = await _documentsDir;
    final audioDir = Directory('${dir.path}/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  /// Save an audio file permanently.
  Future<String> saveAudioFile(String tempFilePath, String generationId) async {
    final audioDir = await getAudioDirectory();
    final ext = tempFilePath.split('.').last;
    final destPath = '${audioDir.path}/$generationId.$ext';
    final sourceFile = File(tempFilePath);
    await sourceFile.copy(destPath);
    return destPath;
  }

  /// Delete an audio file.
  Future<void> deleteAudioFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get total size of stored audio files.
  Future<int> getAudioStorageSize() async {
    final audioDir = await getAudioDirectory();
    if (!await audioDir.exists()) return 0;
    
    int totalSize = 0;
    await for (final entity in audioDir.list()) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }
}
