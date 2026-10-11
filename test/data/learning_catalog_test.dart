import 'package:flutter_test/flutter_test.dart';
import 'package:learnloop_ai/data/learning_catalog.dart';
import 'package:learnloop_ai/models/learning_domain.dart';

void main() {
  group('LearningCatalog', () {
    final catalog = LearningCatalog.instance;

    test('all seven domains are represented with at least one subject', () {
      expect(LearningDomain.values, hasLength(7));
      for (final domain in LearningDomain.values) {
        expect(
          catalog.subjectsFor(domain),
          isNotEmpty,
          reason: '${domain.label} should have at least one subject',
        );
      }
    });

    test('every subject has at least one topic', () {
      for (final subject in LearningCatalog.subjects) {
        expect(
          catalog.topicsFor(subject.id),
          isNotEmpty,
          reason: '${subject.name} should have at least one topic',
        );
      }
    });

    test('mathematics exposes the expected subjects', () {
      final names = catalog
          .subjectsFor(LearningDomain.mathematics)
          .map((s) => s.name)
          .toList();
      expect(
        names,
        containsAll([
          'Algebra',
          'Calculus',
          'Trigonometry',
          'Geometry',
          'Probability and Statistics',
        ]),
      );
    });

    test('computer science exposes Python', () {
      final names = catalog
          .subjectsFor(LearningDomain.computerScience)
          .map((s) => s.name);
      expect(names, contains('Python'));
    });

    test('demo topics cover linear equations and python loops', () {
      final ids = catalog.demoTopics.map((t) => t.id).toList();
      expect(ids, contains('mathematics_algebra_linear_equations'));
      expect(ids, contains('computer_science_python_loops'));
    });

    test('topic lookup resolves by id and returns null for unknown', () {
      expect(
        catalog.topicById('mathematics_algebra_linear_equations'),
        isNotNull,
      );
      expect(catalog.topicById('does_not_exist'), isNull);
      expect(catalog.subjectById(null), isNull);
    });
  });
}
