/// Difficulty band for a question.
///
/// [level] provides an ordered numeric value used by the adaptive engine to
/// walk difficulty up or down without relying on string comparisons.
enum Difficulty {
  easy(1, 'Easy'),
  medium(2, 'Medium'),
  hard(3, 'Hard'),
  challenge(4, 'Challenge');

  const Difficulty(this.level, this.label);

  final int level;
  final String label;

  /// Parses a wire value, falling back to [Difficulty.medium] for unknown or
  /// malformed values so a single bad record never breaks a quiz.
  static Difficulty fromName(Object? value) {
    if (value is Difficulty) return value;
    final raw = value?.toString().toLowerCase();
    for (final d in Difficulty.values) {
      if (d.name.toLowerCase() == raw) return d;
    }
    return Difficulty.medium;
  }

  Difficulty get easier {
    final index = Difficulty.values.indexOf(this);
    return Difficulty.values[index == 0 ? 0 : index - 1];
  }

  Difficulty get harder {
    final index = Difficulty.values.indexOf(this);
    return Difficulty.values[index >= Difficulty.values.length - 1
        ? index
        : index + 1];
  }
}

/// Supported question formats. The MVP presents [multipleChoice]; the other
/// values are reserved so the model does not need to change later.
enum QuestionType {
  multipleChoice('multipleChoice'),
  trueFalse('trueFalse'),
  shortAnswer('shortAnswer'),
  numeric('numeric');

  const QuestionType(this.id);

  final String id;

  static QuestionType fromId(Object? value) {
    if (value is QuestionType) return value;
    final raw = value?.toString();
    for (final t in QuestionType.values) {
      if (t.id == raw || t.name == raw) return t;
    }
    return QuestionType.multipleChoice;
  }
}

/// A rule that maps a plausible wrong answer to a misconception category.
///
/// NOTE: the shared `Question` contract lists `misconceptionRules` but does not
/// define the element schema. This is a documented, backward-compatible
/// proposal for that element. It can still be round-tripped from raw maps.
class MisconceptionRule {
  const MisconceptionRule({
    required this.id,
    required this.errorCategory,
    required this.concept,
    this.triggerAnswers = const [],
    this.hintId,
    this.evidence = const [],
  });

  /// Stable identifier for the rule.
  final String id;

  /// Category of error this rule represents (for example `sign_error`).
  final String errorCategory;

  /// The concept the learner is likely struggling with.
  final String concept;

  /// Normalised answers that trigger this rule.
  final List<String> triggerAnswers;

  /// Optional hint to suggest when this rule fires.
  final String? hintId;

  /// Optional evidence templates supporting this rule.
  final List<String> evidence;

  bool matches(String answer) {
    final normalised = _normalise(answer);
    return triggerAnswers.any((a) => _normalise(a) == normalised);
  }

  static String _normalise(String value) => value.trim().toLowerCase();

  Map<String, dynamic> toJson() => {
    'id': id,
    'errorCategory': errorCategory,
    'concept': concept,
    'triggerAnswers': triggerAnswers,
    'hintId': hintId,
    'evidence': evidence,
  };

  factory MisconceptionRule.fromJson(Map<String, dynamic> json) {
    return MisconceptionRule(
      id: json['id'] as String? ?? '',
      errorCategory: json['errorCategory'] as String? ?? 'unknown',
      concept: json['concept'] as String? ?? '',
      triggerAnswers: (json['triggerAnswers'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      hintId: json['hintId'] as String?,
      evidence: (json['evidence'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
    );
  }
}

/// The shared question contract.
///
/// Field names match the team agreement exactly:
/// id, domain, subject, topic, prompt, type, options, correctAnswer,
/// explanation, misconceptionRules, hints, followUpIds, difficulty.
///
/// `domain`, `subject` and `topic` are kept as strings (the stable ids) so the
/// contract is not coupled to the Dart enum and remains forward compatible with
/// service payloads.
class Question {
  const Question({
    required this.id,
    required this.domain,
    required this.subject,
    required this.topic,
    required this.prompt,
    required this.correctAnswer,
    required this.explanation,
    this.type = QuestionType.multipleChoice,
    this.options = const [],
    this.misconceptionRules = const [],
    this.hints = const [],
    this.followUpIds = const [],
    this.difficulty = Difficulty.medium,
  });

  final String id;
  final String domain;
  final String subject;
  final String topic;
  final String prompt;
  final QuestionType type;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final List<MisconceptionRule> misconceptionRules;
  final List<String> hints;
  final List<String> followUpIds;
  final Difficulty difficulty;

  /// True when the learner answer matches the verified correct answer.
  /// Comparison is trimmed and case-insensitive, with light numeric tolerance.
  bool isCorrect(String answer) {
    final expected = _normalise(correctAnswer);
    final actual = _normalise(answer);
    if (expected == actual) return true;
    final expectedNumber = num.tryParse(correctAnswer.trim());
    final actualNumber = num.tryParse(answer.trim());
    if (expectedNumber != null && actualNumber != null) {
      return (expectedNumber - actualNumber).abs() < 1e-9;
    }
    return false;
  }

  static String _normalise(String value) => value.trim().toLowerCase();

  Question copyWith({
    String? id,
    String? domain,
    String? subject,
    String? topic,
    String? prompt,
    QuestionType? type,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    List<MisconceptionRule>? misconceptionRules,
    List<String>? hints,
    List<String>? followUpIds,
    Difficulty? difficulty,
  }) {
    return Question(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      prompt: prompt ?? this.prompt,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      misconceptionRules: misconceptionRules ?? this.misconceptionRules,
      hints: hints ?? this.hints,
      followUpIds: followUpIds ?? this.followUpIds,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'domain': domain,
    'subject': subject,
    'topic': topic,
    'prompt': prompt,
    'type': type.id,
    'options': options,
    'correctAnswer': correctAnswer,
    'explanation': explanation,
    'misconceptionRules': misconceptionRules
        .map((r) => r.toJson())
        .toList(growable: false),
    'hints': hints,
    'followUpIds': followUpIds,
    'difficulty': difficulty.name,
  };

  /// Tolerant deserialisation: missing optional collections become empty lists
  /// and unknown enum values fall back to safe defaults.
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      type: QuestionType.fromId(json['type']),
      options: (json['options'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      correctAnswer: json['correctAnswer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      misconceptionRules:
          (json['misconceptionRules'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(MisconceptionRule.fromJson)
              .toList(growable: false),
      hints: (json['hints'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      followUpIds: (json['followUpIds'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      difficulty: Difficulty.fromName(json['difficulty']),
    );
  }

  @override
  bool operator ==(Object other) => other is Question && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Question($id, $prompt)';
}
