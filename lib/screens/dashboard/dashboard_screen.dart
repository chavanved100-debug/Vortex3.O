import 'package:flutter/material.dart';

import '../../app/services_scope.dart';
import '../../data/learning_catalog.dart';
import '../../models/diagnosis_result.dart';
import '../../models/learning_progress.dart';
import '../../widgets/section_header.dart';
import '../../widgets/state_views.dart';

/// Progress dashboard built from real recorded activity, not decorative stats.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialised = false;
  bool _loading = true;
  Object? _error;
  LearningProgress _progress = const LearningProgress();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialised) {
      _initialised = true;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final progress = await ServicesScope.of(context).progress.getProgress();
      if (!mounted) return;
      setState(() {
        _progress = progress;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(top: false, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const AppLoadingView(message: 'Loading your progress…');
    }
    if (_error != null) {
      return AppErrorView(
        title: 'Progress unavailable',
        message:
            'We could not load your progress right now. Your learning '
            'data is stored on this device and is not lost.',
        onRetry: _load,
      );
    }
    if (_progress.isEmpty) {
      return const _EmptyDashboard();
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: _DashboardBody(progress: _progress),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const _OfflineBanner(),
        const SizedBox(height: 80),
        const AppEmptyView(
          title: 'No learning activity yet',
          message:
              'Complete a lesson and try a few questions. Your progress '
              'will appear here — stored locally on this device.',
          icon: Icons.insights_outlined,
        ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline-first: lessons and questions work without a network. '
              'Your progress is stored locally on this device. Online sync is '
              'not enabled in this demo.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.progress});

  final LearningProgress progress;

  @override
  Widget build(BuildContext context) {
    final topics = progress.topicProgress.values.toList()
      ..sort((a, b) => b.attempts.compareTo(a.attempts));
    final misconceptions = progress.repeatedMisconceptions;
    final revisions = progress.topicsNeedingRevision;
    final sessions = progress.effectiveSessions;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const _OfflineBanner(),
        const SectionHeader(title: 'Overview'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _OverviewGrid(progress: progress),
        ),
        if (progress.prePost != null) ...[
          const SectionHeader(
            title: 'Pre-test vs post-test',
            subtitle: 'Same assessment items where available',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _PrePostCard(comparison: progress.prePost!),
          ),
        ],
        const SectionHeader(title: 'Topic progress'),
        if (topics.isEmpty)
          const _InlineNote('No topic activity recorded yet.')
        else
          for (final topic in topics)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _TopicProgressTile(topic: topic),
            ),
        const SectionHeader(title: 'Repeated misconception categories'),
        if (misconceptions.isEmpty)
          const _InlineNote('No repeated misconceptions detected.')
        else
          for (final item in misconceptions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _MisconceptionTile(item: item),
            ),
        const SectionHeader(title: 'Topics needing revision'),
        if (revisions.isEmpty)
          const _InlineNote('Nothing flagged for revision right now.')
        else
          for (final topic in revisions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _RevisionTile(topic: topic),
            ),
        const SectionHeader(title: 'Recent learning sessions'),
        if (sessions.isEmpty)
          const _InlineNote('No sessions recorded yet.')
        else
          for (final session in sessions.take(5))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _SessionTile(session: session),
            ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Mastery is shown cautiously: a single correct answer is progress, '
            'not proof. Topic mastery grows only as consistent evidence builds.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.progress});

  final LearningProgress progress;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Attempted', '${progress.totalAttempts}', Icons.quiz_outlined),
      ('Correct', '${progress.correctAttempts}', Icons.check_circle_outline),
      ('Incorrect', '${progress.incorrectAttempts}', Icons.cancel_outlined),
      (
        'Accuracy',
        '${(progress.accuracy * 100).round()}%',
        Icons.percent_outlined,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.1,
      children: [
        for (final item in items)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(item.$3, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$2,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          item.$1,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PrePostCard extends StatelessWidget {
  const _PrePostCard({required this.comparison});

  final AssessmentComparison comparison;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delta = comparison.delta;
    final deltaText = delta >= 0
        ? '+${(delta * 100).round()}%'
        : '${(delta * 100).round()}%';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Score(label: 'Pre-test', value: comparison.preScore),
                Icon(
                  Icons.arrow_forward,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                _Score(label: 'Post-test', value: comparison.postScore),
              ],
            ),
            const SizedBox(height: 12),
            Text('Change: $deltaText', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              'Based on ${comparison.sampleSize} '
              '${comparison.sampleSize == 1 ? 'item' : 'items'}.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Text(comparison.note, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          '${(value * 100).round()}%',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _TopicProgressTile extends StatelessWidget {
  const _TopicProgressTile({required this.topic});

  final TopicProgress topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name =
        LearningCatalog.instance.topicById(topic.topicId)?.name ??
        topic.topicName;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Chip(
                  label: Text(topic.mastery.label),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: topic.accuracy),
            const SizedBox(height: 6),
            Text(
              '${topic.correct} of ${topic.attempts} correct '
              '(${(topic.accuracy * 100).round()}%)',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _MisconceptionTile extends StatelessWidget {
  const _MisconceptionTile({required this.item});

  final MisconceptionCount item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.errorContainer,
          foregroundColor: theme.colorScheme.onErrorContainer,
          child: Text('${item.count}'),
        ),
        title: Text(errorCategoryLabel(item.errorCategory)),
        subtitle: item.concept == null ? null : Text(item.concept!),
      ),
    );
  }
}

class _RevisionTile extends StatelessWidget {
  const _RevisionTile({required this.topic});

  final TopicProgress topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name =
        LearningCatalog.instance.topicById(topic.topicId)?.name ??
        topic.topicName;
    return Card(
      child: ListTile(
        leading: Icon(Icons.replay, color: theme.colorScheme.tertiary),
        title: Text(name),
        subtitle: Text(
          '${topic.correct}/${topic.attempts} correct — worth another look',
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final LearningSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name =
        LearningCatalog.instance.topicById(session.topic)?.name ??
        session.topic;
    final date = session.startedAt;
    final dateText =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Card(
      child: ListTile(
        leading: Icon(Icons.history, color: theme.colorScheme.primary),
        title: Text(name),
        subtitle: Text(dateText),
        trailing: Text('${session.correct}/${session.questionsAttempted}'),
      ),
    );
  }
}

class _InlineNote extends StatelessWidget {
  const _InlineNote(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
