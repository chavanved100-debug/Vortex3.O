import '../models/lesson.dart';
import '../services/lesson_service.dart';
import '../utils/service_exceptions.dart';
import 'mock_lessons.dart';

/// Offline lesson service backed by [LessonContent].
class MockLessonService implements LessonService {
  MockLessonService({this.shouldFail = false});

  /// When true every call throws [ContentNotFoundException].
  final bool shouldFail;

  @override
  Future<Lesson?> getLessonForTopic(String topicId) async {
    _maybeFail();
    return LessonContent.lessonForTopic(topicId);
  }

  @override
  Future<Explanation?> getExplanation(String explanationId) async {
    _maybeFail();
    return LessonContent.explanationById(explanationId);
  }

  @override
  Future<String?> getClarificationQuestionText(String questionId) async {
    _maybeFail();
    return LessonContent.clarificationQuestions[questionId] ??
        LessonContent.clarificationQuestions['clarify_generic'];
  }

  @override
  Future<Hint?> getHint(String hintId) async {
    _maybeFail();
    return LessonContent.hintById(hintId);
  }

  void _maybeFail() {
    if (shouldFail) {
      throw const ContentNotFoundException(
        'Lesson content is unavailable right now.',
      );
    }
  }
}
