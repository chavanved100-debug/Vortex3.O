import 'package:flutter/material.dart';

/// The seven learning domains supported by LearnLoop AI.
///
/// The [id] is the stable string identifier shared with the data layer and the
/// shared service contracts. Do not rename an [id] without flagging the
/// compatibility impact to the rest of the team.
enum LearningDomain {
  mathematics(
    id: 'mathematics',
    label: 'Mathematics',
    description: 'Algebra, calculus, trigonometry, geometry and statistics.',
    icon: Icons.calculate_outlined,
  ),
  science(
    id: 'science',
    label: 'Science',
    description: 'Physics, chemistry, biology and environmental science.',
    icon: Icons.science_outlined,
  ),
  computerScience(
    id: 'computer_science',
    label: 'Computer Science & IT',
    description: 'Python, Java, C, DSA, DBMS, OS, AI/ML and networking.',
    icon: Icons.memory_outlined,
  ),
  competitiveExams(
    id: 'competitive_exams',
    label: 'Competitive Exams',
    description: 'Quantitative aptitude, reasoning, verbal ability and mocks.',
    icon: Icons.emoji_events_outlined,
  ),
  languages(
    id: 'languages',
    label: 'Languages & Communication',
    description: 'Grammar, vocabulary, comprehension, writing and speaking.',
    icon: Icons.translate_outlined,
  ),
  humanities(
    id: 'humanities',
    label: 'Humanities & Social Sciences',
    description: 'History, geography, economics, civics and political science.',
    icon: Icons.public_outlined,
  ),
  professionalSkills(
    id: 'professional_skills',
    label: 'Professional & Practical Skills',
    description: 'Financial literacy, business, workplace and digital skills.',
    icon: Icons.work_outline,
  );

  const LearningDomain({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });

  /// Stable identifier used across services, storage and navigation.
  final String id;

  /// Human readable name shown in the UI.
  final String label;

  /// Short description shown on the domain card.
  final String description;

  /// Icon used by the UI (kept here so there is a single source of truth).
  final IconData icon;

  /// Resolves a domain from its [id], returning null for unknown ids.
  static LearningDomain? fromId(String? id) {
    if (id == null) return null;
    for (final domain in LearningDomain.values) {
      if (domain.id == id) return domain;
    }
    return null;
  }

  /// The two domains that carry the guided hackathon demo content.
  static const Set<LearningDomain> demoDomains = {
    LearningDomain.mathematics,
    LearningDomain.computerScience,
  };

  bool get isDemoPath => demoDomains.contains(this);
}
