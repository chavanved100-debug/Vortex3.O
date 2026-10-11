import 'package:flutter/widgets.dart';

import '../data/mock_adaptive_learning_service.dart';
import '../data/mock_diagnosis_service.dart';
import '../data/mock_lesson_service.dart';
import '../data/mock_progress_service.dart';
import '../data/mock_question_service.dart';
import '../services/adaptive_learning_service.dart';
import '../services/diagnosis_service.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import '../services/question_service.dart';

/// Lightweight dependency container. Screens read the interfaces from here, so
/// the mock implementations can be swapped for real ones without touching UI.
class AppServices {
  AppServices({
    QuestionService? questions,
    DiagnosisService? diagnosis,
    this.adaptiveOverride,
    LessonService? lesson,
    ProgressService? progress,
  }) : questions = questions ?? MockQuestionService(),
       diagnosis = diagnosis ?? MockDiagnosisService(),
       lesson = lesson ?? MockLessonService(),
       progress = progress ?? MockProgressService();

  final QuestionService questions;
  final DiagnosisService diagnosis;
  final LessonService lesson;
  final ProgressService progress;

  /// Optional override for the adaptive service.
  final AdaptiveLearningService? adaptiveOverride;

  /// The adaptive service, defaulting to a mock wired to [questions].
  AdaptiveLearningService get adaptive =>
      adaptiveOverride ?? MockAdaptiveLearningService(questions: questions);

  /// Standard offline wiring using only mock services.
  factory AppServices.mock() => AppServices();
}

/// Provides [AppServices] to the widget tree via an [InheritedWidget].
class ServicesScope extends InheritedWidget {
  const ServicesScope({
    super.key,
    required this.services,
    required super.child,
  });

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ServicesScope>();
    assert(scope != null, 'ServicesScope was not found in the widget tree.');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(ServicesScope oldWidget) =>
      oldWidget.services != services;
}
