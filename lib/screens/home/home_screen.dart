import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/services_scope.dart';
import '../../data/learning_catalog.dart';
import '../../models/learning_domain.dart';
import '../../models/learning_progress.dart';
import '../../models/learning_topic.dart';
import '../../widgets/domain_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/state_views.dart';

/// The polished home screen: branding, continue learning, the recommended
/// Mathematics and Python demo paths, and the seven domain cards.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const _BrandTitle(),
        actions: [
          IconButton(
            tooltip: 'Progress dashboard',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            icon: const Icon(Icons.insights_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: const [
            _ContinueLearningSection(),
            _DemoPathSection(),
            _DomainGridSection(),
          ],
        ),
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.psychology_alt_outlined, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'LearnLoop AI',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'The Wrong Answer Detective',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContinueLearningSection extends StatelessWidget {
  const _ContinueLearningSection();

  @override
  Widget build(BuildContext context) {
    final progress = ServicesScope.of(context).progress;
    return FutureBuilder<LearningProgress>(
      future: progress.getProgress(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: AppLoadingView(message: 'Loading your progress…'),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: AppErrorView(
              title: 'Progress unavailable',
              message:
                  'Your progress could not be loaded right now. You can '
                  'still start a lesson offline.',
            ),
          );
        }
        final data = snapshot.data ?? const LearningProgress();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Continue learning',
              subtitle: 'Pick up where you left off',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: data.isEmpty
                  ? const _StartFirstLessonCard()
                  : _RecentTopicCard(progress: data),
            ),
          ],
        );
      },
    );
  }
}

class _StartFirstLessonCard extends StatelessWidget {
  const _StartFirstLessonCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.flag_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No activity yet. Start with the Mathematics demo below.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTopicCard extends StatelessWidget {
  const _RecentTopicCard({required this.progress});

  final LearningProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topics = progress.topicProgress.values.toList()
      ..sort((a, b) {
        final aTime = a.lastAttemptAt ?? DateTime(0);
        final bTime = b.lastAttemptAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
    final latest = topics.first;
    final catalog = LearningCatalog.instance;
    final topic = catalog.topicById(latest.topicId);
    final title = topic?.name ?? latest.topicName;
    final percent = (latest.attempts == 0)
        ? 0
        : ((latest.correct / latest.attempts) * 100).round();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: topic == null
            ? null
            : () =>
                  Navigator.of(context)
                      .pushNamed(AppRoutes.lesson, arguments: topic),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: percent / 100),
              const SizedBox(height: 8),
              Text(
                '${latest.correct} of ${latest.attempts} correct '
                '($percent%)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoPathSection extends StatelessWidget {
  const _DemoPathSection();

  @override
  Widget build(BuildContext context) {
    final demoTopicIds = LearningCatalog.instance.demoTopics;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Recommended demo paths',
          subtitle: 'Verified Mathematics and Python content, ready offline',
        ),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: demoTopicIds.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _DemoPathCard(topic: demoTopicIds[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _DemoPathCard extends StatelessWidget {
  const _DemoPathCard({required this.topic});

  final LearningTopic topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPython = topic.id.contains('python');
    return SizedBox(
      width: 240,
      child: Card(
        color: theme.colorScheme.tertiaryContainer,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              Navigator.of(context)
                  .pushNamed(AppRoutes.lesson, arguments: topic),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isPython ? Icons.code : Icons.functions,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const Spacer(),
                Text(
                  topic.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  topic.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DomainGridSection extends StatelessWidget {
  const _DomainGridSection();

  @override
  Widget build(BuildContext context) {
    // The seven domains come from the enum, never a duplicated list.
    final domains = LearningDomain.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Explore all seven domains',
          subtitle: 'Choose a domain to see its subjects',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 380,
              mainAxisExtent: 172,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: domains.length,
            itemBuilder: (context, index) {
              final domain = domains[index];
              return DomainCard(
                domain: domain,
                onTap: () =>
                    Navigator.of(context)
                        .pushNamed(AppRoutes.subjects, arguments: domain),
              );
            },
          ),
        ),
      ],
    );
  }
}
