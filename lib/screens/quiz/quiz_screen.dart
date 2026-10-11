import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/route_args.dart';
import '../../app/services_scope.dart';
import '../../models/diagnosis_result.dart';
import '../../models/learning_progress.dart';
import '../../models/question.dart';
import '../../services/progress_service.dart';
import '../../services/question_service.dart';
import '../../widgets/answer_feedback.dart';
import '../../widgets/state_views.dart';

/// Interactive quiz screen. Loads questions for the selected topic, presents
/// multiple-choice options and shows clear selected/submitted/correct/incorrect
/// states. Diagnosis is not performed here: incorrect answers are handed to the
/// detective flow.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.args});

  final QuizArgs args;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuestionService? _questionService;
  ProgressService? _progressService;

  bool _loading = true;
  Object? _error;
  List<Question> _questions = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_questionService == null) {
      final services = ServicesScope.of(context);
      _questionService = services.questions;
      _progressService = services.progress;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final args = widget.args;
      final loaded = await _questionService!.getQuestions(topic: args.topic.id);
      var questions = loaded;
      if (args.questionIds != null && args.questionIds!.isNotEmpty) {
        final byId = <String, Question>{for (final q in loaded) q.id: q};
        for (final id in args.questionIds!) {
          final extra = byId[id] ?? await _questionService!.getQuestionById(id);
          if (extra != null) byId[id] = extra;
        }
        questions = [
          for (final id in args.questionIds!)
            if (byId[id] != null) byId[id]!,
        ];
      }
      if (!mounted) return;
      setState(() {
        _questions = questions;
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
      appBar: AppBar(title: Text(widget.args.topic.name)),
      body: SafeArea(top: false, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const AppLoadingView(message: 'Loading questions…');
    }
    if (_error != null) {
      return AppErrorView(
        title: 'Questions unavailable',
        message:
            'We could not load questions for this topic right now. '
            'The question bank works offline, so please try again.',
        onRetry: _load,
      );
    }
    if (_questions.isEmpty) {
      return const AppEmptyView(
        title: 'No questions yet',
        message:
            'This topic does not have any practice questions yet. '
            'Try the Mathematics or Python demo.',
        icon: Icons.quiz_outlined,
      );
    }
    final question = _questions.first;
    return _QuestionPanel(
      key: ValueKey(question.id),
      question: question,
      onSubmitted: _recordAttempt,
      onContinue: (answer, isCorrect) => _continue(question, answer, isCorrect),
    );
  }

  Future<void> _recordAttempt(
    Question question,
    String answer,
    bool isCorrect,
  ) async {
    final progress = _progressService;
    if (progress == null) return;
    try {
      await progress.recordAttempt(
        AttemptRecord(
          questionId: question.id,
          domain: question.domain,
          subject: question.subject,
          topic: question.topic,
          learnerAnswer: answer,
          correctAnswer: question.correctAnswer,
          isCorrect: isCorrect,
          timestamp: DateTime.now(),
          wasFollowUp: widget.args.isFollowUp,
        ),
      );
    } catch (_) {
      // Progress recording is best-effort and never blocks the learning cycle.
    }
  }

  Future<void> _continue(
    Question question,
    String answer,
    bool isCorrect,
  ) async {
    if (!isCorrect) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.detective,
        arguments: DetectiveArgs(question: question, learnerAnswer: answer),
      );
      return;
    }
    // Correct: gather attempt context and move to the adaptive step.
    var attemptCount = 0;
    var recentIncorrect = 0;
    try {
      final progress = await _progressService!.getProgress();
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
        learnerAnswer: answer,
        diagnosis: const DiagnosisResult(
          concept: 'No error detected',
          errorCategory: 'none',
          evidence: ['The submitted answer matches the verified answer.'],
          confidence: 0.9,
        ),
        attemptCountForTopic: attemptCount,
        recentIncorrectCount: recentIncorrect,
        currentDifficulty: question.difficulty,
        previousCorrect: true,
      ),
    );
  }
}

class _QuestionPanel extends StatefulWidget {
  const _QuestionPanel({
    super.key,
    required this.question,
    required this.onSubmitted,
    required this.onContinue,
  });

  final Question question;
  final void Function(Question, String, bool) onSubmitted;
  final void Function(String, bool) onContinue;

  @override
  State<_QuestionPanel> createState() => _QuestionPanelState();
}

class _QuestionPanelState extends State<_QuestionPanel> {
  String? _selected;
  bool _submitted = false;

  bool get _isCorrect =>
      _selected != null && widget.question.isCorrect(_selected!);

  void _submit() {
    if (_selected == null || _submitted) return; // prevents duplicates
    setState(() => _submitted = true);
    widget.onSubmitted(widget.question, _selected!, _isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.question;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Chip(
          label: Text(question.difficulty.label),
          avatar: const Icon(Icons.speed, size: 16),
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(height: 12),
        Text(
          question.prompt,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        for (final option in question.options)
          _OptionTile(
            label: option,
            selected: _selected == option,
            submitted: _submitted,
            isCorrectOption: question.isCorrect(option),
            onTap: _submitted ? null : () => setState(() => _selected = option),
          ),
        const SizedBox(height: 20),
        if (!_submitted)
          FilledButton(
            onPressed: _selected == null ? null : _submit,
            child: const Text('Submit answer'),
          )
        else
          AnswerFeedback(
            question: question,
            learnerAnswer: _selected!,
            isCorrect: _isCorrect,
            continueLabel: _isCorrect
                ? 'See suggested next step'
                : 'Open the Detective',
            continueIcon: _isCorrect ? Icons.auto_awesome : Icons.search,
            onContinue: () => widget.onContinue(_selected!, _isCorrect),
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.submitted,
    required this.isCorrectOption,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool submitted;
  final bool isCorrectOption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? borderColor;
    Color? backgroundColor;
    IconData? trailingIcon;
    Color? trailingColor;

    if (submitted) {
      if (isCorrectOption) {
        backgroundColor = theme.colorScheme.primaryContainer;
        borderColor = theme.colorScheme.primary;
        trailingIcon = Icons.check_circle;
        trailingColor = theme.colorScheme.primary;
      } else if (selected) {
        backgroundColor = theme.colorScheme.errorContainer;
        borderColor = theme.colorScheme.error;
        trailingIcon = Icons.cancel;
        trailingColor = theme.colorScheme.error;
      }
    } else if (selected) {
      borderColor = theme.colorScheme.primary;
      backgroundColor = theme.colorScheme.surfaceContainerHighest;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: Material(
          color: backgroundColor ?? theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor ?? theme.colorScheme.outlineVariant,
                  width: borderColor == null ? 1 : 2,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(label, style: theme.textTheme.bodyLarge),
                  ),
                  if (trailingIcon != null)
                    Icon(trailingIcon, color: trailingColor)
                  else if (selected)
                    Icon(
                      Icons.radio_button_checked,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
