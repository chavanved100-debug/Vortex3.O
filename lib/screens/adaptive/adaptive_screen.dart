import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/route_args.dart';
import '../../app/services_scope.dart';
import '../../data/learning_catalog.dart';
import '../../models/adaptive_decision.dart';
import '../../models/diagnosis_result.dart';
import '../../models/learning_progress.dart';
import '../../models/learning_topic.dart';
import '../../models/lesson.dart';
import '../../models/question.dart';
import '../../widgets/state_views.dart';

/// Adaptive follow-up screen.
///
/// It asks [AdaptiveLearningService] for a decision, resolves the referenced
/// explanation and question through the local services, and renders them. No
/// decision rules live in this widget.
class AdaptiveScreen extends StatefulWidget {
  const AdaptiveScreen({super.key, required this.args});

  final AdaptiveArgs args;

  @override
  State<AdaptiveScreen> createState() => _AdaptiveScreenState();
}

class _AdaptiveData {
  const _AdaptiveData({
    required this.decision,
    this.explanation,
    this.nextQuestion,
  });

  final AdaptiveDecision decision;
  final Explanation? explanation;
  final Question? nextQuestion;
}

class _AdaptiveScreenState extends State<AdaptiveScreen> {
  bool _initialised = false;
  bool _loading = true;
  Object? _error;
  _AdaptiveData? _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialised) {
      _initialised = true;
      _load();
    }
  }

  Future<void> _load() async {
    final services = ServicesScope.of(context);
    final args = widget.args;
    final q = args.question;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final decision = await services.adaptive.decide(
        AdaptiveContext(
          diagnosis: args.diagnosis,
          domain: q.domain,
          subject: q.subject,
          topic: q.topic,
          attemptedQuestionId: q.id,
          attemptCountForTopic: args.attemptCountForTopic,
          recentIncorrectCount: args.recentIncorrectCount,
          currentDifficulty: args.currentDifficulty,
          previousCorrect: args.previousCorrect,
        ),
      );
      Explanation? explanation;
      if (decision.explanationId != null) {
        explanation = await services.lesson.getExplanation(
          decision.explanationId!,
        );
      }
      Question? nextQuestion;
      if (decision.nextQuestionId != null) {
        nextQuestion = await services.questions.getQuestionById(
          decision.nextQuestionId!,
        );
      }
      if (!mounted) return;
      setState(() {
        _data = _AdaptiveData(
          decision: decision,
          explanation: explanation,
          nextQuestion: nextQuestion,
        );
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  LearningTopic? get _topic =>
      LearningCatalog.instance.topicById(widget.args.question.topic);

  void _startQuestion(Question question) {
    final topic = _topic;
    if (topic == null) return;
    Navigator.of(context).pushNamed(
      AppRoutes.quiz,
      arguments: QuizArgs(
        topic: topic,
        questionIds: [question.id],
        isFollowUp: true,
      ),
    );
  }

  void _practiceTopicAgain() {
    final topic = _topic;
    if (topic == null) return;
    Navigator.of(context).pushNamed(
      AppRoutes.quiz,
      arguments: QuizArgs(topic: topic, isFollowUp: true),
    );
  }

  void _openClarification() {
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.detective,
      arguments: DetectiveArgs(
        question: widget.args.question,
        learnerAnswer: widget.args.learnerAnswer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your next step')),
      body: SafeArea(top: false, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const AppLoadingView(message: 'Choosing the best next step…');
    }
    if (_error != null) {
      return AppErrorView(
        title: 'Next step unavailable',
        message:
            'We could not choose your next step right now. You can '
            'continue with the lesson or try again.',
        onRetry: _load,
      );
    }
    final data = _data;
    if (data == null) {
      return const AppEmptyView(
        title: 'Nothing to show',
        message: 'No follow-up activity was produced.',
      );
    }
    final args = widget.args;
    final decision = data.decision;
    final isUncertain =
        args.diagnosis.needsClarification ||
        decision.activityType == ActivityType.clarificationActivity;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _ActivityHeader(decision: decision),
        const SizedBox(height: 16),
        _DiagnosisSummary(diagnosis: args.diagnosis),
        const SizedBox(height: 16),
        if (isUncertain)
          _ClarificationPath(onOpen: _openClarification)
        else ...[
          _ExplanationSection(
            decision: decision,
            explanation: data.explanation,
          ),
          const SizedBox(height: 16),
          _NextStepCard(
            decision: decision,
            nextQuestion: data.nextQuestion,
            onStart: _startQuestion,
            onPracticeAgain: _practiceTopicAgain,
          ),
        ],
        if (args.previousCorrect) ...[
          const SizedBox(height: 16),
          const _MasteryNote(),
        ],
      ],
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({required this.decision});

  final AdaptiveDecision decision;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.auto_awesome),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                decision.activityType.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Suggested from your last answer',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiagnosisSummary extends StatelessWidget {
  const _DiagnosisSummary({required this.diagnosis});

  final DiagnosisResult diagnosis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What we noticed', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              errorCategoryLabel(diagnosis.errorCategory),
              style: theme.textTheme.bodyLarge,
            ),
            if (diagnosis.concept.isNotEmpty &&
                diagnosis.errorCategory != 'none') ...[
              const SizedBox(height: 4),
              Text(
                diagnosis.concept,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClarificationPath extends StatelessWidget {
  const _ClarificationPath({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'One quick clarification first',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We are not confident about the exact cause yet, so we will ask '
              'a short question instead of guessing.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.help_outline),
              label: const Text('Open clarification'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplanationSection extends StatelessWidget {
  const _ExplanationSection({
    required this.decision,
    required this.explanation,
  });

  final AdaptiveDecision decision;
  final Explanation? explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (decision.explanationId != null && explanation == null) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.info_outline, color: theme.colorScheme.error),
          title: const Text('Explanation unavailable'),
          subtitle: const Text(
            'The suggested explanation could not be found. You can still try '
            'the practice question below.',
          ),
        ),
      );
    }
    if (explanation == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  explanation!.isSimplified
                      ? Icons.lightbulb_outline
                      : Icons.menu_book_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    explanation!.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(explanation!.body, style: theme.textTheme.bodyMedium),
            if (explanation!.steps.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (var i = 0; i < explanation!.steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}. ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          explanation!.steps[i],
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  const _NextStepCard({
    required this.decision,
    required this.nextQuestion,
    required this.onStart,
    required this.onPracticeAgain,
  });

  final AdaptiveDecision decision;
  final Question? nextQuestion;
  final void Function(Question) onStart;
  final VoidCallback onPracticeAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = nextQuestion;

    if (decision.nextQuestionId != null && question == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Follow-up unavailable', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              const Text(
                'The suggested follow-up question is not available offline. '
                'You can practice another question from this topic instead.',
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: onPracticeAgain,
                icon: const Icon(Icons.replay),
                label: const Text('Practice another question'),
              ),
            ],
          ),
        ),
      );
    }

    if (question == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ready for another go?', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              const Text(
                'No specific follow-up was chosen. You can practice this topic '
                'again to keep the loop going.',
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: onPracticeAgain,
                icon: const Icon(Icons.replay),
                label: const Text('Practice another question'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.quiz_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your next question',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(
                  label: Text(question.difficulty.label),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(question.prompt, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => onStart(question),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start this question'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MasteryNote extends StatelessWidget {
  const _MasteryNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.hourglass_bottom,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nice work. One correct answer is progress, not proof of mastery. '
              'A few more will tell us more.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
