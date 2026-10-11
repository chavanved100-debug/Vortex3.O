import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnloop_ai/app/app.dart';
import 'package:learnloop_ai/app/route_args.dart';
import 'package:learnloop_ai/app/services_scope.dart';
import 'package:learnloop_ai/data/mock_diagnosis_service.dart';
import 'package:learnloop_ai/data/mock_questions.dart';
import 'package:learnloop_ai/models/question.dart';

Question _questionById(String id) =>
    QuestionBank.all.firstWhere((q) => q.id == id);

Future<void> _pumpDetective(
  WidgetTester tester, {
  required Question question,
  required String answer,
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
  navigator.pushNamed(
    '/detective',
    arguments: DetectiveArgs(question: question, learnerAnswer: answer),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('likely misconception shows evidence and confidence', (
    tester,
  ) async {
    await _pumpDetective(
      tester,
      question: _questionById('math_linear_eq_2'),
      answer: 'x = 3',
      services: AppServices(
        diagnosis: MockDiagnosisService(
          forcedResult: DiagnosisScenarios.misconception,
        ),
      ),
    );
    expect(find.text('What may have gone wrong?'), findsOneWidget);
    expect(find.textContaining('Distributing a factor'), findsWidgets);
    expect(find.text('Confidence'), findsOneWidget);
    expect(find.text('High confidence'), findsOneWidget);
    expect(find.text('Certain:'), findsNothing); // exact note is longer
    expect(find.textContaining('Certain:'), findsOneWidget);
  });

  testWidgets('careless slip is presented without blame', (tester) async {
    await _pumpDetective(
      tester,
      question: _questionById('math_linear_eq_2'),
      answer: 'x = 2',
      services: AppServices(
        diagnosis: MockDiagnosisService(
          forcedResult: DiagnosisScenarios.carelessSlip,
        ),
      ),
    );
    expect(find.text('Careless calculation slip'), findsOneWidget);
    expect(find.text('Not available yet'), findsNothing);
  });

  testWidgets('uncertain diagnosis never appears as confirmed', (tester) async {
    await _pumpDetective(
      tester,
      question: _questionById('math_linear_eq_1'),
      answer: 'x = 999',
      services: AppServices(
        diagnosis: MockDiagnosisService(
          forcedResult: DiagnosisScenarios.uncertain,
        ),
      ),
    );
    // A clarification is requested and no definitive misconception card shown.
    expect(find.text('A quick question before we guess'), findsOneWidget);
    expect(find.text('What may have gone wrong?'), findsNothing);
    expect(find.text('Submit response'), findsOneWidget);
  });

  testWidgets('unknown error category is handled gracefully', (tester) async {
    await _pumpDetective(
      tester,
      question: _questionById('math_linear_eq_1'),
      answer: 'x = 4',
      services: AppServices(
        diagnosis: MockDiagnosisService(
          forcedResult: DiagnosisScenarios.unknownCategory,
        ),
      ),
    );
    expect(find.textContaining('still uncovering'), findsWidgets);
  });

  testWidgets('diagnosis service failure shows an error state', (tester) async {
    await _pumpDetective(
      tester,
      question: _questionById('math_linear_eq_1'),
      answer: 'x = 2',
      services: AppServices(diagnosis: MockDiagnosisService(shouldFail: true)),
    );
    expect(find.text('Detective unavailable'), findsOneWidget);
  });

  testWidgets('clarification can be submitted and refines the diagnosis', (
    tester,
  ) async {
    await _pumpDetective(
      tester,
      question: _questionById('python_loops_1'),
      answer: '99',
    );
    expect(find.text('A quick question before we guess'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'I started at 1');
    await tester.tap(find.text('Submit response'));
    await tester.pumpAndSettle();

    // Updated, definitive diagnosis replaces the clarification card.
    expect(find.text('What may have gone wrong?'), findsOneWidget);
    expect(find.textContaining('range()'), findsWidgets);
  });
}
