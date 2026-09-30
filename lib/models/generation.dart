/// Represents a TTS generation result.
class Generation {
  final String id;
  final String text;
  final String voiceId;
  final String voiceName;
  final DateTime createdAt;
  final String? audioFilePath;
  final int? durationMs;
  final String? modelId;

  const Generation({
    required this.id,
    required this.text,
    required this.voiceId,
    required this.voiceName,
    required this.createdAt,
    this.audioFilePath,
    this.durationMs,
    this.modelId,
  });

  factory Generation.fromJson(Map<String, dynamic> json) {
    return Generation(
      id: json['id'] as String,
      text: json['text'] as String,
      voiceId: json['voice_id'] as String,
      voiceName: json['voice_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      audioFilePath: json['audio_file_path'] as String?,
      durationMs: json['duration_ms'] as int?,
      modelId: json['model_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'voice_id': voiceId,
      'voice_name': voiceName,
      'created_at': createdAt.toIso8601String(),
      'audio_file_path': audioFilePath,
      'duration_ms': durationMs,
      'model_id': modelId,
    };
  }

  Generation copyWith({
    String? id,
    String? text,
    String? voiceId,
    String? voiceName,
    DateTime? createdAt,
    String? audioFilePath,
    int? durationMs,
    String? modelId,
  }) {
    return Generation(
      id: id ?? this.id,
      text: text ?? this.text,
      voiceId: voiceId ?? this.voiceId,
      voiceName: voiceName ?? this.voiceName,
      createdAt: createdAt ?? this.createdAt,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      durationMs: durationMs ?? this.durationMs,
      modelId: modelId ?? this.modelId,
    );
  }
}
