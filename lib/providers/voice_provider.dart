import 'package:flutter/foundation.dart';
import '../models/voice.dart';
import '../services/eleven_labs_service.dart';
import '../services/storage_service.dart';

/// Provider for voice management.
class VoiceProvider extends ChangeNotifier {
  final ElevenLabsService _elevenLabsService;
  final StorageService _storageService;

  List<Voice> _voices = [];
  List<Voice> _filteredVoices = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedLanguage;
  String? _selectedGender;
  String? _selectedUseCase;
  bool _showFavoritesOnly = false;

  VoiceProvider({
    required ElevenLabsService elevenLabsService,
    required StorageService storageService,
  })  : _elevenLabsService = elevenLabsService,
        _storageService = storageService;

  // Getters
  List<Voice> get voices => _filteredVoices;
  List<Voice> get allVoices => _voices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedLanguage => _selectedLanguage;
  String? get selectedGender => _selectedGender;
  String? get selectedUseCase => _selectedUseCase;
  bool get showFavoritesOnly => _showFavoritesOnly;
  Set<String> get favoriteIds => _favoriteIds;

  /// Get available languages from voices.
  List<String> get availableLanguages {
    final languages = _voices
        .where((v) => v.language != null)
        .map((v) => v.language!)
        .toSet()
        .toList();
    languages.sort();
    return languages;
  }

  /// Get available genders from voices.
  List<String> get availableGenders {
    final genders = _voices
        .where((v) => v.gender != null)
        .map((v) => v.gender!)
        .toSet()
        .toList();
    genders.sort();
    return genders;
  }

  /// Get available use cases from voices.
  List<String> get availableUseCases {
    final useCases = _voices
        .where((v) => v.useCase != null)
        .map((v) => v.useCase!)
        .toSet()
        .toList();
    useCases.sort();
    return useCases;
  }

  /// Load voices from API and favorites from storage.
  Future<void> loadVoices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _voices = await _elevenLabsService.getVoices();
      _favoriteIds = await _storageService.getFavoriteVoiceIds();
      _applyFilters();
    } on ElevenLabsException catch (e) {
      _error = e.userMessage ?? e.message;
    } catch (e) {
      _error = 'Impossible de charger les voix. Réessayez plus tard.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh voices from API.
  Future<void> refreshVoices() async {
    await loadVoices();
  }

  /// Search voices by name.
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Filter by language.
  void filterByLanguage(String? language) {
    _selectedLanguage = language;
    _applyFilters();
  }

  /// Filter by gender.
  void filterByGender(String? gender) {
    _selectedGender = gender;
    _applyFilters();
  }

  /// Filter by use case.
  void filterByUseCase(String? useCase) {
    _selectedUseCase = useCase;
    _applyFilters();
  }

  /// Toggle favorites only view.
  void toggleFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    _applyFilters();
  }

  /// Clear all filters.
  void clearFilters() {
    _searchQuery = '';
    _selectedLanguage = null;
    _selectedGender = null;
    _selectedUseCase = null;
    _showFavoritesOnly = false;
    _applyFilters();
  }

  /// Toggle favorite status for a voice.
  Future<void> toggleFavorite(String voiceId) async {
    final isNowFavorite = await _storageService.toggleFavorite(voiceId);
    if (isNowFavorite) {
      _favoriteIds.add(voiceId);
    } else {
      _favoriteIds.remove(voiceId);
    }
    _applyFilters();
  }

  /// Check if a voice is favorited.
  bool isFavorite(String voiceId) => _favoriteIds.contains(voiceId);

  /// Apply all active filters.
  void _applyFilters() {
    _filteredVoices = _voices.where((voice) {
      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!voice.name.toLowerCase().contains(query) &&
            !(voice.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Language filter
      if (_selectedLanguage != null && voice.language != _selectedLanguage) {
        return false;
      }

      // Gender filter
      if (_selectedGender != null && voice.gender != _selectedGender) {
        return false;
      }

      // Use case filter
      if (_selectedUseCase != null && voice.useCase != _selectedUseCase) {
        return false;
      }

      // Favorites only
      if (_showFavoritesOnly && !_favoriteIds.contains(voice.id)) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }
}
