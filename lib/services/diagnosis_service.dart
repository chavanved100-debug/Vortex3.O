import '../models/diagnosis_result.dart';
import '../models/learning_progress.dart';

/// Interface for wrong-answer diagnosis. Owned by Member 2.
///
/// A real implementation must implement [diagnose] with this exact signature:
///   `Future<DiagnosisResult> diagnose(DiagnosisRequest request)`
/// where [DiagnosisRequest] carries the question, the learner answer, prior
/// attempts and any clarification response. A wrong final answer alone must NOT
/// be treated as proof of a specific misconception: return
/// `needsClarification = true` when more information is required.
abstract class DiagnosisService {
  Future<DiagnosisResult> diagnose(DiagnosisRequest request);
}
