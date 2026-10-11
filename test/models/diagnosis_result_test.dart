import 'package:flutter_test/flutter_test.dart';
import 'package:learnloop_ai/models/diagnosis_result.dart';

void main() {
  group('DiagnosisResult', () {
    test('clamps confidence into the 0..1 range', () {
      expect(
        const DiagnosisResult(
          concept: 'c',
          errorCategory: 'x',
          confidence: 1.5,
        ).safeConfidence,
        1.0,
      );
      expect(
        const DiagnosisResult(
          concept: 'c',
          errorCategory: 'x',
          confidence: -2,
        ).safeConfidence,
        0.0,
      );
    });

    test('is never definitive when clarification is required', () {
      const result = DiagnosisResult(
        concept: 'unclear',
        errorCategory: 'unknown',
        confidence: 0.95,
        needsClarification: true,
      );
      expect(result.isDefinitive, isFalse);
    });

    test('maps unknown categories to a supportive label', () {
      expect(
        errorCategoryLabel('novel_error_xyz'),
        'Something specific we are still uncovering',
      );
      expect(errorCategoryLabel('sign_error'), 'Sign or direction error');
      expect(errorCategoryLabel(null), 'Unclear at the moment');
    });

    test('round-trips through JSON', () {
      const result = DiagnosisResult(
        concept: 'distribution',
        errorCategory: 'conceptual_gap',
        evidence: ['expanded 5(x-2) as 5x-2'],
        confidence: 0.8,
        recommendedHintId: 'hint_math_distribute',
      );
      final restored = DiagnosisResult.fromJson(result.toJson());
      expect(restored.concept, result.concept);
      expect(restored.errorCategory, result.errorCategory);
      expect(restored.evidence, result.evidence);
      expect(restored.confidence, closeTo(0.8, 0.0001));
      expect(restored.recommendedHintId, 'hint_math_distribute');
    });

    test('confidenceLevel reflects the confidence band', () {
      expect(
        const DiagnosisResult(
          concept: 'c',
          errorCategory: 'x',
          confidence: 0.9,
        ).confidenceLevel,
        ConfidenceLevel.high,
      );
      expect(
        const DiagnosisResult(
          concept: 'c',
          errorCategory: 'x',
          confidence: 0.0,
        ).confidenceLevel,
        ConfidenceLevel.none,
      );
    });
  });
}
