/// Base error type for recoverable service failures. The UI catches these to
/// show friendly error states instead of crashing.
class ServiceException implements Exception {
  const ServiceException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'ServiceException: $message';
}

/// Thrown when the diagnosis service cannot complete a request.
class DiagnosisServiceException extends ServiceException {
  const DiagnosisServiceException(super.message, {super.cause});
}

/// Thrown when question retrieval fails.
class QuestionServiceException extends ServiceException {
  const QuestionServiceException(super.message, {super.cause});
}

/// Thrown when the adaptive service cannot produce a decision.
class AdaptiveServiceException extends ServiceException {
  const AdaptiveServiceException(super.message, {super.cause});
}

/// Thrown when progress persistence fails.
class ProgressServiceException extends ServiceException {
  const ProgressServiceException(super.message, {super.cause});
}

/// Thrown when referenced local content (lesson, explanation, follow-up
/// question) cannot be found. Callers should present a safe fallback.
class ContentNotFoundException extends ServiceException {
  const ContentNotFoundException(super.message, {super.cause});
}
