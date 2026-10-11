import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnloop_ai/app/app.dart';
import 'package:learnloop_ai/models/learning_domain.dart';

Future<void> _pumpHome(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const LearnLoopApp());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('all seven domains are shown on the home screen', (tester) async {
    await _pumpHome(tester);
    for (final domain in LearningDomain.values) {
      expect(
        find.text(domain.label),
        findsWidgets,
        reason: '${domain.label} should be visible on the home screen',
      );
    }
  });

  testWidgets('selecting Mathematics shows its subjects', (tester) async {
    await _pumpHome(tester);
    await tester.tap(find.text('Mathematics'));
    await tester.pumpAndSettle();

    expect(find.text('Algebra'), findsOneWidget);
    expect(find.text('Calculus'), findsOneWidget);
    expect(find.text('Probability and Statistics'), findsOneWidget);
  });

  testWidgets('selecting Algebra shows its topics', (tester) async {
    await _pumpHome(tester);
    await tester.tap(find.text('Mathematics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    expect(find.text('Linear Equations'), findsOneWidget);
    expect(find.text('Quadratic Equations'), findsOneWidget);
  });

  testWidgets('navigation preserves the selected topic into the lesson', (
    tester,
  ) async {
    await _pumpHome(tester);
    await tester.tap(find.text('Mathematics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Linear Equations'));
    await tester.pumpAndSettle();

    // The lesson screen shows the selected topic and its objective.
    expect(find.text('Linear Equations'), findsWidgets);
    expect(find.text('Start quiz'), findsOneWidget);
    expect(find.text('Learning objective'), findsOneWidget);
    expect(
      find.textContaining('single-variable linear equations'),
      findsWidgets,
    );
  });

  testWidgets('Python demo path opens the loops topic', (tester) async {
    await _pumpHome(tester);
    // Recommended demo card for Python.
    await tester.tap(find.text('Loops and Range'));
    await tester.pumpAndSettle();

    expect(find.text('Loops and Range'), findsWidgets);
    expect(find.text('Start quiz'), findsOneWidget);
  });

  testWidgets('unknown route shows a safe placeholder', (tester) async {
    await tester.pumpWidget(const LearnLoopApp());
    await tester.pumpAndSettle();
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/totally-unknown');
    await tester.pumpAndSettle();
    expect(find.text('Not available yet'), findsWidgets);
  });
}
