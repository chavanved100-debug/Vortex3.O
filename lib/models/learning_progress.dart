import 'diagnosis_result.dart';
import 'question.dart';

/// Mastery bands derived from accumulated evidence, never from a single answer.
enum MasteryLevel {
  notStarted('Not started', 0),
  developing('Developing', 1),
  practising('Practising', 2),
  proficient('Proficient', 3);

  const MasteryLevel(this.label, this.rank);

  final String label;
  final int rank;

  /// Estimates a mastery band from evidence counts.
  ///
  /// Deliberately conservative: one correct answer can never exceed
  /// [MasteryLevel.developing], because a single result is not proof.
  static MasteryLevel fromEvidence({
    required int attempts,
    required int correct,
  }) {
    if (attempts == 0) return MasteryLevel.notStarted;
    final accuracy = correct / attempts;
    if (attempts >= 5 && correct >= 4 && accuracy >= 0.8) {
      return MasteryLevel.proficient;
    }
    if (attempts >= 3 && correct >= 2 && accuracy >= 0.6) {
      return MasteryLevel.practising;
    }
    return MasteryLevel.developing;
  }
}

/// A single recorded answer attempt. This is the raw evidence for progress.
class AttemptRecord {
  const AttemptRecord({
    required this.questionId,
    required this.domain,
    required this.subject,
    required this.topic,
    required this.learnerAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.timestamp,
    this.errorCategory,
    this.concept,
    this.wasFollowUp = false,
  });

  final String questionId;
  final String domain;
  final String subject;
  final String topic;
  final String learnerAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final DateTime timestamp;

  /// Populated after diagnosis, when a category was inferred.
  final String? errorCategory;

  /// Populated after diagnosis, when a concept was inferred.
  final String? concept;

