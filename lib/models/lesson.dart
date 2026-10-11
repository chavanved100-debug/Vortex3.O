/// A titled section of a lesson (concept explanation, recap, etc.).
class LessonSection {
  const LessonSection({required this.heading, required this.body});

  final String heading;
  final String body;

  Map<String, dynamic> toJson() => {'heading': heading, 'body': body};

  factory LessonSection.fromJson(Map<String, dynamic> json) => LessonSection(
    heading: json['heading'] as String? ?? '',
    body: json['body'] as String? ?? '',
  );
}

/// A hint attached to a lesson or question.
class Hint {
  const Hint({required this.id, required this.title, required this.body});

  final String id;
  final String title;
  final String body;

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'body': body};

  factory Hint.fromJson(Map<String, dynamic> json) => Hint(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
  );
}

/// A standalone explanation that can be referenced by `explanationId` from an
/// [AdaptiveDecision]. Stored locally so it works fully offline.
class Explanation {
  const Explanation({
    required this.id,
    required this.title,
    required this.body,
    this.steps = const [],
    this.isSimplified = false,
  });

  final String id;
  final String title;
  final String body;
  final List<String> steps;

  /// True when this is a deliberately simplified re-explanation.
  final bool isSimplified;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'steps': steps,
    'isSimplified': isSimplified,
  };

  factory Explanation.fromJson(Map<String, dynamic> json) => Explanation(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    steps: (json['steps'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(growable: false),
    isSimplified: json['isSimplified'] as bool? ?? false,
  );
}

/// A lesson for a topic: objective, concept explanation, worked example and
/// hints. Rendered by the lesson screen (Phase 3).
class Lesson {
  const Lesson({
    required this.id,
    required this.topicId,
    required this.title,
    required this.objective,
    this.sections = const [],
    this.workedExampleSteps = const [],
    this.hints = const [],
  });

  final String id;
  final String topicId;
  final String title;
  final String objective;
  final List<LessonSection> sections;
  final List<String> workedExampleSteps;
  final List<Hint> hints;

  Map<String, dynamic> toJson() => {
    'id': id,
    'topicId': topicId,
    'title': title,
    'objective': objective,
    'sections': sections.map((s) => s.toJson()).toList(growable: false),
    'workedExampleSteps': workedExampleSteps,
    'hints': hints.map((h) => h.toJson()).toList(growable: false),
  };

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as String? ?? '',
    topicId: json['topicId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    objective: json['objective'] as String? ?? '',
    sections: (json['sections'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(LessonSection.fromJson)
        .toList(growable: false),
    workedExampleSteps:
        (json['workedExampleSteps'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(growable: false),
    hints: (json['hints'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Hint.fromJson)
        .toList(growable: false),
  );
}
