import 'package:flutter_test/flutter_test.dart';
import 'package:eleven_studio/models/voice.dart';

void main() {
  group('Voice Model', () {
    test('creates Voice from JSON correctly', () {
      final json = {
        'voice_id': 'voice123',
        'name': 'Test Voice',
        'description': 'A test voice',
        'preview_url': 'https://example.com/preview.mp3',
        'labels': {
          'language': 'Arabic',
          'accent': 'Algerian',
          'gender': 'female',
          'age': 'young',
          'use_case': 'narration',
        },
      };

      final voice = Voice.fromJson(json);

      expect(voice.id, 'voice123');
      expect(voice.name, 'Test Voice');
      expect(voice.description, 'A test voice');
      expect(voice.previewUrl, 'https://example.com/preview.mp3');
      expect(voice.language, 'Arabic');
      expect(voice.accent, 'Algerian');
      expect(voice.gender, 'female');
      expect(voice.age, 'young');
      expect(voice.useCase, 'narration');
    });

    test('handles missing optional fields', () {
      final json = {
        'voice_id': 'voice456',
        'name': 'Minimal Voice',
      };

      final voice = Voice.fromJson(json);

      expect(voice.id, 'voice456');
      expect(voice.name, 'Minimal Voice');
      expect(voice.description, isNull);
      expect(voice.language, isNull);
      expect(voice.gender, isNull);
    });

    test('copyWith works correctly', () {
      final voice = const Voice(
        id: 'voice1',
        name: 'Original',
        language: 'Arabic',
      );

      final updated = voice.copyWith(name: 'Updated', isFavorite: true);

      expect(updated.id, 'voice1');
      expect(updated.name, 'Updated');
      expect(updated.language, 'Arabic');
      expect(updated.isFavorite, isTrue);
    });

    test('equality is based on id', () {
      const voice1 = Voice(id: 'same', name: 'Voice 1');
      const voice2 = Voice(id: 'same', name: 'Voice 2');
      const voice3 = Voice(id: 'different', name: 'Voice 1');

      expect(voice1, voice2);
      expect(voice1, isNot(voice3));
    });

    test('toJson works correctly', () {
      const voice = Voice(
        id: 'voice1',
        name: 'Test Voice',
        description: 'Description',
        language: 'Arabic',
      );

      final json = voice.toJson();

      expect(json['voice_id'], 'voice1');
      expect(json['name'], 'Test Voice');
      expect(json['description'], 'Description');
    });
  });
}
