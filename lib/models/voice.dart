/// Voice model representing an ElevenLabs voice.
class Voice {
  final String id;
  final String name;
  final String? description;
  final String? language;
  final String? accent;
  final String? gender;
  final String? age;
  final String? useCase;
  final String? previewUrl;
  final Map<String, dynamic>? labels;
  final bool isFavorite;

  const Voice({
    required this.id,
    required this.name,
    this.description,
    this.language,
    this.accent,
    this.gender,
    this.age,
    this.useCase,
    this.previewUrl,
    this.labels,
    this.isFavorite = false,
  });

  factory Voice.fromJson(Map<String, dynamic> json) {
    final labels = json['labels'] as Map<String, dynamic>?;
    return Voice(
      id: json['voice_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      description: json['description'] as String?,
      language: labels?['language'] as String?,
      accent: labels?['accent'] as String?,
      gender: labels?['gender'] as String?,
      age: labels?['age'] as String?,
      useCase: labels?['use_case'] as String?,
      previewUrl: json['preview_url'] as String?,
      labels: labels,
    );
  }

  Voice copyWith({
    String? id,
    String? name,
    String? description,
    String? language,
    String? accent,
    String? gender,
    String? age,
    String? useCase,
    String? previewUrl,
    Map<String, dynamic>? labels,
    bool? isFavorite,
  }) {
    return Voice(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      language: language ?? this.language,
      accent: accent ?? this.accent,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      useCase: useCase ?? this.useCase,
      previewUrl: previewUrl ?? this.previewUrl,
      labels: labels ?? this.labels,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voice_id': id,
      'name': name,
      'description': description,
      'labels': labels,
      'preview_url': previewUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Voice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
