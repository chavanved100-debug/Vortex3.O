import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnloop_ai/app/app.dart';
import 'package:learnloop_ai/app/route_args.dart';
import 'package:learnloop_ai/app/services_scope.dart';
import 'package:learnloop_ai/data/learning_catalog.dart';
import 'package:learnloop_ai/data/mock_progress_service.dart';
import 'package:learnloop_ai/data/mock_question_service.dart';
import 'package:learnloop_ai/models/learning_topic.dart';

final LearningTopic _linearTopic = LearningCatalog.instance.topicById(
  'mathematics_algebra_linear_equations',
)!;

Future<void> _pumpApp(WidgetTester tester, {AppServices? services}) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    LearnLoopApp(services: services ?? AppServices.mock()),
  );
  await tester.pumpAndSettle();
}

Future<void> _pushQuiz(WidgetTester tester, {QuizArgs? args}) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed(
    '/quiz',
    arguments: args ?? QuizArgs(topic: _linearTopic),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lesson to quiz navigation', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Mathematics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Linear Equations'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Start quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Solve for x:  2x - 3 = 7'), findsOneWidget);
    expect(find.text('Submit answer'), findsOneWidget);
  });

  testWidgets('selecting an option and submitting records one attempt', (
    tester,
  ) async {
    final progress = MockProgressService();
    await _pumpApp(tester, services: AppServices(progress: progress));
    await _pushQuiz(tester);

    await tester.tap(find.text('x = 5'));
    await tester.pump();
    await tester.tap(find.text('Submit answer'));
    await tester.pumpAndSettle();

    // Tapping again must not create a second attempt (button is gone).
    expect(find.text('Submit answer'), findsNothing);
    final data = await progress.getProgress();
    expect(data.totalAttempts, 1);
  });

  testWidgets('correct answer shows correct feedback', (tester) async {
    await _pumpApp(tester);
    await _pushQuiz(tester);
    await tester.tap(find.text('x = 5'));
    await tester.pump();
    await tester.tap(find.text('Submit answer'));
    await tester.pumpAndSettle();

    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('Verified answer: x = 5'), findsOneWidget);
    expect(find.text('See suggested next step'), findsOneWidget);
  });

  testWidgets('incorrect answer shows incorrect feedback and detective route', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _pushQuiz(tester);
    await tester.tap(find.text('x = 2'));
    await tester.pump();
    await tester.tap(find.text('Submit answer'));
    await tester.pumpAndSettle();

    expect(find.text('Not quite'), findsOneWidget);
    expect(find.text('Verified answer: x = 5'), findsOneWidget);

    await tester.tap(find.text('Open the Detective'));
    await tester.pumpAndSettle();
    expect(find.text('Wrong Answer Detective'), findsOneWidget);
  });

  testWidgets('empty question bank shows an empty state', (tester) async {
    await _pumpApp(
      tester,
      services: AppServices(questions: MockQuestionService.empty),
    );
    await _pushQuiz(tester);
    expect(find.text('No questions yet'), findsOneWidget);
  });

  testWidgets('question service error shows an error state', (tester) async {
    await _pumpApp(
      tester,
      services: AppServices(questions: MockQuestionService(shouldFail: true)),
    );
    await _pushQuiz(tester);
    expect(find.text('Questions unavailable'), findsOneWidget);
  });
}
