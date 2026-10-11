import 'learning_domain.dart';

/// A subject that belongs to exactly one [LearningDomain].
class LearningSubject {
  const LearningSubject({
    required this.id,
    required this.domain,
    required this.name,
    required this.description,
    this.isDemoPath = false,
  });

  /// Stable identifier (for example `mathematics_algebra`).
  final String id;

  /// Parent domain.
  final LearningDomain domain;

  /// Display name shown on the subject card.
  final String name;

  /// Short description of the subject.
  final String description;

  /// True when this subject carries verified demo content.
  final bool isDemoPath;

  Map<String, dynamic> toJson() => {
    'id': id,
    'domain': domain.id,
    'name': name,
    'description': description,
    'isDemoPath': isDemoPath,
  };

  factory LearningSubject.fromJson(Map<String, dynamic> json) {
    final domain = LearningDomain.fromId(json['domain'] as String?);
    if (domain == null) {
      throw FormatException('Unknown domain id: ${json['domain']}');
    }
    return LearningSubject(
      id: json['id'] as String,
      domain: domain,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isDemoPath: json['isDemoPath'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LearningSubject &&
      other.id == id &&
      other.domain == domain &&
      other.name == name;

  @override
  int get hashCode => Object.hash(id, domain, name);

  @override
  String toString() => 'LearningSubject($id, $name)';
}
