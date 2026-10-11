import '../models/adaptive_decision.dart';
import '../models/learning_progress.dart';
import '../models/question.dart';
import '../services/adaptive_learning_service.dart';
import '../services/question_service.dart';
import '../utils/service_exceptions.dart';
import 'mock_question_service.dart';

/// Offline adaptive engine used until Member 3 provides the real service.
///
/// All decision logic lives here, never in widgets. The UI only renders the
/// returned [AdaptiveDecision].
class MockAdaptiveLearningService implements AdaptiveLearningService {
  MockAdaptiveLearningService({
    QuestionService? questions,
    this.shouldFail = false,
  }) : _questions = questions ?? MockQuestionService();

  final QuestionService _questions;

  /// When true every call throws [AdaptiveServiceException].
  final bool shouldFail;

  int callCount = 0;

  @override
  Future<AdaptiveDecision> decide(AdaptiveContext context) async {
    callCount++;
    if (shouldFail) {
      throw const AdaptiveServiceException(
        'We could not choose the next step right now.',
      );
    }
    final diagnosis = context.diagnosis;

    // 1. Uncertain diagnosis: clarify before personalising anything.
    if (diagnosis.needsClarification) {
      return AdaptiveDecision(
        activityType: ActivityType.clarificationActivity,
        difficulty: context.currentDifficulty,
      );
    }

    // 2. Demonstrated understanding: cautiously raise the challenge.
    //    A single correct answer is not enough (attemptCountForTopic >= 2).
    if (context.previousCorrect &&
        context.recentIncorrectCount == 0 &&
        context.attemptCountForTopic >= 2) {
      final harder = await _pickFollowUp(context, preferHarder: true);
      return AdaptiveDecision(
        activityType: ActivityType.challengeQuestion,
        nextQuestionId: harder?.id,
        difficulty: context.currentDifficulty.harder,
      );
    }

    // 3. Repeated errors: revise with easier practice.
    if (context.recentIncorrectCount >= 2) {
      final easier = await _pickFollowUp(context, preferEasier: true);
      return AdaptiveDecision(
        explanationId: 'exp_generic_revision',
        activityType: ActivityType.revisionExercise,
        nextQuestionId: easier?.id,
        difficulty: context.currentDifficulty.easier,
      );
    }

    // 4. Category-specific follow-ups.
    switch (diagnosis.errorCategory) {
      case 'conceptual_gap':
      case 'boundary_error':
        final practice = await _pickFollowUp(context, preferEasier: true);
        return AdaptiveDecision(
          explanationId: _simplifiedExplanationId(context),
          activityType: ActivityType.targetedPractice,
          nextQuestionId: practice?.id,
          difficulty: context.currentDifficulty,
        );
      case 'sign_error':
      case 'incomplete_reasoning':
        final practice = await _pickFollowUp(context);
        return AdaptiveDecision(
          explanationId: _workedExampleId(context),
          activityType: ActivityType.workedExample,
          nextQuestionId: practice?.id,
          difficulty: context.currentDifficulty,
        );
      case 'calculation_slip':
      case 'careless_slip':
        final practice = await _pickFollowUp(context);
        return AdaptiveDecision(
          activityType: ActivityType.targetedPractice,
          nextQuestionId: practice?.id,
          difficulty: context.currentDifficulty,
        );
      case 'none':
        final harder = await _pickFollowUp(context, preferHarder: true);
        return AdaptiveDecision(
          activityType: ActivityType.challengeQuestion,
          nextQuestionId: harder?.id,
          difficulty: context.currentDifficulty.harder,
        );
      default:
        final revision = await _pickFollowUp(context, preferEasier: true);
        return AdaptiveDecision(
          explanationId: 'exp_generic_revision',
          activityType: ActivityType.revisionExercise,
          nextQuestionId: revision?.id,
          difficulty: context.currentDifficulty.easier,
        );
    }
  }

  String? _simplifiedExplanationId(AdaptiveContext context) {
    if (context.topic.contains('linear')) return 'exp_math_linear_simplified';
    if (context.topic.contains('loop') || context.topic.contains('range')) {
      return 'exp_python_range_simplified';
    }
    return 'exp_generic_revision';
  }

  String? _workedExampleId(AdaptiveContext context) {
    if (context.topic.contains('linear')) return 'exp_math_linear_step';
    if (context.topic.contains('loop') || context.topic.contains('range')) {
      return 'exp_python_range_step';
    }
    return 'exp_generic_revision';
  }

  /// Picks a follow-up question, preferring the current question's
  /// `followUpIds` and falling back to other questions in the same topic.
  Future<Question?> _pickFollowUp(
    AdaptiveContext context, {
    bool preferHarder = false,
    bool preferEasier = false,
  }) async {
    final candidates = <Question>[];
    if (context.attemptedQuestionId != null) {
      candidates.addAll(
        await _questions.getFollowUpQuestions(context.attemptedQuestionId!),
      );
    }
    if (candidates.isEmpty) {
      candidates.addAll(await _questions.getQuestions(topic: context.topic));
    }
    // Never immediately repeat the same question.
    final filtered = candidates
        .where((q) => q.id != context.attemptedQuestionId)
        .toList();
    if (filtered.isEmpty) return null;

    int rank(Question q) => q.difficulty.level;
    final target = context.currentDifficulty;
    filtered.sort(
      (a, b) => (rank(a) - target.level).abs().compareTo(
        (rank(b) - target.level).abs(),
      ),
    );
    if (preferHarder) {
      final harder = filtered.where((q) => rank(q) > target.level).toList();
      if (harder.isNotEmpty) {
        harder.sort((a, b) => rank(a).compareTo(rank(b)));
        return harder.first;
      }
    }
    if (preferEasier) {
      final easier = filtered.where((q) => rank(q) < target.level).toList();
      if (easier.isNotEmpty) {
        easier.sort((a, b) => rank(b).compareTo(rank(a)));
        return easier.first;
      }
    }
    return filtered.first;
  }
}
