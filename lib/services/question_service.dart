import '../models/question.dart';

/// Read access to questions. Implemented locally by
/// `MockQuestionService`; the same interface can later be backed by the real
/// shared question service.
abstract class QuestionService {
  /// Returns questions filtered by any combination of domain/subject/topic.
  Future<List<Question>> getQuestions({
    String? domain,
    String? subject,
    String? topic,
  });

  /// Returns all questions in the bank.
  Future<List<Question>> getAllQuestions();

  /// Returns a single question by id, or null when it does not exist.
  Future<Question?> getQuestionById(String id);

  /// Returns follow-up questions referenced by [questionId]'s `followUpIds`.
  Future<List<Question>> getFollowUpQuestions(String questionId);
}
