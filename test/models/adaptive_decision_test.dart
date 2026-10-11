import 'package:flutter_test/flutter_test.dart';
import 'package:learnloop_ai/models/adaptive_decision.dart';
import 'package:learnloop_ai/models/question.dart';

void main() {
  group('AdaptiveDecision', () {
    test('round-trips through JSON', () {
      const decision = AdaptiveDecision(
        explanationId: 'exp_math_linear_simplified',
        activityType: ActivityType.targetedPractice,
        nextQuestionId: 'math_linear_eq_1_easier',
        difficulty: Difficulty.easy,
      );
      final restored = AdaptiveDecision.fromJson(decision.toJson());
      expect(restored.explanationId, 'exp_math_linear_simplified');
      expect(restored.activityType, ActivityType.targetedPractice);
      expect(restored.nextQuestionId, 'math_linear_eq_1_easier');
      expect(restored.difficulty, Difficulty.easy);
    });

    test('unknown activity types fall back safely', () {
      final restored = AdaptiveDecision.fromJson(const {
        'activityType': 'teleportation',
      });
      expect(restored.activityType, ActivityType.unknown);
      expect(restored.nextQuestionId, isNull);
    });
  });
}
