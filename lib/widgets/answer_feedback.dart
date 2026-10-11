import 'package:flutter/material.dart';

import '../models/question.dart';

/// Reusable answer feedback panel: result, verified answer, explanation and a
/// continue action. Used by the quiz (and reusable by follow-up flows).
class AnswerFeedback extends StatelessWidget {
  const AnswerFeedback({
    super.key,
    required this.question,
    required this.learnerAnswer,
    required this.isCorrect,
    required this.onContinue,
    this.continueLabel = 'Continue',
    this.continueIcon = Icons.arrow_forward,
  });

  final Question question;
  final String learnerAnswer;
  final bool isCorrect;
  final VoidCallback onContinue;
  final String continueLabel;
  final IconData continueIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    final background = isCorrect
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.errorContainer;
    final onBackground = isCorrect
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onErrorContainer;

    return Card(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  isCorrect ? 'Correct' : 'Not quite',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onBackground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your answer: $learnerAnswer',
              style: theme.textTheme.bodyMedium?.copyWith(color: onBackground),
            ),
            const SizedBox(height: 4),
            Text(
              'Verified answer: ${question.correctAnswer}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onBackground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Why',
              style: theme.textTheme.labelLarge?.copyWith(color: onBackground),
            ),
            const SizedBox(height: 4),
            Text(
              question.explanation,
              style: theme.textTheme.bodyMedium?.copyWith(color: onBackground),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onContinue,
              icon: Icon(continueIcon),
              label: Text(continueLabel),
            ),
          ],
        ),
      ),
    );
  }
}
