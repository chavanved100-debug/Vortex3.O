import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../data/learning_catalog.dart';
import '../../models/learning_domain.dart';
import '../../widgets/state_views.dart';
import '../../widgets/subject_card.dart';

/// Lists the subjects of a chosen [LearningDomain].
class SubjectListScreen extends StatelessWidget {
  const SubjectListScreen({super.key, required this.domain});

  final LearningDomain domain;

  @override
  Widget build(BuildContext context) {
    final subjects = LearningCatalog.instance.subjectsFor(domain);
    return Scaffold(
      appBar: AppBar(title: Text(domain.label)),
      body: SafeArea(
        top: false,
        child: subjects.isEmpty
            ? const AppEmptyView(
                title: 'No subjects yet',
                message: 'Subjects for this domain are being prepared.',
                icon: Icons.category_outlined,
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: subjects.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return SubjectCard(
                    subject: subject,
                    onTap: () =>
                        Navigator.of(context)
                            .pushNamed(AppRoutes.topics, arguments: subject),
                  );
                },
              ),
      ),
    );
  }
}
