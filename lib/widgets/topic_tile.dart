import 'package:flutter/material.dart';

import '../models/learning_topic.dart';

/// Reusable tile representing a [LearningTopic].
///
/// When no lesson content exists the tile is visibly marked as unavailable but
/// remains tappable so the caller can show a helpful message.
class TopicTile extends StatelessWidget {
  const TopicTile({super.key, required this.topic, required this.onTap});

  final LearningTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = topic.hasLesson;
    return Semantics(
      button: true,
      label: available
          ? '${topic.name}. ${topic.objective}'
          : '${topic.name}. Content coming soon.',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: available
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            foregroundColor: available
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            child: Icon(available ? Icons.play_arrow : Icons.schedule),
          ),
          title: Text(
            topic.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            available ? topic.objective : 'Content coming soon',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(
            available ? Icons.chevron_right : Icons.lock_outline,
            color: available ? null : theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
