import '../models/adaptive_decision.dart';
import '../models/learning_progress.dart';

/// Interface for adaptive follow-up decisions. Owned by Member 3.
///
/// A real implementation must implement [decide] with this exact signature:
///   `Future<AdaptiveDecision> decide(AdaptiveContext context)`
/// The UI renders the returned decision and must not contain subject-specific
/// decision rules.
abstract class AdaptiveLearningService {
  Future<AdaptiveDecision> decide(AdaptiveContext context);
}
