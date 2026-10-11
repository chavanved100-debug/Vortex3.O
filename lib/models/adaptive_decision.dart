import 'question.dart';

/// The kind of follow-up activity chosen by the adaptive engine.
///
/// Unknown wire values fall back to [ActivityType.unknown] so the UI can show a
/// safe fallback instead of crashing.
enum ActivityType {
  simplerExplanation('simpler_explanation', 'A simpler explanation'),
  workedExample('worked_example', 'A step-by-step worked example'),
  targetedPractice('targeted_practice', 'A targeted practice question'),
  clarificationActivity('clarification_activity', 'A short clarification'),
  revisionExercise('revision_exercise', 'A revision exercise'),
  challengeQuestion('challenge_question', 'A more challenging question'),
  unknown('unknown', 'A suitable next step');

  const ActivityType(this.id, this.label);

  final String id;
  final String label;

  static ActivityType fromId(Object? value) {
    if (value is ActivityType) return value;
    final raw = value?.toString();
    for (final type in ActivityType.values) {
      if (type.id == raw || type.name == raw) return type;
    }
    return ActivityType.unknown;
  }
}

/// Shared adaptive decision contract owned by Member 3.
///
/// Field names match the team agreement exactly:
/// explanationId, activityType, nextQuestionId, difficulty.
///
/// Content ids are nullable because a decision may not reference every piece of
/// content. Missing content is handled by the UI with a safe fallback.
class AdaptiveDecision {
  const AdaptiveDecision({
    this.explanationId,
    this.activityType = ActivityType.unknown,
    this.nextQuestionId,
    this.difficulty = Difficulty.medium,
  });

  /// Id of the explanation to show (resolved through a local content service).
  final String? explanationId;

  /// The activity the learner should do next.
  final ActivityType activityType;

  /// Id of the follow-up question, when the decision includes one.
  final String? nextQuestionId;

  /// Difficulty for the follow-up question.
  final Difficulty difficulty;

  Map<String, dynamic> toJson() => {
    'explanationId': explanationId,
    'activityType': activityType.id,
    'nextQuestionId': nextQuestionId,
    'difficulty': difficulty.name,
  };

  factory AdaptiveDecision.fromJson(Map<String, dynamic> json) {
    return AdaptiveDecision(
      explanationId: json['explanationId'] as String?,
      activityType: ActivityType.fromId(json['activityType']),
      nextQuestionId: json['nextQuestionId'] as String?,
      difficulty: Difficulty.fromName(json['difficulty']),
    );
  }

  @override
  String toString() =>
      'AdaptiveDecision(${activityType.name}, next: $nextQuestionId, ${difficulty.name})';
}
