import 'package:flutter_test/flutter_test.dart';
import 'package:learnloop_ai/app/app.dart';

void main() {
  testWidgets('app boots and shows LearnLoop AI branding', (tester) async {
    await tester.pumpWidget(const LearnLoopApp());
    expect(find.text('LearnLoop AI'), findsWidgets);
  });
}
