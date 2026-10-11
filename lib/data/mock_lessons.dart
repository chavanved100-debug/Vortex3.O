import '../models/lesson.dart';

/// Offline lesson content for the two demo topics, plus the standalone
/// explanations and clarification questions referenced by the adaptive and
/// diagnosis services. Everything here works without a network.
class LessonContent {
  const LessonContent._();

  static const List<Lesson> lessons = [
    Lesson(
      id: 'lesson_math_linear_equations',
      topicId: 'mathematics_algebra_linear_equations',
      title: 'Linear Equations',
      objective: 'Solve single-variable linear equations by keeping both sides balanced.',
      sections: [
        LessonSection(
          heading: 'What is a linear equation?',
          body:
              'A linear equation is a statement that two expressions are equal, '
              'where the unknown (usually x) appears only to the first power. '
              'Solving it means finding the value of x that makes the statement '
              'true.',
        ),
        LessonSection(
          heading: 'The balance idea',
          body:
              'Think of the equation as a balance scale. Whatever operation you '
              'perform on one side you must do to the other, so the equation '
              'stays balanced. To isolate x, undo operations in reverse order: '
              'undo addition or subtraction first, then multiplication or '
              'division.',
        ),
        LessonSection(
          heading: 'Common pitfalls',
          body:
              'Watch the sign of each term when you move it across the equals '
              'sign, and remember to divide by the coefficient after collecting '
              'the x terms. Distribute a factor across every term inside a '
              'bracket.',
        ),
      ],
      workedExampleSteps: [
        'Example: solve 2x - 3 = 7.',
        'Step 1: Add 3 to both sides so the constant term is removed: 2x = 10.',
        'Step 2: Divide both sides by 2 to isolate x: x = 5.',
        'Check: 2(5) - 3 = 10 - 3 = 7, which matches the original equation.',
      ],
      hints: [
        Hint(
          id: 'hint_math_undo_addition',
          title: 'Undo the constant first',
          body:
              'When a constant is subtracted, add it to both sides. When it is '
              'added, subtract it from both sides.',
        ),
        Hint(
          id: 'hint_math_undo_multiplication',
          title: 'Divide to undo multiplication',
          body:
              'If the unknown is multiplied by a number, divide both sides by '
              'that number.',
        ),
        Hint(
          id: 'hint_math_distribute',
          title: 'Distribute across the whole bracket',
          body:
              'Multiply the factor outside the bracket by every term inside the '
              'bracket.',
        ),
      ],
    ),
    Lesson(
      id: 'lesson_python_loops',
      topicId: 'computer_science_python_loops',
      title: 'Loops and Range',
      objective: 'Predict loop iterations and range() boundaries accurately in Python.',
      sections: [
        LessonSection(
          heading: 'What loops do',
          body:
              'A for loop repeats a block of code once for each value produced '
              'by the thing on the right of "in". Understanding how many values '
              'are produced tells you how many iterations to expect.',
        ),
        LessonSection(
          heading: 'How range() works',
          body:
              'range(stop) starts at 0 and stops BEFORE stop. range(start, stop) '
              'starts at start and stops before stop. range(start, stop, step) '
              'increases by step each time and still stops before stop.',
        ),
        LessonSection(
          heading: 'The classic off-by-one',
          body:
              'The most common range mistake is treating the stop value as '
              'inclusive. It never is. range(3) gives 0, 1, 2 - three values - '
              'and not 3.',
        ),
      ],
      workedExampleSteps: [
        'Example: list the values from range(2, 8, 2).',
        'Start at 2. Add the step: 2 + 2 = 4. Add again: 4 + 2 = 6.',
        'Add again: 6 + 2 = 8, which reaches the stop value, so we stop.',
        'The values are 2, 4, 6 - three iterations.',
      ],
      hints: [
        Hint(
          id: 'hint_python_range_start',
          title: 'range() starts at 0',
          body:
              'With a single argument, range starts at 0. Write the first value '
              'down before counting.',
        ),
        Hint(
          id: 'hint_python_range_stop',
          title: 'The stop value is excluded',
          body:
              'range() stops before the stop value. The stop value itself is '
              'never produced.',
        ),
      ],
    ),
  ];

