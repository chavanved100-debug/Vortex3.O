import '../models/diagnosis_result.dart';
import '../models/learning_progress.dart';
import '../services/diagnosis_service.dart';
import '../utils/service_exceptions.dart';

/// Rule-based offline diagnosis used until Member 2 provides the real service.
///
/// It demonstrates the important rule that a wrong final answer alone must not
/// establish the learner's reasoning: when no misconception rule matches, the
/// result is marked `needsClarification = true` and is never presented as a
/// confirmed misconception.
class MockDiagnosisService implements DiagnosisService {
  MockDiagnosisService({this.forcedResult, this.shouldFail = false});

  /// When set, every diagnosis returns this result (used by tests and demos).
  final DiagnosisResult? forcedResult;

  /// When true every call throws [DiagnosisServiceException].
  final bool shouldFail;

  /// Number of diagnosis calls, useful for assertions.
  int callCount = 0;

  @override
  Future<DiagnosisResult> diagnose(DiagnosisRequest request) async {
    callCount++;
    if (shouldFail) {
      throw const DiagnosisServiceException(
        'The detective could not analyse this answer right now.',
      );
    }
    if (forcedResult != null) return forcedResult!;

    // A correct answer carries no misconception.
    if (request.question.isCorrect(request.learnerAnswer)) {
      return const DiagnosisResult(
        concept: 'No error detected',
        errorCategory: 'none',
        evidence: ['The submitted answer matches the verified answer.'],
        confidence: 0.9,
      );
    }

    // Second pass after a clarification response.
    if (request.isClarification) {
      return _refine(request);
    }

    // First pass: look for a matching misconception rule.
    final answer = _normalise(request.learnerAnswer);
    for (final rule in request.question.misconceptionRules) {
      final triggers = rule.triggerAnswers.map(_normalise);
      if (triggers.contains(answer)) {
        final evidence = rule.evidence.isEmpty
            ? ['The chosen answer matches a known error pattern for this topic.']
            : rule.evidence;
        return DiagnosisResult(
          concept: rule.concept,
          errorCategory: rule.errorCategory,
          evidence: evidence,
          confidence: 0.8,
          needsClarification: false,
          recommendedHintId: rule.hintId,
        );
      }
    }

    // No confident match: ask a clarifying question instead of guessing.
    return DiagnosisResult(
      concept: 'Reasoning not yet clear',
      errorCategory: 'unknown',
      evidence: [
        'The chosen answer differs from the verified answer, but it does not '
            'match a known error pattern.',
      ],
      confidence: 0.2,
      needsClarification: true,
      clarificationQuestionId: _clarificationIdFor(request.question.topic),
    );
  }

  DiagnosisResult _refine(DiagnosisRequest request) {
    final response = _normalise(request.clarificationResponse ?? '');
    final topic = request.question.topic;

    if (response.contains('only the first term')) {
      return DiagnosisResult(
        concept: 'Distributing a factor across a bracket',
        errorCategory: 'conceptual_gap',
        evidence: [
          'You said you multiplied only the first term inside the bracket.',
          'That matches a known distribution error.',
        ],
        confidence: 0.7,
        needsClarification: false,
        recommendedHintId: 'hint_math_distribute',
      );
    }
    if (response.contains('started at 1') ||
        response.contains('included') ||
        response.contains('include')) {
      return DiagnosisResult(
        concept: 'range() boundaries',
        errorCategory: 'boundary_error',
        evidence: [
          'You described how you counted the range values.',
          'That matches a known range boundary off-by-one error.',
        ],
        confidence: 0.7,
        needsClarification: false,
        recommendedHintId: 'hint_python_range_stop',
      );
    }
    if (response.contains('removed') || response.contains('first')) {
      return DiagnosisResult(
        concept: 'Arithmetic while rearranging the equation',
        errorCategory: 'careless_slip',
        evidence: [
          'You described the correct first step, so the result looks like a '
              'slip rather than a rule misunderstanding.',
        ],
        confidence: 0.55,
        needsClarification: false,
      );
    }

    // Still not clear: remain honest and uncertain.
    return DiagnosisResult(
      concept: 'Reasoning not yet clear',
      errorCategory: 'unknown',
      evidence: [
        'Your explanation did not yet point to a single likely cause.',
      ],
      confidence: 0.2,
      needsClarification: true,
      clarificationQuestionId: _clarificationIdForSecondRound(topic),
    );
  }

  String _clarificationIdFor(String topic) {
    if (topic.contains('linear_equations')) return 'clarify_math_linear_1';
    if (topic.contains('loop') || topic.contains('range')) {
      return 'clarify_python_range_1';
    }
    return 'clarify_generic';
  }

  String _clarificationIdForSecondRound(String topic) {
    if (topic.contains('linear')) return 'clarify_math_linear_2';
    if (topic.contains('loop') || topic.contains('range')) {
      return 'clarify_python_range_2';
    }
    return 'clarify_generic';
  }

  String _normalise(String value) => value.trim().toLowerCase();
}

/// Predefined diagnosis results for demos and tests. Keep scenario data out of
/// the widgets.
class DiagnosisScenarios {
  const DiagnosisScenarios._();

  /// A likely conceptual misconception with supporting evidence.
  static const DiagnosisResult misconception = DiagnosisResult(
    concept: 'Distributing a factor across a bracket',
    errorCategory: 'conceptual_gap',
    evidence: [
      'The learner expanded 5(x - 2) as 5x - 2 instead of 5x - 10.',
      'The same distribution slip appeared on the previous attempt.',
    ],
    confidence: 0.82,
    needsClarification: false,
    recommendedHintId: 'hint_math_distribute',
  );

  /// A likely careless calculation slip.
  static const DiagnosisResult carelessSlip = DiagnosisResult(
    concept: 'Arithmetic while rearranging the equation',
    errorCategory: 'calculation_slip',
    evidence: [
      'The learner chose a value one step away from the correct answer.',
      'Their earlier attempts on this topic were correct.',
    ],
    confidence: 0.6,
    needsClarification: false,
    recommendedHintId: 'hint_math_undo_multiplication',
  );

  /// An uncertain diagnosis that must trigger a clarification question.
  static const DiagnosisResult uncertain = DiagnosisResult(
    concept: 'Reasoning not yet clear',
    errorCategory: 'unknown',
    evidence: ['The answer does not match a known error pattern yet.'],
    confidence: 0.2,
    needsClarification: true,
    clarificationQuestionId: 'clarify_math_linear_1',
  );

  /// A diagnosis with an error category the app does not know about.
  static const DiagnosisResult unknownCategory = DiagnosisResult(
    concept: 'A pattern we are still learning to name',
    errorCategory: 'novel_error_xyz',
    evidence: [
      'The service returned a category that the app does not recognise.',
    ],
    confidence: 0.5,
    needsClarification: false,
  );
}
