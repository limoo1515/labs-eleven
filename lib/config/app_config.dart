/// Application configuration for Eleven Studio.
/// 
/// API keys should NEVER be hardcoded in the repository.
/// For local development, create a `.env` file in the project root
/// (already added to .gitignore) with:
///   ELEVENLABS_API_KEY=your_api_key_here
/// 
/// For production, use a backend proxy to avoid exposing the API key.
class AppConfig {
  AppConfig._();

  static const String appName = 'Eleven Studio';
  static const String appSubtitle = 'Text → Voice';
  
  // ElevenLabs API
  static const String elevenLabsBaseUrl = 'https://api.elevenlabs.io/v1';
  static const String defaultModelId = 'eleven_turbo_v2_5';
  
  // Available models (documented, not hardcoded voice IDs)
  static const List<String> availableModels = [
    'eleven_turbo_v2_5',
    'eleven_flash_v2_5',
    'eleven_multilingual_v2',
  ];
  
  // Text limits
  static const int maxTextLength = 5000;
  static const int minTextLength = 1;
  
  // Audio
  static const int audioSampleRate = 44100;
  
  // Default voice (Sarah - works with free plan)
  static const String defaultVoiceId = 'EXAVITQu4vr4xnSDxMaL';
  
  // UI
  static const double defaultPadding = 16.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 14.0;
}