  static const List<Explanation> explanations = [
    Explanation(
      id: 'exp_math_linear_simplified',
      title: 'A simpler way to think about it',
      body:
          'Think of the equation as a balance scale. Remove the extra number '
          'first, then divide what is left.',
      isSimplified: true,
      steps: [
        'Write the equation with the unknown on its own.',
        'Remove any added or subtracted number using the opposite operation.',
        'Divide by the number multiplying the unknown.',
        'Check your answer in the original equation.',
      ],
    ),
    Explanation(
      id: 'exp_math_linear_step',
      title: 'Step-by-step worked example',
      body: 'Follow each step slowly and say the operation out loud.',
      steps: [
        'Start: 2x - 3 = 7.',
        'Add 3 to both sides: 2x = 10.',
        'Divide both sides by 2: x = 5.',
        'Check: 2(5) - 3 = 7. Correct.',
      ],
    ),
    Explanation(
      id: 'exp_python_range_simplified',
      title: 'range() in plain words',
      body:
          'range() hands you numbers one at a time. It starts where you tell it '
          'and stops just before the second number you give it.',
      isSimplified: true,
      steps: [
        'range(3) gives 0, 1, 2 (starts at 0, stops before 3).',
        'range(2, 8, 2) gives 2, 4, 6 (skips forward, stops before 8).',
        'Count how many numbers you wrote down; that is the iteration count.',
      ],
    ),
    Explanation(
      id: 'exp_python_range_step',
      title: 'Step-by-step worked example',
      body: 'Write the sequence out before deciding the answer.',
      steps: [
        'Start: range(2, 8, 2).',
        'Values: 2, 4, 6.',
        'The next value 8 equals the stop value, so stop.',
        'Three iterations in total.',
      ],
    ),
    Explanation(
      id: 'exp_generic_revision',
      title: 'Quick revision',
      body:
          'Take a calm second pass over the concept before trying a similar '
          'question. Slowing down often removes small slips.',
      steps: [
        'Read the question twice.',
        'Write down the rule you are using.',
        'Apply it one step at a time.',
      ],
    ),
  ];

  /// Text for clarification questions referenced by a DiagnosisResult.
  static const Map<String, String> clarificationQuestions = {
    'clarify_math_linear_1':
        'Which step did you take first when solving the equation?',
    'clarify_math_linear_2':
        'When you saw the bracket, did you multiply the outside number by '
        'every term inside it?',
    'clarify_python_range_1':
        'When you counted the range, did you start at 0 or at 1?',
    'clarify_python_range_2':
        'Did you treat the stop value in range() as included or excluded?',
    'clarify_generic':
        'Can you describe the first step you took in your own words?',
  };

  /// Optional clarification answer options, keyed by clarification question id.
  static const Map<String, List<String>> clarificationOptions = {
    'clarify_math_linear_1': [
      'I removed the added/subtracted number first',
      'I divided first',
      'I am not sure',
    ],
    'clarify_math_linear_2': [
      'Yes, every term inside',
      'No, only the first term',
      'I am not sure',
    ],
    'clarify_python_range_1': [
      'I started at 0',
      'I started at 1',
      'I am not sure',
    ],
    'clarify_python_range_2': [
      'Excluded (stops before it)',
      'Included it',
      'I am not sure',
    ],
  };

  static Lesson? lessonForTopic(String topicId) {
    for (final lesson in lessons) {
      if (lesson.topicId == topicId) return lesson;
    }
    return null;
  }

  static Explanation? explanationById(String id) {
    for (final explanation in explanations) {
      if (explanation.id == id) return explanation;
    }
    return null;
  }

  static Hint? hintById(String id) {
    for (final lesson in lessons) {
      for (final hint in lesson.hints) {
        if (hint.id == id) return hint;
      }
    }
    return null;
  }
}
