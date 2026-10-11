import '../models/learning_progress.dart';

/// Persistence interface for learner progress. Persistence is owned by
/// Member 4; the UI only depends on this interface.
///
/// The mock implementation is in-memory. A real implementation must keep the
/// same method signatures and preserve [LearningProgress] backward
/// compatibility (new fields optional with defaults).
abstract class ProgressService {
  /// Returns the current aggregated progress.
  Future<LearningProgress> getProgress();

  /// Records a completed attempt and returns the updated progress.
  Future<LearningProgress> recordAttempt(AttemptRecord attempt);

  /// Updates the diagnosis fields of the most recent matching attempt.
  Future<LearningProgress> attachDiagnosis({
    required String questionId,
    required String errorCategory,
    String? concept,
  });

  /// Clears all recorded progress.
  Future<void> clear();
}
