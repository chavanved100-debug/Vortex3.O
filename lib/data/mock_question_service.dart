import '../models/question.dart';
import '../services/question_service.dart';
import '../utils/service_exceptions.dart';
import 'mock_questions.dart';

/// Offline question service backed by [QuestionBank].
///
/// Supports dependency injection so tests can supply an empty bank or force a
/// failure without touching real data.
class MockQuestionService implements QuestionService {
  MockQuestionService({List<Question>? questions, this.shouldFail = false})
    : _questions = List<Question>.unmodifiable(questions ?? QuestionBank.all);

  final List<Question> _questions;

  /// When true every call throws [QuestionServiceException].
  final bool shouldFail;

  static final MockQuestionService empty = MockQuestionService(
    questions: const <Question>[],
  );

  @override
  Future<List<Question>> getQuestions({
    String? domain,
    String? subject,
    String? topic,
  }) async {
    _maybeFail();
    return _questions
        .where(
          (q) =>
              (domain == null || q.domain == domain) &&
              (subject == null || q.subject == subject) &&
              (topic == null || q.topic == topic),
        )
        .toList(growable: false);
  }

  @override
  Future<List<Question>> getAllQuestions() async {
    _maybeFail();
    return _questions;
  }

  @override
  Future<Question?> getQuestionById(String id) async {
    _maybeFail();
    for (final question in _questions) {
      if (question.id == id) return question;
    }
    return null;
  }

  @override
  Future<List<Question>> getFollowUpQuestions(String questionId) async {
    _maybeFail();
    final source = await getQuestionById(questionId);
    if (source == null) return const [];
    final result = <Question>[];
    for (final id in source.followUpIds) {
      final question = await getQuestionById(id);
      if (question != null) result.add(question);
    }
    return result;
  }

  void _maybeFail() {
    if (shouldFail) {
      throw const QuestionServiceException(
        'Question bank is unavailable right now.',
      );
    }
  }
}
