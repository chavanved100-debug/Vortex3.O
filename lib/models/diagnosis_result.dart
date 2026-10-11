/// Shared diagnosis contract owned by Member 2.
///
/// Field names match the team agreement exactly:
/// concept, errorCategory, evidence, confidence, needsClarification,
/// clarificationQuestionId, recommendedHintId.
///
/// `errorCategory` is intentionally a free-form [String] so the real ML service
/// can introduce new categories without a schema change. Unknown categories are
/// rendered gracefully by the UI through [errorCategoryLabel].
class DiagnosisResult {
  const DiagnosisResult({
    required this.concept,
    required this.errorCategory,
    this.evidence = const [],
    this.confidence = 0,
    this.needsClarification = false,
    this.clarificationQuestionId,
    this.recommendedHintId,
  });

  /// The concept the learner may be struggling with.
  final String concept;

  /// Category of the suspected error (for example `sign_error`,
  /// `boundary_error`, `unknown`). Free-form to stay forward compatible.
  final String errorCategory;

  /// Concrete evidence supporting the inference (answers, steps, patterns).
  final List<String> evidence;

  /// Confidence in the range 0.0 – 1.0. Values outside the range are clamped.
  final double confidence;

  /// When true the service cannot yet commit to a specific misconception and a
  /// clarification question must be asked first.
  final bool needsClarification;

  /// Id of the clarification question to ask (required when
  /// [needsClarification] is true).
  final String? clarificationQuestionId;

  /// Id of the targeted hint to recommend, when available.
  final String? recommendedHintId;

  /// Confidence clamped to a valid 0.0 – 1.0 range.
  double get safeConfidence => confidence.clamp(0.0, 1.0);

  /// A coarse band used to phrase confidence in learner-friendly language.
  ConfidenceLevel get confidenceLevel {
    final value = safeConfidence;
    if (value >= 0.75) return ConfidenceLevel.high;
    if (value >= 0.45) return ConfidenceLevel.medium;
    if (value > 0) return ConfidenceLevel.low;
    return ConfidenceLevel.none;
  }

  /// True when the diagnosis is definitive enough to show as a likely cause.
  /// Uncertain results must never be presented as confirmed.
  bool get isDefinitive => !needsClarification && safeConfidence >= 0.45;

  DiagnosisResult copyWith({
    String? concept,
    String? errorCategory,
    List<String>? evidence,
    double? confidence,
    bool? needsClarification,
    String? clarificationQuestionId,
    String? recommendedHintId,
  }) {
    return DiagnosisResult(
      concept: concept ?? this.concept,
      errorCategory: errorCategory ?? this.errorCategory,
      evidence: evidence ?? this.evidence,
      confidence: confidence ?? this.confidence,
      needsClarification: needsClarification ?? this.needsClarification,
      clarificationQuestionId:
          clarificationQuestionId ?? this.clarificationQuestionId,
      recommendedHintId: recommendedHintId ?? this.recommendedHintId,
    );
  }

  Map<String, dynamic> toJson() => {
    'concept': concept,
    'errorCategory': errorCategory,
    'evidence': evidence,
    'confidence': confidence,
    'needsClarification': needsClarification,
    'clarificationQuestionId': clarificationQuestionId,
    'recommendedHintId': recommendedHintId,
  };

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    final rawConfidence = json['confidence'];
    final confidence = rawConfidence is num
        ? rawConfidence.toDouble()
        : double.tryParse(rawConfidence?.toString() ?? '') ?? 0;
    return DiagnosisResult(
      concept: json['concept'] as String? ?? '',
      errorCategory: json['errorCategory'] as String? ?? 'unknown',
      evidence: (json['evidence'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      confidence: confidence,
      needsClarification: json['needsClarification'] as bool? ?? false,
      clarificationQuestionId: json['clarificationQuestionId'] as String?,
      recommendedHintId: json['recommendedHintId'] as String?,
    );
  }

  @override
  String toString() =>
      'DiagnosisResult($concept, $errorCategory, ${safeConfidence.toStringAsFixed(2)})';
}

/// Coarse confidence bands for human-readable presentation.
enum ConfidenceLevel {
  none('Not enough evidence yet'),
  low('Low confidence'),
  medium('Moderate confidence'),
  high('High confidence');

  const ConfidenceLevel(this.label);

  final String label;
}

/// Human-readable labels for the known error categories. Unknown categories
/// fall back to a neutral, non-blaming phrase.
const Map<String, String> knownErrorCategoryLabels = {
  'sign_error': 'Sign or direction error',
  'calculation_slip': 'Careless calculation slip',
  'careless_slip': 'Careless slip',
  'boundary_error': 'Range or boundary error',
  'conceptual_gap': 'Conceptual misunderstanding',
  'misread_question': 'Misread the question',
  'incomplete_reasoning': 'Incomplete reasoning',
  'unit_error': 'Unit or notation error',
  'unknown': 'Unclear at the moment',
};

/// Maps an [errorCategory] string to a supportive, learner-friendly label.
String errorCategoryLabel(String? errorCategory) {
  if (errorCategory == null || errorCategory.isEmpty) {
    return knownErrorCategoryLabels['unknown']!;
  }
  return knownErrorCategoryLabels[errorCategory] ??
      'Something specific we are still uncovering';
}
