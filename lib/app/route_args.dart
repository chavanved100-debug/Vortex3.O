import '../models/diagnosis_result.dart';
import '../models/learning_topic.dart';
import '../models/question.dart';

/// Navigation arguments for the quiz route.
class QuizArgs {
  const QuizArgs({
    required this.topic,
    this.questionIds,
    this.isFollowUp = false,
  });

  final LearningTopic topic;

  /// Optional explicit question id order. When null the quiz uses all
  /// questions for [topic].
  final List<String>? questionIds;

  /// True when this quiz was launched as an adaptive follow-up activity, so the
  /// attempt is recorded as a follow-up.
  final bool isFollowUp;
}

/// Navigation arguments for the Wrong Answer Detective route.
class DetectiveArgs {
  const DetectiveArgs({
    required this.question,
    required this.learnerAnswer,
    this.isFollowUp = false,
  });

  final Question question;
  final String learnerAnswer;
  final bool isFollowUp;
}

/// Navigation arguments for the adaptive follow-up route.
class AdaptiveArgs {
  const AdaptiveArgs({
    required this.question,
    required this.learnerAnswer,
    required this.diagnosis,
    this.attemptCountForTopic = 0,
    this.recentIncorrectCount = 0,
    this.currentDifficulty = Difficulty.medium,
    this.previousCorrect = false,
  });

  final Question question;
  final String learnerAnswer;
  final DiagnosisResult diagnosis;
  final int attemptCountForTopic;
  final int recentIncorrectCount;
  final Difficulty currentDifficulty;
  final bool previousCorrect;
}
