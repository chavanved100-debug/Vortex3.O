import 'package:flutter_test/flutter_test.dart';
import 'package:learnloop_ai/data/mock_adaptive_learning_service.dart';
import 'package:learnloop_ai/data/mock_diagnosis_service.dart';
import 'package:learnloop_ai/data/mock_lesson_service.dart';
import 'package:learnloop_ai/data/mock_progress_service.dart';
import 'package:learnloop_ai/data/mock_question_service.dart';
import 'package:learnloop_ai/models/adaptive_decision.dart';
import 'package:learnloop_ai/models/diagnosis_result.dart';
import 'package:learnloop_ai/models/learning_progress.dart';
import 'package:learnloop_ai/models/question.dart';
import 'package:learnloop_ai/utils/service_exceptions.dart';

void main() {
  group('MockQuestionService', () {
    final service = MockQuestionService();

    test('filters by domain, subject and topic', () async {
      final math = await service.getQuestions(domain: 'mathematics');
      expect(math, isNotEmpty);
      expect(math.every((q) => q.domain == 'mathematics'), isTrue);

      final loops = await service.getQuestions(
        topic: 'computer_science_python_loops',
      );
      expect(loops, isNotEmpty);
      expect(
        loops.every((q) => q.topic == 'computer_science_python_loops'),
        isTrue,
      );
    });

    test('returns follow-up questions for a question id', () async {
      final followUps = await service.getFollowUpQuestions('math_linear_eq_1');
      expect(followUps, isNotEmpty);
      expect(followUps.map((q) => q.id), contains('math_linear_eq_2'));
    });

    test('empty bank returns no questions', () async {
      expect(await MockQuestionService.empty.getAllQuestions(), isEmpty);
    });

    test('throws a service exception when forced to fail', () async {
      final failing = MockQuestionService(shouldFail: true);
      expect(
        () => failing.getAllQuestions(),
        throwsA(isA<QuestionServiceException>()),
      );
    });
  });

  group('MockDiagnosisService', () {
    final service = MockDiagnosisService();
    final questions = MockQuestionService();

    test('detects a known misconception with evidence', () async {
      final question = (await questions.getQuestionById('math_linear_eq_1'))!;
      final result = await service.diagnose(
        DiagnosisRequest(question: question, learnerAnswer: 'x = 2'),
      );
      expect(result.needsClarification, isFalse);
      expect(result.errorCategory, 'sign_error');
      expect(result.evidence, isNotEmpty);
      expect(result.safeConfidence, greaterThan(0.5));
    });

    test('returns an uncertain result when no rule matches', () async {
      final question = (await questions.getQuestionById('math_linear_eq_1'))!;
      final result = await service.diagnose(
        DiagnosisRequest(question: question, learnerAnswer: 'x = 999'),
      );
      expect(result.needsClarification, isTrue);
      expect(result.clarificationQuestionId, isNotNull);
      expect(result.isDefinitive, isFalse);
    });

    test('refines the diagnosis after a clarification response', () async {
      final question = (await questions.getQuestionById('math_linear_eq_2'))!;
      final result = await service.diagnose(
        DiagnosisRequest(
          question: question,
          learnerAnswer: 'x = 3',
          clarificationResponse: 'I multiplied only the first term',
        ),
      );
      expect(result.errorCategory, 'conceptual_gap');
      expect(result.needsClarification, isFalse);
    });

    test('scenario fixtures cover uncertainty and unknown categories', () {
      expect(DiagnosisScenarios.uncertain.needsClarification, isTrue);
      expect(
        DiagnosisScenarios.unknownCategory.errorCategory,
        'novel_error_xyz',
      );
      expect(DiagnosisScenarios.misconception.evidence, isNotEmpty);
    });

    test('throws when forced to fail', () async {
      final failing = MockDiagnosisService(shouldFail: true);
      final question = (await questions.getQuestionById('math_linear_eq_1'))!;
      expect(
        () => failing.diagnose(
          DiagnosisRequest(question: question, learnerAnswer: 'x = 2'),
        ),
        throwsA(isA<DiagnosisServiceException>()),
      );
    });
  });

  group('MockAdaptiveLearningService', () {
    final questions = MockQuestionService();
    final adaptive = MockAdaptiveLearningService(questions: questions);

    test('clarifies before personalising when uncertain', () async {
      final decision = await adaptive.decide(
        const AdaptiveContext(
          diagnosis: DiagnosisScenarios.uncertain,
          domain: 'mathematics',
          subject: 'mathematics_algebra',
          topic: 'mathematics_algebra_linear_equations',
        ),
      );
      expect(decision.activityType, ActivityType.clarificationActivity);
    });

    test(
      'conceptual gap leads to a simpler explanation and practice',
      () async {
        final decision = await adaptive.decide(
          AdaptiveContext(
            diagnosis: DiagnosisScenarios.misconception,
            domain: 'mathematics',
            subject: 'mathematics_algebra',
            topic: 'mathematics_algebra_linear_equations',
            attemptedQuestionId: 'math_linear_eq_2',
            currentDifficulty: Difficulty.medium,
          ),
        );
        expect(decision.explanationId, 'exp_math_linear_simplified');
        expect(decision.activityType, ActivityType.targetedPractice);
        expect(decision.nextQuestionId, isNotNull);
      },
    );

    test('careless slip leads to a brief verification question', () async {
      final decision = await adaptive.decide(
        AdaptiveContext(
          diagnosis: DiagnosisScenarios.carelessSlip,
          domain: 'mathematics',
          subject: 'mathematics_algebra',
          topic: 'mathematics_algebra_linear_equations',
          attemptedQuestionId: 'math_linear_eq_2',
        ),
      );
      expect(decision.activityType, ActivityType.targetedPractice);
      expect(decision.nextQuestionId, isNotNull);
    });

    test('repeated errors lead to revision with easier practice', () async {
      final decision = await adaptive.decide(
        AdaptiveContext(
          diagnosis: DiagnosisScenarios.misconception,
          domain: 'computer_science',
          subject: 'computer_science_python',
          topic: 'computer_science_python_loops',
          attemptedQuestionId: 'python_loops_2',
          recentIncorrectCount: 3,
          currentDifficulty: Difficulty.medium,
        ),
      );
      expect(decision.activityType, ActivityType.revisionExercise);
      expect(decision.difficulty, Difficulty.easy);
    });

    test('demonstrated understanding raises the challenge', () async {
      final decision = await adaptive.decide(
        AdaptiveContext(
          diagnosis: const DiagnosisResult(
            concept: 'No error detected',
            errorCategory: 'none',
            confidence: 0.9,
          ),
          domain: 'mathematics',
          subject: 'mathematics_algebra',
          topic: 'mathematics_algebra_linear_equations',
          attemptedQuestionId: 'math_linear_eq_1',
          previousCorrect: true,
          attemptCountForTopic: 3,
          currentDifficulty: Difficulty.easy,
        ),
      );
      expect(decision.activityType, ActivityType.challengeQuestion);
      expect(decision.difficulty.level, greaterThan(Difficulty.easy.level));
    });

    test(
      'missing follow-up content does not crash (null next question)',
      () async {
        final emptyAdaptive = MockAdaptiveLearningService(
          questions: MockQuestionService.empty,
        );
        final decision = await emptyAdaptive.decide(
          const AdaptiveContext(
            diagnosis: DiagnosisScenarios.misconception,
            domain: 'mathematics',
            subject: 'mathematics_algebra',
            topic: 'mathematics_algebra_linear_equations',
          ),
        );
        expect(decision.nextQuestionId, isNull);
      },
    );

    test('throws when forced to fail', () {
      final failing = MockAdaptiveLearningService(shouldFail: true);
      expect(
        () => failing.decide(
          const AdaptiveContext(
            diagnosis: DiagnosisScenarios.misconception,
            domain: 'mathematics',
            subject: 'mathematics_algebra',
            topic: 'mathematics_algebra_linear_equations',
          ),
        ),
        throwsA(isA<AdaptiveServiceException>()),
      );
    });
  });

  group('MockLessonService', () {
    final service = MockLessonService();

    test('returns a verified lesson for the demo topics', () async {
      final lesson = await service.getLessonForTopic(
        'mathematics_algebra_linear_equations',
      );
      expect(lesson, isNotNull);
      expect(lesson!.sections, isNotEmpty);
      expect(lesson.workedExampleSteps, isNotEmpty);
    });

    test('resolves an explanation by id', () async {
      final explanation = await service.getExplanation(
        'exp_math_linear_simplified',
      );
      expect(explanation, isNotNull);
      expect(explanation!.isSimplified, isTrue);
    });

    test('falls back to a generic clarification question', () async {
      final text = await service.getClarificationQuestionText('missing-id');
      expect(text, isNotNull);
      expect(text, isNotEmpty);
    });
  });

  group('MockProgressService', () {
    test('records attempts and computes aggregates', () async {
      final service = MockProgressService();
      await service.recordAttempt(
        AttemptRecord(
          questionId: 'q1',
          domain: 'mathematics',
          subject: 'mathematics_algebra',
          topic: 'mathematics_algebra_linear_equations',
          learnerAnswer: 'x = 2',
          correctAnswer: 'x = 5',
          isCorrect: false,
          timestamp: DateTime(2026, 1, 1),
          errorCategory: 'sign_error',
        ),
      );
      await service.recordAttempt(
        AttemptRecord(
          questionId: 'q2',
          domain: 'mathematics',
          subject: 'mathematics_algebra',
          topic: 'mathematics_algebra_linear_equations',
          learnerAnswer: 'x = 5',
          correctAnswer: 'x = 5',
          isCorrect: true,
          timestamp: DateTime(2026, 1, 2),
        ),
      );

      final progress = await service.getProgress();
      expect(progress.totalAttempts, 2);
      expect(progress.correctAttempts, 1);
      expect(progress.incorrectAttempts, 1);
      expect(
        progress.repeatedMisconceptions.single.errorCategory,
        'sign_error',
      );
      expect(progress.topicProgress, hasLength(1));
    });

    test('attaches a diagnosis to the latest matching attempt', () async {
      final service = MockProgressService();
      await service.recordAttempt(
        AttemptRecord(
          questionId: 'q1',
          domain: 'mathematics',
          subject: 'mathematics_algebra',
          topic: 'mathematics_algebra_linear_equations',
          learnerAnswer: 'x = 2',
          correctAnswer: 'x = 5',
          isCorrect: false,
          timestamp: DateTime(2026, 1, 1),
        ),
      );
      final updated = await service.attachDiagnosis(
        questionId: 'q1',
        errorCategory: 'sign_error',
        concept: 'negative terms',
      );
      expect(updated.attempts.single.errorCategory, 'sign_error');
    });

    test('throws when forced to fail', () {
      final failing = MockProgressService(shouldFail: true);
      expect(
        () => failing.getProgress(),
        throwsA(isA<ProgressServiceException>()),
      );
    });
  });
}
