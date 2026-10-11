import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../data/learning_catalog.dart';
import '../../models/learning_subject.dart';
import '../../models/learning_topic.dart';
import '../../widgets/state_views.dart';
import '../../widgets/topic_tile.dart';

/// Lists the topics of a chosen [LearningSubject].
class TopicListScreen extends StatelessWidget {
  const TopicListScreen({super.key, required this.subject});

  final LearningSubject subject;

  void _openTopic(BuildContext context, LearningTopic topic) {
    if (topic.hasLesson) {
      Navigator.of(context).pushNamed(AppRoutes.lesson, arguments: topic);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '“${topic.name}” is coming soon. '
            'Try the Mathematics or Python demo in the meantime.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topics = LearningCatalog.instance.topicsFor(subject.id);
    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: SafeArea(
        top: false,
        child: topics.isEmpty
            ? const AppEmptyView(
                title: 'No topics yet',
                message: 'Topics for this subject are on the way.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: topics.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return TopicTile(
                    topic: topic,
                    onTap: () => _openTopic(context, topic),
                  );
                },
              ),
      ),
    );
  }
}
