import 'dart:io';

/// Secure API key management.
/// 
/// Priority order:
/// 1. Environment variable (ELEVENLABS_API_KEY)
/// 2. .env file in project root (development only)
/// 
/// NEVER commit real API keys to version control.
class ApiKeys {
  ApiKeys._();

  static String? _cachedKey;

  /// Get the ElevenLabs API key from environment or .env file.
  static String? get elevenLabsApiKey {
    if (_cachedKey != null) return _cachedKey;
    
    // Try environment variable first
    final envKey = Platform.environment['ELEVENLABS_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      _cachedKey = envKey;
      return _cachedKey;
    }
    
    // Try .env file (development only)
    try {
      final envFile = File('.env');
      if (envFile.existsSync()) {
        final lines = envFile.readAsLinesSync();
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('ELEVENLABS_API_KEY=')) {
            final key = trimmed.substring('ELEVENLABS_API_KEY='.length).trim();
            if (key.isNotEmpty) {
              _cachedKey = key;
              return _cachedKey;
            }
          }
        }
      }
    } catch (_) {
      // Ignore errors reading .env
    }
    
    return null;
  }

  /// Check if API key is configured.
  static bool get hasApiKey => elevenLabsApiKey != null;

  /// Clear cached key (useful for testing).
  static void clearCache() => _cachedKey = null;
}