  /// True when this attempt came from a follow-up / practice question.
  final bool wasFollowUp;

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'domain': domain,
    'subject': subject,
    'topic': topic,
    'learnerAnswer': learnerAnswer,
    'correctAnswer': correctAnswer,
    'isCorrect': isCorrect,
    'timestamp': timestamp.toIso8601String(),
    'errorCategory': errorCategory,
    'concept': concept,
    'wasFollowUp': wasFollowUp,
  };

  factory AttemptRecord.fromJson(Map<String, dynamic> json) {
    return AttemptRecord(
      questionId: json['questionId'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      learnerAnswer: json['learnerAnswer'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      errorCategory: json['errorCategory'] as String?,
      concept: json['concept'] as String?,
      wasFollowUp: json['wasFollowUp'] as bool? ?? false,
    );
  }

  AttemptRecord copyWith({String? errorCategory, String? concept}) {
    return AttemptRecord(
      questionId: questionId,
      domain: domain,
      subject: subject,
      topic: topic,
      learnerAnswer: learnerAnswer,
      correctAnswer: correctAnswer,
      isCorrect: isCorrect,
      timestamp: timestamp,
      errorCategory: errorCategory ?? this.errorCategory,
      concept: concept ?? this.concept,
      wasFollowUp: wasFollowUp,
    );
  }
}

/// Aggregated progress for a single topic.
class TopicProgress {
  const TopicProgress({
    required this.topicId,
    required this.topicName,
    required this.attempts,
    required this.correct,
    this.lastAttemptAt,
  });

  final String topicId;
  final String topicName;
  final int attempts;
  final int correct;
  final DateTime? lastAttemptAt;

  double get accuracy => attempts == 0 ? 0 : correct / attempts;

  MasteryLevel get mastery =>
      MasteryLevel.fromEvidence(attempts: attempts, correct: correct);

  bool get needsRevision => attempts >= 2 && accuracy < 0.6;

  Map<String, dynamic> toJson() => {
    'topicId': topicId,
    'topicName': topicName,
    'attempts': attempts,
    'correct': correct,
    'lastAttemptAt': lastAttemptAt?.toIso8601String(),
  };

  factory TopicProgress.fromJson(Map<String, dynamic> json) {
    return TopicProgress(
      topicId: json['topicId'] as String? ?? '',
      topicName: json['topicName'] as String? ?? '',
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      lastAttemptAt: DateTime.tryParse(json['lastAttemptAt'] as String? ?? ''),
    );
  }
}

/// Count of how often a misconception category has recurred.
class MisconceptionCount {
  const MisconceptionCount({
    required this.errorCategory,
    required this.count,
    this.concept,
  });

  final String errorCategory;
  final int count;
  final String? concept;
}

/// A learning session grouping attempts made close together in time.
class LearningSession {
  const LearningSession({
    required this.id,
    required this.domain,
    required this.topic,
    required this.questionsAttempted,
    required this.correct,
    required this.startedAt,
    this.endedAt,
  });

  final String id;
  final String domain;
  final String topic;
  final int questionsAttempted;
  final int correct;
  final DateTime startedAt;
  final DateTime? endedAt;

  double get accuracy =>
      questionsAttempted == 0 ? 0 : correct / questionsAttempted;
}

/// Pre-test / post-test comparison. Improvement alone does not prove causation.
class AssessmentComparison {
  const AssessmentComparison({
    required this.preScore,
    required this.postScore,
    required this.sampleSize,
    this.note =
        'Improvement over time can have many causes and does not by itself '
        'prove that LearnLoop AI caused the change.',
  });

  final double preScore;
  final double postScore;
  final int sampleSize;
  final String note;

  double get delta => postScore - preScore;
}

/// Aggregate learner progress. This model is shared with Member 4; additions
/// must remain backward compatible (new fields optional with defaults).
class LearningProgress {
  const LearningProgress({
    this.attempts = const [],
    this.sessions = const [],
    this.prePost,
  });

  final List<AttemptRecord> attempts;
  final List<LearningSession> sessions;
  final AssessmentComparison? prePost;

  int get totalAttempts => attempts.length;

  int get correctAttempts => attempts.where((a) => a.isCorrect).length;

  int get incorrectAttempts => attempts.where((a) => !a.isCorrect).length;

  double get accuracy =>
      totalAttempts == 0 ? 0 : correctAttempts / totalAttempts;

  bool get isEmpty => attempts.isEmpty;

  /// Topic-level progress keyed by topic id.
  Map<String, TopicProgress> get topicProgress {
    final Map<String, TopicProgress> result = {};
    for (final attempt in attempts) {
      final existing = result[attempt.topic];
      final correct = (existing?.correct ?? 0) + (attempt.isCorrect ? 1 : 0);
      final count = (existing?.attempts ?? 0) + 1;
      final last = existing?.lastAttemptAt;
      final newer = last == null || attempt.timestamp.isAfter(last)
          ? attempt.timestamp
          : last;
      result[attempt.topic] = TopicProgress(
        topicId: attempt.topic,
        topicName: existing?.topicName ?? attempt.topic,
        attempts: count,
        correct: correct,
        lastAttemptAt: newer,
      );
    }
    return result;
  }

  /// The most repeated misconception categories, most frequent first.
  List<MisconceptionCount> get repeatedMisconceptions {
    final Map<String, MisconceptionCount> counts = {};
    for (final attempt in attempts) {
      final category = attempt.errorCategory;
      if (attempt.isCorrect || category == null || category.isEmpty) continue;
      final existing = counts[category];
      counts[category] = MisconceptionCount(
        errorCategory: category,
        count: (existing?.count ?? 0) + 1,
        concept: attempt.concept ?? existing?.concept,
      );
    }
    final list = counts.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return list;
  }

  /// Topics that would benefit from revision based on accumulated evidence.
  List<TopicProgress> get topicsNeedingRevision =>
      topicProgress.values.where((t) => t.needsRevision).toList()
        ..sort((a, b) => a.accuracy.compareTo(b.accuracy));

  /// Recent learning sessions derived from attempts, grouped by calendar day.
  ///
  /// Used by the dashboard when no explicitly stored sessions are available.
  List<LearningSession> get derivedSessions {
    final Map<String, List<AttemptRecord>> byDay = {};
    for (final attempt in attempts) {
      final day = DateTime(
        attempt.timestamp.year,
        attempt.timestamp.month,
        attempt.timestamp.day,
      ).toIso8601String();
      byDay.putIfAbsent(day, () => []).add(attempt);
    }
    final sessions = byDay.entries.map((entry) {
      final dayAttempts = entry.value
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      // Use the most frequently attempted topic as the session label.
      final topicCounts = <String, int>{};
      for (final a in dayAttempts) {
        topicCounts[a.topic] = (topicCounts[a.topic] ?? 0) + 1;
      }
      final topic = topicCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      return LearningSession(
        id: entry.key,
        domain: dayAttempts.first.domain,
        topic: topic,
        questionsAttempted: dayAttempts.length,
        correct: dayAttempts.where((a) => a.isCorrect).length,
        startedAt: dayAttempts.first.timestamp,
        endedAt: dayAttempts.last.timestamp,
      );
    }).toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  /// Sessions to display, preferring stored sessions over derived ones.
  List<LearningSession> get effectiveSessions =>
      sessions.isNotEmpty ? sessions : derivedSessions;

  LearningProgress copyWith({
    List<AttemptRecord>? attempts,
    List<LearningSession>? sessions,
    AssessmentComparison? prePost,
  }) {
    return LearningProgress(
      attempts: attempts ?? this.attempts,
      sessions: sessions ?? this.sessions,
      prePost: prePost ?? this.prePost,
    );
  }

  Map<String, dynamic> toJson() => {
    'attempts': attempts.map((a) => a.toJson()).toList(growable: false),
    'sessions': const [],
    'prePost': prePost == null
        ? null
        : {
            'preScore': prePost!.preScore,
            'postScore': prePost!.postScore,
            'sampleSize': prePost!.sampleSize,
            'note': prePost!.note,
          },
  };

  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    final prePostJson = json['prePost'];
    return LearningProgress(
      attempts: (json['attempts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AttemptRecord.fromJson)
          .toList(growable: false),
      sessions: const [],
      prePost: prePostJson is Map<String, dynamic>
          ? AssessmentComparison(
              preScore: (prePostJson['preScore'] as num?)?.toDouble() ?? 0,
              postScore: (prePostJson['postScore'] as num?)?.toDouble() ?? 0,
              sampleSize: (prePostJson['sampleSize'] as num?)?.toInt() ?? 0,
              note:
                  prePostJson['note'] as String? ??
                  'Improvement over time does not by itself prove causation.',
            )
          : null,
    );
  }

  static const LearningProgress empty = LearningProgress();
}

/// Context passed to the diagnosis service: the question, the learner answer
/// and any available evidence (attempt history / clarification response).
class DiagnosisRequest {
  const DiagnosisRequest({
    required this.question,
    required this.learnerAnswer,
    this.priorAttempts = const [],
    this.clarificationResponse,
    this.attemptHistorySummary = const [],
  });

  final Question question;
  final String learnerAnswer;
  final List<AttemptRecord> priorAttempts;
  final String? clarificationResponse;
  final List<String> attemptHistorySummary;

  bool get isClarification => clarificationResponse != null;
}

/// Context passed to the adaptive service after a diagnosis.
class AdaptiveContext {
  const AdaptiveContext({
    required this.diagnosis,
    required this.domain,
    required this.subject,
    required this.topic,
    this.attemptedQuestionId,
    this.attemptCountForTopic = 0,
    this.recentIncorrectCount = 0,
    this.currentDifficulty = Difficulty.medium,
    this.previousCorrect = false,
  });

  final DiagnosisResult diagnosis;
  final String domain;
  final String subject;
  final String topic;
  final String? attemptedQuestionId;
  final int attemptCountForTopic;
  final int recentIncorrectCount;
  final Difficulty currentDifficulty;
  final bool previousCorrect;
}
