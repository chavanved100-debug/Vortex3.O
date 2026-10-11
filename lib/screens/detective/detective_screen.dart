import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/route_args.dart';
import '../../app/services_scope.dart';
import '../../models/diagnosis_result.dart';
import '../../models/learning_progress.dart';
import '../../models/lesson.dart';
import '../../widgets/state_views.dart';

/// The Wrong Answer Detective.
///
/// Presents the answer error (certain) separately from any inferred cause
/// (uncertain), asks a clarification question when the diagnosis service is not
/// confident, and never presents an unsupported misconception as fact.
class DetectiveScreen extends StatefulWidget {
  const DetectiveScreen({super.key, required this.args});

  final DetectiveArgs args;

  @override
  State<DetectiveScreen> createState() => _DetectiveScreenState();
}

class _DetectiveScreenState extends State<DetectiveScreen> {
  final TextEditingController _clarificationController =
      TextEditingController();

  bool _initialised = false;
  bool _loading = true;
  bool _refining = false;
  Object? _error;
  DiagnosisResult? _diagnosis;
  Hint? _hint;
  String? _clarificationText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialised) {
      _initialised = true;
      _diagnose();
    }
  }

  @override
  void dispose() {
    _clarificationController.dispose();
    super.dispose();
  }

  Future<void> _diagnose({String? clarificationResponse}) async {
    final services = ServicesScope.of(context);
    final question = widget.args.question;
    setState(() {
      if (clarificationResponse == null) {
        _loading = true;
      } else {
        _refining = true;
      }
      _error = null;
    });
    try {
      final result = await services.diagnosis.diagnose(
        DiagnosisRequest(
          question: question,
          learnerAnswer: widget.args.learnerAnswer,
          clarificationResponse: clarificationResponse,
        ),
      );
      Hint? hint;
      if (result.recommendedHintId != null) {
        hint = await services.lesson.getHint(result.recommendedHintId!);
      }
      String? clarText;
      if (result.needsClarification && result.clarificationQuestionId != null) {
        clarText = await services.lesson.getClarificationQuestionText(
          result.clarificationQuestionId!,
        );
      }
      if (!mounted) return;
      setState(() {
        _diagnosis = result;
        _hint = hint;
        _clarificationText = clarText;
        _loading = false;
        _refining = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
        _refining = false;
      });
    }
  }

  Future<void> _submitClarification() async {
    final response = _clarificationController.text.trim();
    if (response.isEmpty) return;
    await _diagnose(clarificationResponse: response);
    _clarificationController.clear();
  }

  Future<void> _continue() async {
    final diagnosis = _diagnosis;
    if (diagnosis == null) return;
    final question = widget.args.question;
    var attemptCount = 0;
    var recentIncorrect = 0;
    try {
      final progress = await ServicesScope.of(context).progress.getProgress();
      final attempts = progress.attempts
          .where((a) => a.topic == question.topic)
          .toList();
      attemptCount = attempts.length;
      recentIncorrect = attempts.where((a) => !a.isCorrect).length;
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.adaptive,
      arguments: AdaptiveArgs(
        question: question,
        learnerAnswer: widget.args.learnerAnswer,
        diagnosis: diagnosis,
        attemptCountForTopic: attemptCount,
        recentIncorrectCount: recentIncorrect,
        currentDifficulty: question.difficulty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wrong Answer Detective')),
      body: SafeArea(top: false, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const AppLoadingView(message: 'Investigating your answer…');
    }
    if (_error != null) {
      return AppErrorView(
        title: 'Detective unavailable',
        message:
            'We could not analyse this answer right now. Your answer was '
            'recorded; please try again.',
        onRetry: _diagnose,
      );
    }
    final diagnosis = _diagnosis;
    if (diagnosis == null) {
      return const AppEmptyView(
        title: 'Nothing to investigate',
        message: 'No diagnosis was produced for this answer.',
        icon: Icons.search_off,
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _Intro(),
        const SizedBox(height: 16),
        _AnswerCard(args: widget.args),
        const SizedBox(height: 16),
        _CertaintyNote(diagnosis: diagnosis),
        const SizedBox(height: 16),
        if (diagnosis.needsClarification)
          _ClarificationCard(
            questionText:
                _clarificationText ??
                'Can you describe the first step you took?',
            controller: _clarificationController,
            busy: _refining,
            onSubmit: _submitClarification,
          )
        else
          _MisconceptionCard(diagnosis: diagnosis),
        if (_hint != null) ...[
          const SizedBox(height: 16),
          _HintCard(hint: _hint!),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _continue,
          icon: const Icon(Icons.auto_awesome),
          label: Text(
            diagnosis.needsClarification
                ? 'Continue with a short clarification'
                : 'See the suggested next step',
          ),
        ),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.search),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "Let's look at what may have happened — without any blame.",
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.args});

  final DetectiveArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(args.question.prompt, style: theme.textTheme.bodyLarge),
            const Divider(height: 24),
            Text('Your answer', style: theme.textTheme.labelMedium),
            Text(
              args.learnerAnswer,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text('Verified correct answer', style: theme.textTheme.labelMedium),
            Text(
              args.question.correctAnswer,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertaintyNote extends StatelessWidget {
  const _CertaintyNote({required this.diagnosis});

  final DiagnosisResult diagnosis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = diagnosis.needsClarification
        ? 'Certain: the answer is different from the verified answer. '
              'Not yet certain: the reason behind it.'
        : 'Certain: the answer is different from the verified answer. '
              'The cause below is an inference from the evidence, not a proof.';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _MisconceptionCard extends StatelessWidget {
  const _MisconceptionCard({required this.diagnosis});

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
            Text(
              'What may have gone wrong?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _LabelValue(label: 'Likely cause', value: diagnosis.concept),
            const SizedBox(height: 8),
            _LabelValue(
              label: 'Pattern',
              value: errorCategoryLabel(diagnosis.errorCategory),
            ),
            const SizedBox(height: 12),
            Text('Evidence', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            for (final item in diagnosis.evidence)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(item, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            _ConfidenceBar(diagnosis: diagnosis),
          ],
        ),
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({required this.diagnosis});

  final DiagnosisResult diagnosis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confidence', style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: diagnosis.safeConfidence,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(diagnosis.confidenceLevel.label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _ClarificationCard extends StatelessWidget {
  const _ClarificationCard({
    required this.questionText,
    required this.controller,
    required this.busy,
    required this.onSubmit,
  });

  final String questionText;
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSubmit;

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
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A quick question before we guess',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              questionText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              minLines: 1,
              maxLines: 3,
              enabled: !busy,
              decoration: const InputDecoration(
                hintText: 'Describe your reasoning…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: busy ? null : onSubmit,
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(busy ? 'Updating…' : 'Submit response'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.hint});

  final Hint hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Targeted hint',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(hint.title, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(hint.body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
