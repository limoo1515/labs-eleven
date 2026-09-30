import '../config/app_config.dart';

/// Utility class for text validation.
class TextValidator {
  TextValidator._();

  /// Validate text for TTS generation.
  /// Returns null if valid, error message otherwise.
  static String? validate(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Le texte est vide. Écrivez du texte pour générer la voix.';
    }

    if (text.length < AppConfig.minTextLength) {
      return 'Le texte est trop court.';
    }

    if (text.length > AppConfig.maxTextLength) {
      return 'Le texte est trop long (${text.length}/${AppConfig.maxTextLength} caractères).';
    }

    return null;
  }

  /// Check if text contains Arabic characters.
  static bool containsArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    return arabicRegex.hasMatch(text);
  }

  /// Check if text contains French/Latin characters.
  static bool containsLatin(String text) {
    final latinRegex = RegExp(r'[a-zA-ZÀ-ÿ]');
    return latinRegex.hasMatch(text);
  }

  /// Check if text contains digits.
  static bool containsDigits(String text) {
    return RegExp(r'\d').hasMatch(text);
  }

  /// Get the appropriate text direction based on content.
  static String detectDirection(String text) {
    if (text.isEmpty) return 'ltr';
    
    // Check first significant character
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (char.trim().isEmpty) continue;
      
      final codeUnit = char.codeUnitAt(0);
      // Arabic character ranges
      if ((codeUnit >= 0x0600 && codeUnit <= 0x06FF) ||
          (codeUnit >= 0x0750 && codeUnit <= 0x077F) ||
          (codeUnit >= 0x08A0 && codeUnit <= 0x08FF) ||
          (codeUnit >= 0xFB50 && codeUnit <= 0xFDFF) ||
          (codeUnit >= 0xFE70 && codeUnit <= 0xFEFF)) {
        return 'rtl';
      }
      // Latin character
      if ((codeUnit >= 0x0041 && codeUnit <= 0x005A) ||
          (codeUnit >= 0x0061 && codeUnit <= 0x007A) ||
          (codeUnit >= 0x00C0 && codeUnit <= 0x00FF)) {
        return 'ltr';
      }
      break;
    }
    
    return 'ltr';
  }

  /// Get character count (excluding whitespace).
  static int getCharacterCount(String text) {
    return text.replaceAll(RegExp(r'\s'), '').length;
  }

  /// Get word count.
  static int getWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  /// Estimate reading time in seconds.
  static int estimateReadingTime(String text) {
    final words = getWordCount(text);
    // Average reading speed: 150 words per minute
    return (words / 150 * 60).ceil();
  }
}
