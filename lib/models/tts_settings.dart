/// TTS generation settings.
/// Only includes parameters supported by ElevenLabs API.
class TTSSettings {
  final double stability;
  final double similarityBoost;
  final double style;
  final double speed;
  final bool useSpeakerBoost;

  const TTSSettings({
    this.stability = 0.5,
    this.similarityBoost = 0.75,
    this.style = 0.0,
    this.speed = 1.0,
    this.useSpeakerBoost = true,
  });

  /// Default settings optimized for natural speech.
  static const TTSSettings defaults = TTSSettings();

  /// Settings optimized for Arabic/Darija naturalness.
  static const TTSSettings arabicOptimized = TTSSettings(
    stability: 0.55,
    similarityBoost: 0.8,
    style: 0.1,
    speed: 0.95,
    useSpeakerBoost: true,
  );

  /// Settings optimized for broadcast/TV presentation.
  static const TTSSettings broadcast = TTSSettings(
    stability: 0.6,
    similarityBoost: 0.75,
    style: 0.15,
    speed: 0.9,
    useSpeakerBoost: true,
  );

  TTSSettings copyWith({
    double? stability,
    double? similarityBoost,
    double? style,
    double? speed,
    bool? useSpeakerBoost,
  }) {
    return TTSSettings(
      stability: stability ?? this.stability,
      similarityBoost: similarityBoost ?? this.similarityBoost,
      style: style ?? this.style,
      speed: speed ?? this.speed,
      useSpeakerBoost: useSpeakerBoost ?? this.useSpeakerBoost,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stability': stability,
      'similarity_boost': similarityBoost,
      'style': style,
      'speed': speed,
      'use_speaker_boost': useSpeakerBoost,
    };
  }

  factory TTSSettings.fromJson(Map<String, dynamic> json) {
    return TTSSettings(
      stability: (json['stability'] as num?)?.toDouble() ?? 0.5,
      similarityBoost: (json['similarity_boost'] as num?)?.toDouble() ?? 0.75,
      style: (json['style'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      useSpeakerBoost: json['use_speaker_boost'] as bool? ?? true,
    );
  }
}
