import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/route_args.dart';
import '../../app/services_scope.dart';
import '../../data/learning_catalog.dart';
import '../../models/learning_topic.dart';
import '../../models/lesson.dart';
import '../../widgets/state_views.dart';

/// Lesson delivery: objective, concept explanation, worked example, hints and
/// a Start Quiz action. Fully offline.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.topic});

  final LearningTopic topic;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  Future<Lesson?>? _lessonFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lessonFuture ??= ServicesScope.of(context).lesson
        .getLessonForTopic(widget.topic.id);
  }

  void _startQuiz() {
    Navigator.of(context)
        .pushNamed(AppRoutes.quiz, arguments: QuizArgs(topic: widget.topic));
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final catalog = LearningCatalog.instance;
    final subject = catalog.subjectById(topic.subjectId);

    return Scaffold(
      appBar: AppBar(
        title: Text(topic.name),
        bottom: subject == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${subject.domain.label} • ${subject.name}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<Lesson?>(
          future: _lessonFuture!,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingView(message: 'Loading lesson…');
            }
            if (snapshot.hasError) {
              return AppErrorView(
                title: 'Lesson unavailable',
                message:
                    'This lesson could not be loaded. It works offline, '
                    'so please try again.',
                onRetry: () => setState(() {
                  _lessonFuture = ServicesScope.of(context).lesson
                      .getLessonForTopic(topic.id);
                }),
              );
            }
            final lesson = snapshot.data;
            if (lesson == null) {
              return const AppUnavailableView(
                title: 'Lesson coming soon',
                message:
                    'This topic does not have a verified lesson yet. '
                    'Try the Mathematics or Python demo.',
              );
            }
            return _LessonBody(lesson: lesson, onStartQuiz: _startQuiz);
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _startQuiz,
          icon: const Icon(Icons.quiz_outlined),
          label: const Text('Start quiz'),
        ),
      ),
    );
  }
}

class _LessonBody extends StatelessWidget {
  const _LessonBody({required this.lesson, required this.onStartQuiz});

  final Lesson lesson;
  final VoidCallback onStartQuiz;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          'Learning objective',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(lesson.objective, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 20),
        for (final section in lesson.sections) ...[
          Text(
            section.heading,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(section.body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 18),
        ],
        if (lesson.workedExampleSteps.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calculate_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Worked example',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < lesson.workedExampleSteps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
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
                              lesson.workedExampleSteps[i],
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
        if (lesson.hints.isNotEmpty) _HintsPanel(hints: lesson.hints),
      ],
    );
  }
}

class _HintsPanel extends StatefulWidget {
  const _HintsPanel({required this.hints});

  final List<Hint> hints;

  @override
  State<_HintsPanel> createState() => _HintsPanelState();
}

class _HintsPanelState extends State<_HintsPanel> {
  final Set<String> _revealed = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hints',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        for (final hint in widget.hints)
          Card(
            child: ExpansionTile(
              shape: const Border(),
              leading: Icon(
                Icons.lightbulb_outline,
                color: theme.colorScheme.tertiary,
              ),
              title: Text(hint.title),
              onExpansionChanged: (open) {
                if (open) setState(() => _revealed.add(hint.id));
              },
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(hint.body, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
