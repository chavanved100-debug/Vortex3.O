import 'package:flutter_test/flutter_test.dart';
import 'package:learnloop_ai/models/question.dart';

void main() {
  group('Question', () {
    const question = Question(
      id: 'q1',
      domain: 'mathematics',
      subject: 'mathematics_algebra',
      topic: 'mathematics_algebra_linear_equations',
      prompt: 'Solve 2x - 3 = 7',
      options: ['x = 2', 'x = 5', 'x = 10', 'x = 4'],
      correctAnswer: 'x = 5',
      explanation: 'Add 3, then divide by 2.',
      hints: ['undo subtraction first'],
      followUpIds: ['q2'],
      difficulty: Difficulty.easy,
      misconceptionRules: [
        MisconceptionRule(
          id: 'r1',
          errorCategory: 'sign_error',
          concept: 'negative terms',
          triggerAnswers: ['x = 2'],
        ),
      ],
    );

    test('identifies correct answers case-insensitively', () {
      expect(question.isCorrect('x = 5'), isTrue);
      expect(question.isCorrect('  X = 5 '), isTrue);
      expect(question.isCorrect('x = 2'), isFalse);
    });

    test('round-trips through JSON preserving fields', () {
      final restored = Question.fromJson(question.toJson());
      expect(restored.id, question.id);
      expect(restored.domain, question.domain);
      expect(restored.topic, question.topic);
      expect(restored.options, question.options);
      expect(restored.correctAnswer, question.correctAnswer);
      expect(restored.difficulty, Difficulty.easy);
      expect(restored.type, QuestionType.multipleChoice);
      expect(restored.misconceptionRules.single.errorCategory, 'sign_error');
      expect(restored.followUpIds, ['q2']);
    });

    test('falls back to safe defaults for malformed JSON', () {
      final restored = Question.fromJson(const {
        'id': 'x',
        'type': 'not-a-real-type',
        'difficulty': 'impossible',
      });
      expect(restored.type, QuestionType.multipleChoice);
      expect(restored.difficulty, Difficulty.medium);
      expect(restored.options, isEmpty);
      expect(restored.misconceptionRules, isEmpty);
    });

    test('difficulty ordering walks up and down', () {
      expect(Difficulty.easy.harder, Difficulty.medium);
      expect(Difficulty.easy.easier, Difficulty.easy);
      expect(Difficulty.challenge.harder, Difficulty.challenge);
    });
  });
}
