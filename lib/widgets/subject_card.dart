import 'package:flutter/material.dart';

import '../models/learning_subject.dart';

/// Reusable list card representing a [LearningSubject].
class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key, required this.subject, required this.onTap});

  final LearningSubject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '${subject.name}. ${subject.description}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.secondaryContainer,
            foregroundColor: theme.colorScheme.onSecondaryContainer,
            child: Icon(subject.domain.icon),
          ),
          title: Text(
            subject.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subject.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: subject.isDemoPath
              ? Chip(
                  label: const Text('Demo ready'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                )
              : const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
