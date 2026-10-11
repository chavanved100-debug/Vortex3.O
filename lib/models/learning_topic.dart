/// A topic belonging to a [LearningSubject].
class LearningTopic {
  const LearningTopic({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.objective,
    required this.description,
    this.hasLesson = false,
    this.isDemoPath = false,
  });

  /// Stable identifier (for example `math_linear_equations`).
  final String id;

  /// Parent subject id.
  final String subjectId;

  /// Display name shown in navigation and the lesson screen.
  final String name;

  /// Learning objective shown at the top of the lesson.
  final String objective;

  /// Short description for the topic tile.
  final String description;

  /// Whether verified lesson + quiz content exists for this topic.
  final bool hasLesson;

  /// True when this topic carries verified demo content.
  final bool isDemoPath;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectId': subjectId,
    'name': name,
    'objective': objective,
    'description': description,
    'hasLesson': hasLesson,
    'isDemoPath': isDemoPath,
  };

  factory LearningTopic.fromJson(Map<String, dynamic> json) {
    return LearningTopic(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      name: json['name'] as String? ?? '',
      objective: json['objective'] as String? ?? '',
      description: json['description'] as String? ?? '',
      hasLesson: json['hasLesson'] as bool? ?? false,
      isDemoPath: json['isDemoPath'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LearningTopic &&
      other.id == id &&
      other.subjectId == subjectId &&
      other.name == name;

  @override
  int get hashCode => Object.hash(id, subjectId, name);

  @override
  String toString() => 'LearningTopic($id, $name)';
}
