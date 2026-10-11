import '../models/learning_progress.dart';
import '../services/progress_service.dart';
import '../utils/service_exceptions.dart';

/// In-memory progress service. Persistence is owned by Member 4; this mock
/// keeps the same interface so the UI can be developed and tested offline.
class MockProgressService implements ProgressService {
  MockProgressService({LearningProgress? initial, this.shouldFail = false})
    : _progress = initial ?? const LearningProgress();

  LearningProgress _progress;

  /// When true every call throws [ProgressServiceException].
  final bool shouldFail;

  @override
  Future<LearningProgress> getProgress() async {
    _maybeFail();
    return _progress;
  }

  @override
  Future<LearningProgress> recordAttempt(AttemptRecord attempt) async {
    _maybeFail();
    _progress = _progress.copyWith(attempts: [..._progress.attempts, attempt]);
    return _progress;
  }

  @override
  Future<LearningProgress> attachDiagnosis({
    required String questionId,
    required String errorCategory,
    String? concept,
  }) async {
    _maybeFail();
    final attempts = [..._progress.attempts];
    for (var i = attempts.length - 1; i >= 0; i--) {
      if (attempts[i].questionId == questionId &&
          attempts[i].errorCategory == null) {
        attempts[i] = attempts[i].copyWith(
          errorCategory: errorCategory,
          concept: concept,
        );
        break;
      }
    }
    _progress = _progress.copyWith(attempts: attempts);
    return _progress;
  }

  @override
  Future<void> clear() async {
    _maybeFail();
    _progress = const LearningProgress();
  }

  void _maybeFail() {
    if (shouldFail) {
      throw const ProgressServiceException(
        'Progress is unavailable right now.',
      );
    }
  }
}
