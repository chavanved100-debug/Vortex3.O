import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnloop_ai/app/app.dart';
import 'package:learnloop_ai/app/route_args.dart';
import 'package:learnloop_ai/app/services_scope.dart';
import 'package:learnloop_ai/data/mock_diagnosis_service.dart';
import 'package:learnloop_ai/data/mock_question_service.dart';
import 'package:learnloop_ai/data/mock_questions.dart';
import 'package:learnloop_ai/models/adaptive_decision.dart';
import 'package:learnloop_ai/models/diagnosis_result.dart';
import 'package:learnloop_ai/models/learning_progress.dart';
import 'package:learnloop_ai/models/question.dart';
import 'package:learnloop_ai/services/adaptive_learning_service.dart';

Question _q(String id) => QuestionBank.all.firstWhere((q) => q.id == id);

/// Adaptive service that always returns a fixed decision, used to exercise the
/// UI's missing-content fallbacks deterministically.
class _FixedAdaptiveService implements AdaptiveLearningService {
  _FixedAdaptiveService(this.decision);

  final AdaptiveDecision decision;

  @override
  Future<AdaptiveDecision> decide(AdaptiveContext context) async => decision;
}

Future<void> _pumpAdaptive(
  WidgetTester tester,
  AdaptiveArgs args, {
  AppServices? services,
}) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    LearnLoopApp(services: services ?? AppServices.mock()),
  );
  await tester.pumpAndSettle();
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed('/adaptive', arguments: args);
  await tester.pumpAndSettle();
}

Future<void> _pumpWithServices(
  WidgetTester tester,
  AdaptiveArgs args,
  AppServices services,
) => _pumpAdaptive(tester, args, services: services);

void main() {
  testWidgets('conceptual gap shows a simpler explanation and practice', (
    tester,
  ) async {
    await _pumpAdaptive(
      tester,
      AdaptiveArgs(
        question: _q('math_linear_eq_2'),
        learnerAnswer: 'x = 3',
        diagnosis: DiagnosisScenarios.misconception,
        currentDifficulty: Difficulty.medium,
      ),
    );
    expect(find.text('A targeted practice question'), findsOneWidget);
    expect(find.text('A simpler way to think about it'), findsOneWidget);
    expect(find.text('Your next question'), findsOneWidget);
  });

  testWidgets('careless slip shows a brief verification question', (
    tester,
  ) async {
    await _pumpAdaptive(
      tester,
      AdaptiveArgs(
        question: _q('math_linear_eq_2'),
        learnerAnswer: 'x = 2',
        diagnosis: DiagnosisScenarios.carelessSlip,
      ),
    );
    expect(find.text('A targeted practice question'), findsOneWidget);
    expect(find.text('Your next question'), findsOneWidget);
  });

  testWidgets('uncertain diagnosis follows the clarification path', (
    tester,
  ) async {
    await _pumpAdaptive(
      tester,
      AdaptiveArgs(
        question: _q('math_linear_eq_1'),
        learnerAnswer: 'x = 999',
        diagnosis: DiagnosisScenarios.uncertain,
      ),
    );
    expect(find.text('One quick clarification first'), findsOneWidget);
    expect(find.text('Your next question'), findsNothing);
  });

  testWidgets('repeated errors lead to a revision activity', (tester) async {
    await _pumpAdaptive(
      tester,
      AdaptiveArgs(
        question: _q('python_loops_2'),
        learnerAnswer: '4',
        diagnosis: DiagnosisScenarios.misconception,
        recentIncorrectCount: 3,
        currentDifficulty: Difficulty.medium,
      ),
    );
    expect(find.text('A revision exercise'), findsOneWidget);
  });

  testWidgets('demonstrated understanding raises the challenge', (
    tester,
  ) async {
    await _pumpAdaptive(
      tester,
      AdaptiveArgs(
        question: _q('math_linear_eq_1'),
        learnerAnswer: 'x = 5',
        diagnosis: const DiagnosisResult(
          concept: 'No error detected',
          errorCategory: 'none',
          confidence: 0.9,
        ),
        attemptCountForTopic: 3,
        currentDifficulty: Difficulty.easy,
        previousCorrect: true,
      ),
    );
    expect(find.text('A more challenging question'), findsOneWidget);
    expect(find.textContaining('not proof of mastery'), findsOneWidget);
  });

  testWidgets('missing referenced content shows a safe fallback', (
    tester,
  ) async {
    final services = AppServices(
      questions: MockQuestionService.empty,
      adaptiveOverride: _FixedAdaptiveService(
        const AdaptiveDecision(
          explanationId: 'missing_explanation',
          activityType: ActivityType.targetedPractice,
          nextQuestionId: 'missing_question',
        ),
      ),
    );
    await _pumpWithServices(
      tester,
      AdaptiveArgs(
        question: _q('math_linear_eq_1'),
        learnerAnswer: 'x = 2',
        diagnosis: DiagnosisScenarios.misconception,
      ),
      services,
    );
    expect(find.text('Explanation unavailable'), findsOneWidget);
    expect(find.text('Follow-up unavailable'), findsOneWidget);
    expect(find.text('Practice another question'), findsOneWidget);
  });

  testWidgets('starting the follow-up preserves the topic context', (
    tester,
  ) async {
    await _pumpAdaptive(
      tester,
      AdaptiveArgs(
        question: _q('math_linear_eq_2'),
        learnerAnswer: 'x = 3',
        diagnosis: DiagnosisScenarios.misconception,
        currentDifficulty: Difficulty.medium,
      ),
    );
    await tester.tap(find.text('Start this question'));
    await tester.pumpAndSettle();
    // Quiz opens on the same topic, preserving domain/subject/topic.
    expect(find.text('Linear Equations'), findsOneWidget);
    expect(find.text('Submit answer'), findsOneWidget);
  });
}
