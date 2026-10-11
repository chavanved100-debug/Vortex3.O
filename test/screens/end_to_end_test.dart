import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnloop_ai/app/app.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const LearnLoopApp());
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

/// Walks home → Mathematics → Algebra → Linear Equations → Start quiz.
Future<void> _openLinearQuiz(WidgetTester tester) async {
  await _pumpApp(tester);
  await _tap(tester, 'Mathematics');
  await _tap(tester, 'Algebra');
  await _tap(tester, 'Linear Equations');
  await tester.tap(find.widgetWithText(FilledButton, 'Start quiz'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('wrong answer flows lesson → quiz → detective → adaptive', (
    tester,
  ) async {
    await _openLinearQuiz(tester);

    // Quiz: a known sign error is diagnosed.
    await _tap(tester, 'x = 2');
    await _tap(tester, 'Submit answer');
    expect(find.text('Not quite'), findsOneWidget);
    await _tap(tester, 'Open the Detective');

    // Detective: shows a likely cause (not a certainty) plus a targeted hint.
    expect(find.text('Wrong Answer Detective'), findsOneWidget);
    expect(find.text('What may have gone wrong?'), findsOneWidget);
    expect(find.text('Sign or direction error'), findsOneWidget);
    expect(find.text('Targeted hint'), findsOneWidget);
    await _tap(tester, 'See the suggested next step');

    // Adaptive: a concrete follow-up question is offered.
    expect(find.text('Your next step'), findsOneWidget);
    expect(find.text('Your next question'), findsOneWidget);
  });

  testWidgets('correct answer flows quiz → adaptive with a cautious note', (
    tester,
  ) async {
    await _openLinearQuiz(tester);

    await _tap(tester, 'x = 5');
    await _tap(tester, 'Submit answer');
    expect(find.text('Correct'), findsOneWidget);
    await _tap(tester, 'See suggested next step');

    expect(find.text('Your next step'), findsOneWidget);
    expect(find.text('A more challenging question'), findsOneWidget);
    expect(find.textContaining('not proof of mastery'), findsOneWidget);
  });

  testWidgets('a topic without content stays friendly and never crashes', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _tap(tester, 'Mathematics');
    await _tap(tester, 'Calculus');
    // Topics without curated content are clearly marked in the list.
    expect(find.text('Content coming soon'), findsWidgets);
    await _tap(tester, 'Limits');
    expect(find.textContaining('is coming soon'), findsOneWidget);
  });
}
