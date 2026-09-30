import 'package:flutter_test/flutter_test.dart';
import 'package:eleven_studio/utils/text_validator.dart';

void main() {
  group('TextValidator', () {
    group('validate', () {
      test('returns error for null text', () {
        expect(TextValidator.validate(null), isNotNull);
      });

      test('returns error for empty text', () {
        expect(TextValidator.validate(''), isNotNull);
        expect(TextValidator.validate('   '), isNotNull);
      });

      test('returns null for valid text', () {
        expect(TextValidator.validate('Hello world'), isNull);
        expect(TextValidator.validate('السلام عليكم'), isNull);
      });

      test('returns error for text exceeding max length', () {
        final longText = 'a' * 5001;
        expect(TextValidator.validate(longText), isNotNull);
      });

      test('returns null for text at max length', () {
        final maxText = 'a' * 5000;
        expect(TextValidator.validate(maxText), isNull);
      });
    });

    group('containsArabic', () {
      test('detects Arabic characters', () {
        expect(TextValidator.containsArabic('السلام عليكم'), isTrue);
        expect(TextValidator.containsArabic('مرحبا'), isTrue);
      });

      test('returns false for non-Arabic text', () {
        expect(TextValidator.containsArabic('Hello world'), isFalse);
        expect(TextValidator.containsArabic('Bonjour'), isFalse);
      });

      test('detects Arabic in mixed text', () {
        expect(TextValidator.containsArabic('Hello مرحبا'), isTrue);
      });
    });

    group('containsLatin', () {
      test('detects Latin characters', () {
        expect(TextValidator.containsLatin('Hello'), isTrue);
        expect(TextValidator.containsLatin('Bonjour'), isTrue);
      });

      test('returns false for non-Latin text', () {
        expect(TextValidator.containsLatin('السلام عليكم'), isFalse);
      });
    });

    group('detectDirection', () {
      test('detects RTL for Arabic text', () {
        expect(TextValidator.detectDirection('السلام عليكم'), 'rtl');
      });

      test('detects LTR for French text', () {
        expect(TextValidator.detectDirection('Bonjour le monde'), 'ltr');
      });

      test('detects LTR for English text', () {
        expect(TextValidator.detectDirection('Hello world'), 'ltr');
      });

      test('detects RTL for mixed Arabic/French text starting with Arabic', () {
        expect(TextValidator.detectDirection('السلام عليكم Aujourd\'hui'), 'rtl');
      });

      test('detects LTR for mixed French/Arabic text starting with French', () {
        expect(TextValidator.detectDirection('Aujourd\'hui السلام عليكم'), 'ltr');
      });

      test('returns LTR for empty text', () {
        expect(TextValidator.detectDirection(''), 'ltr');
      });
    });

    group('getCharacterCount', () {
      test('counts characters excluding whitespace', () {
        expect(TextValidator.getCharacterCount('Hello world'), 10);
        expect(TextValidator.getCharacterCount('  '), 0);
      });
    });

    group('getWordCount', () {
      test('counts words correctly', () {
        expect(TextValidator.getWordCount('Hello world'), 2);
        expect(TextValidator.getWordCount(''), 0);
        expect(TextValidator.getWordCount('   '), 0);
      });
    });

    group('estimateReadingTime', () {
      test('estimates reading time', () {
        // 150 words per minute
        final text150 = List.generate(150, (i) => 'word').join(' ');
        expect(TextValidator.estimateReadingTime(text150), 60);
      });
    });
  });
}
