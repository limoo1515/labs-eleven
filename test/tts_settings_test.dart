import 'package:flutter_test/flutter_test.dart';
import 'package:eleven_studio/models/tts_settings.dart';

void main() {
  group('TTSSettings', () {
    test('has correct default values', () {
      const settings = TTSSettings();

      expect(settings.stability, 0.5);
      expect(settings.similarityBoost, 0.75);
      expect(settings.style, 0.0);
      expect(settings.speed, 1.0);
      expect(settings.useSpeakerBoost, true);
    });

    test('arabicOptimized preset has correct values', () {
      const settings = TTSSettings.arabicOptimized;

      expect(settings.stability, 0.55);
      expect(settings.similarityBoost, 0.8);
      expect(settings.style, 0.1);
      expect(settings.speed, 0.95);
      expect(settings.useSpeakerBoost, true);
    });

    test('broadcast preset has correct values', () {
      const settings = TTSSettings.broadcast;

      expect(settings.stability, 0.6);
      expect(settings.similarityBoost, 0.75);
      expect(settings.style, 0.15);
      expect(settings.speed, 0.9);
      expect(settings.useSpeakerBoost, true);
    });

    test('copyWith works correctly', () {
      const settings = TTSSettings();

      final updated = settings.copyWith(stability: 0.8, speed: 1.2);

      expect(updated.stability, 0.8);
      expect(updated.speed, 1.2);
      expect(updated.similarityBoost, 0.75); // unchanged
    });

    test('toJson works correctly', () {
      const settings = TTSSettings(
        stability: 0.7,
        similarityBoost: 0.8,
        style: 0.2,
        speed: 1.1,
        useSpeakerBoost: false,
      );

      final json = settings.toJson();

      expect(json['stability'], 0.7);
      expect(json['similarity_boost'], 0.8);
      expect(json['style'], 0.2);
      expect(json['speed'], 1.1);
      expect(json['use_speaker_boost'], false);
    });

    test('fromJson works correctly', () {
      final json = {
        'stability': 0.6,
        'similarity_boost': 0.7,
        'style': 0.1,
        'speed': 0.9,
        'use_speaker_boost': true,
      };

      final settings = TTSSettings.fromJson(json);

      expect(settings.stability, 0.6);
      expect(settings.similarityBoost, 0.7);
      expect(settings.style, 0.1);
      expect(settings.speed, 0.9);
      expect(settings.useSpeakerBoost, true);
    });

    test('fromJson handles missing values with defaults', () {
      final json = <String, dynamic>{};

      final settings = TTSSettings.fromJson(json);

      expect(settings.stability, 0.5);
      expect(settings.similarityBoost, 0.75);
      expect(settings.style, 0.0);
      expect(settings.speed, 1.0);
      expect(settings.useSpeakerBoost, true);
    });
  });
}
