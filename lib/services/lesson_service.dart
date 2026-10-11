import '../models/lesson.dart';

/// Local content access: lessons, standalone explanations and clarification
/// question text. Kept offline-first so the core cycle never needs a network.
abstract class LessonService {
  /// Returns the lesson for a topic, or null when no verified lesson exists.
  Future<Lesson?> getLessonForTopic(String topicId);

  /// Resolves an explanation referenced by an adaptive decision.
  Future<Explanation?> getExplanation(String explanationId);

  /// Returns the text of a clarification question by id, or null if missing.
  Future<String?> getClarificationQuestionText(String questionId);

  /// Resolves a hint by id (used for `DiagnosisResult.recommendedHintId`).
  /// Returns null when the hint is unknown so callers can fall back safely.
  Future<Hint?> getHint(String hintId);
}
