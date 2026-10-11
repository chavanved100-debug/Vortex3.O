import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnloop_ai/app/app.dart';
import 'package:learnloop_ai/app/services_scope.dart';
import 'package:learnloop_ai/data/mock_progress_service.dart';
import 'package:learnloop_ai/models/learning_progress.dart';

const String _linearTopic = 'mathematics_algebra_linear_equations';

AttemptRecord _attempt({
  required String id,
  required bool correct,
  String? category,
  String? concept,
  DateTime? at,
  String topic = _linearTopic,
  bool wasFollowUp = false,
}) {
  return AttemptRecord(
    questionId: id,
    domain: 'mathematics',
    subject: 'mathematics_algebra',
    topic: topic,
    learnerAnswer: 'x',
    correctAnswer: 'y',
    isCorrect: correct,
    timestamp: at ?? DateTime(2026, 10, 11, 10, 0),
    errorCategory: category,
    concept: concept,
    wasFollowUp: wasFollowUp,
  );
}

Future<void> _openDashboard(WidgetTester tester, AppServices services) async {
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(LearnLoopApp(services: services));
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/dashboard');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty progress shows an encouraging empty state', (
    tester,
  ) async {
    await _openDashboard(tester, AppServices(progress: MockProgressService()));
    expect(find.text('No learning activity yet'), findsOneWidget);
    expect(find.textContaining('Offline-first'), findsOneWidget);
  });

  testWidgets('recorded activity is summarised honestly', (tester) async {
    final progress = MockProgressService(
      initial: LearningProgress(
        attempts: [
          _attempt(id: 'q1', correct: true),
          _attempt(
            id: 'q2',
            correct: false,
            category: 'conceptual_gap',
            concept: 'Balancing both sides',
          ),
          _attempt(
            id: 'q3',
            correct: false,
            category: 'conceptual_gap',
            concept: 'Balancing both sides',
            wasFollowUp: true,
          ),
        ],
      ),
    );
    await _openDashboard(tester, AppServices(progress: progress));

    expect(find.text('3'), findsOneWidget); // Attempted
    expect(find.text('33%'), findsOneWidget); // Accuracy
    expect(find.text('Conceptual misunderstanding'), findsOneWidget);
    // Topic progress, revision and session tiles all name the topic.
    expect(find.text('Linear Equations'), findsWidgets);
    expect(find.textContaining('not proof'), findsOneWidget);
  });

  testWidgets('pre/post comparison shows sample size and a causality note', (
    tester,
  ) async {
    final progress = MockProgressService(
      initial: LearningProgress(
        attempts: [_attempt(id: 'q1', correct: true)],
        prePost: const AssessmentComparison(
          preScore: 0.4,
          postScore: 0.7,
          sampleSize: 10,
        ),
      ),
    );
    await _openDashboard(tester, AppServices(progress: progress));

    expect(find.text('Pre-test'), findsOneWidget);
    expect(find.text('Post-test'), findsOneWidget);
    expect(find.text('Change: +30%'), findsOneWidget);
    expect(find.text('Based on 10 items.'), findsOneWidget);
    expect(
      find.textContaining('prove that LearnLoop AI caused'),
      findsOneWidget,
    );
  });

  testWidgets('progress service failure shows a recoverable error', (
    tester,
  ) async {
    await _openDashboard(
      tester,
      AppServices(progress: MockProgressService(shouldFail: true)),
    );
    expect(find.text('Progress unavailable'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('refresh reflects newly recorded attempts', (tester) async {
    final progress = MockProgressService();
    await _openDashboard(tester, AppServices(progress: progress));
    expect(find.text('No learning activity yet'), findsOneWidget);

    await progress.recordAttempt(_attempt(id: 'q1', correct: true));
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(find.text('No learning activity yet'), findsNothing);
    expect(find.text('100%'), findsOneWidget); // Accuracy after one correct
  });
}
