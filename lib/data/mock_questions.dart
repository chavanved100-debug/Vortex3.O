import '../models/question.dart';

/// Hand-verified offline question bank.
///
/// The MVP prioritises a fully working Mathematics (linear equations) and
/// Python (loops and range) demonstration. Every answer was checked by hand.
class QuestionBank {
  const QuestionBank._();

  static const String mathDomain = 'mathematics';
  static const String mathSubject = 'mathematics_algebra';
  static const String mathTopic = 'mathematics_algebra_linear_equations';
  static const String pythonDomain = 'computer_science';
  static const String pythonSubject = 'computer_science_python';
  static const String pythonTopic = 'computer_science_python_loops';

  static const List<Question> all = [
    // ---------------- Mathematics: linear equations ----------------
    Question(
      id: 'math_linear_eq_1',
      domain: mathDomain,
      subject: mathSubject,
      topic: mathTopic,
      prompt: 'Solve for x:  2x - 3 = 7',
      type: QuestionType.multipleChoice,
      options: ['x = 2', 'x = 5', 'x = 10', 'x = 4'],
      correctAnswer: 'x = 5',
      explanation:
          'Add 3 to both sides to get 2x = 10, then divide both sides by 2 '
          'to get x = 5.',
      hints: [
        'Undo the subtraction before undoing the multiplication.',
        'Whatever you do to one side, do to the other.',
      ],
      misconceptionRules: [
        MisconceptionRule(
          id: 'math_linear_eq_1_sign',
          errorCategory: 'sign_error',
          concept: 'Handling negative terms when isolating x',
          triggerAnswers: ['x = 2'],
          hintId: 'hint_math_undo_addition',
          evidence: [
            'Choosing x = 2 results from subtracting 3 instead of adding 3.',
          ],
        ),
        MisconceptionRule(
          id: 'math_linear_eq_1_forgot_divide',
          errorCategory: 'incomplete_reasoning',
          concept: 'Dividing after undoing the constant term',
          triggerAnswers: ['x = 10'],
          hintId: 'hint_math_undo_multiplication',
          evidence: [
            'Choosing x = 10 matches stopping at 2x = 10 without dividing by 2.',
          ],
        ),
        MisconceptionRule(
          id: 'math_linear_eq_1_slip',
          errorCategory: 'calculation_slip',
          concept: 'Arithmetic while rearranging the equation',
          triggerAnswers: ['x = 4'],
          evidence: [
            'Choosing x = 4 is close to the correct value and looks like a slip.',
          ],
        ),
      ],
      followUpIds: ['math_linear_eq_1_easier', 'math_linear_eq_2'],
      difficulty: Difficulty.easy,
    ),
    Question(
      id: 'math_linear_eq_1_easier',
      domain: mathDomain,
      subject: mathSubject,
      topic: mathTopic,
      prompt: 'Solve for x:  x + 4 = 9',
      type: QuestionType.multipleChoice,
      options: ['x = 5', 'x = 13', 'x = 4', 'x = 9'],
      correctAnswer: 'x = 5',
      explanation: 'Subtract 4 from both sides: x = 9 - 4 = 5.',
      hints: ['Isolate x by undoing the addition of 4.'],
      followUpIds: ['math_linear_eq_1'],
      difficulty: Difficulty.easy,
    ),
    Question(
      id: 'math_linear_eq_2',
      domain: mathDomain,
      subject: mathSubject,
      topic: mathTopic,
      prompt: 'Solve for x:  5(x - 2) = 3x + 4',
      type: QuestionType.multipleChoice,
      options: ['x = 3', 'x = 7', 'x = 14', 'x = 2'],
      correctAnswer: 'x = 7',
      explanation:
          'Expand the left side: 5x - 10 = 3x + 4. Subtract 3x from both sides '
          'to get 2x - 10 = 4. Add 10 to both sides: 2x = 14. Divide by 2: x = 7.',
      hints: [
        'Distribute the 5 across both terms inside the bracket.',
        'Collect x terms on one side and constants on the other.',
      ],
      misconceptionRules: [
        MisconceptionRule(
          id: 'math_linear_eq_2_distribution',
          errorCategory: 'conceptual_gap',
          concept: 'Distributing a factor across a bracket',
          triggerAnswers: ['x = 3'],
          hintId: 'hint_math_distribute',
          evidence: [
            'Choosing x = 3 matches expanding 5x - 2 instead of 5x - 10.',
          ],
        ),
        MisconceptionRule(
          id: 'math_linear_eq_2_forgot_divide',
          errorCategory: 'incomplete_reasoning',
          concept: 'Dividing after collecting the x terms',
          triggerAnswers: ['x = 14'],
          evidence: [
            'Choosing x = 14 matches stopping at 2x = 14 without dividing by 2.',
          ],
        ),
        MisconceptionRule(
          id: 'math_linear_eq_2_slip',
          errorCategory: 'careless_slip',
          concept: 'Arithmetic while collecting like terms',
          triggerAnswers: ['x = 2'],
          evidence: ['Choosing x = 2 looks like a small arithmetic slip.'],
        ),
      ],
      followUpIds: ['math_linear_eq_1', 'math_linear_eq_3'],
      difficulty: Difficulty.medium,
    ),
    Question(
      id: 'math_linear_eq_3',
      domain: mathDomain,
      subject: mathSubject,
      topic: mathTopic,
      prompt:
          'The sum of three consecutive integers is 72. What is the largest '
          'of the three integers?',
      type: QuestionType.multipleChoice,
      options: ['23', '24', '25', '26'],
      correctAnswer: '25',
      explanation:
          'Let the integers be x, x + 1 and x + 2. Their sum is 3x + 3 = 72, so '
          '3x = 69 and x = 23. The integers are 23, 24 and 25, so the largest '
          'is 25.',
      hints: [
        'Write the three integers using a single variable x.',
        'The question asks for the largest integer, not the smallest.',
      ],
      misconceptionRules: [
        MisconceptionRule(
          id: 'math_linear_eq_3_smallest',
          errorCategory: 'misread_question',
          concept: 'Identifying the requested quantity',
          triggerAnswers: ['23'],
          evidence: [
            'Choosing 23 gives the smallest integer instead of the largest.',
          ],
        ),
        MisconceptionRule(
          id: 'math_linear_eq_3_middle',
          errorCategory: 'misread_question',
          concept: 'Identifying the requested quantity',
          triggerAnswers: ['24'],
          evidence: [
            'Choosing 24 gives the middle integer instead of the largest.',
          ],
        ),
        MisconceptionRule(
          id: 'math_linear_eq_3_slip',
          errorCategory: 'calculation_slip',
          concept: 'Setting up the sum equation',
          triggerAnswers: ['26'],
          evidence: ['Choosing 26 looks like an arithmetic slip.'],
        ),
      ],
      followUpIds: ['math_linear_eq_2'],
      difficulty: Difficulty.hard,
    ),

    // ---------------- Python: loops and range boundaries ----------------
    Question(
      id: 'python_loops_1',
      domain: pythonDomain,
      subject: pythonSubject,
      topic: pythonTopic,
      prompt: 'What does this print?\n\nfor i in range(3):\n    print(i)',
      type: QuestionType.multipleChoice,
      options: ['0 1 2', '1 2 3', '0 1 2 3', '1 2'],
      correctAnswer: '0 1 2',
      explanation:
          'range(3) produces 0, 1 and 2. It starts at 0 by default and stops '
          'before the value 3, so the loop prints "0 1 2".',
      hints: [
        'range(n) starts at 0 by default.',
        'The stop value is never included in range().',
      ],
      misconceptionRules: [
        MisconceptionRule(
          id: 'python_loops_1_starts_at_one',
          errorCategory: 'boundary_error',
          concept: 'range() starting value',
          triggerAnswers: ['1 2 3'],
          hintId: 'hint_python_range_start',
          evidence: [
            'Choosing "1 2 3" assumes range starts at 1, but it starts at 0.',
          ],
        ),
        MisconceptionRule(
          id: 'python_loops_1_inclusive_stop',
          errorCategory: 'boundary_error',
          concept: 'range() stop value is exclusive',
          triggerAnswers: ['0 1 2 3'],
          hintId: 'hint_python_range_stop',
          evidence: [
            'Choosing "0 1 2 3" includes the stop value, but range(3) stops '
                'before 3.',
          ],
        ),
        MisconceptionRule(
          id: 'python_loops_1_off_by_one',
          errorCategory: 'boundary_error',
          concept: 'Counting loop iterations',
          triggerAnswers: ['1 2'],
          evidence: ['Choosing "1 2" misses the first iteration (i = 0).'],
        ),
      ],
      followUpIds: ['python_loops_1_easier', 'python_loops_2'],
      difficulty: Difficulty.easy,
    ),
    Question(
      id: 'python_loops_1_easier',
      domain: pythonDomain,
      subject: pythonSubject,
      topic: pythonTopic,
      prompt: 'How many times does the loop body run?\n\nfor i in range(2):\n    print(i)',
      type: QuestionType.multipleChoice,
      options: ['2', '1', '3', '0'],
      correctAnswer: '2',
      explanation: 'range(2) produces 0 and 1, so the loop body runs twice.',
      hints: ['range(2) produces the two values 0 and 1.'],
      followUpIds: ['python_loops_1'],
      difficulty: Difficulty.easy,
    ),
    Question(
      id: 'python_loops_2',
      domain: pythonDomain,
      subject: pythonSubject,
      topic: pythonTopic,
      prompt: 'How many times does the loop body run?\n\nfor i in range(2, 8, 2):\n    pass',
      type: QuestionType.multipleChoice,
      options: ['3', '4', '2', '6'],
      correctAnswer: '3',
      explanation:
          'range(2, 8, 2) produces 2, 4 and 6. The stop value 8 is excluded, so '
          'the body runs three times.',
      hints: [
        'Start at 2 and step by 2: 2, 4, 6, ... ',
        'Stop before 8, and remember range excludes the stop value.',
      ],
      misconceptionRules: [
        MisconceptionRule(
          id: 'python_loops_2_inclusive_stop',
          errorCategory: 'boundary_error',
          concept: 'range() excludes the stop value',
          triggerAnswers: ['4'],
          hintId: 'hint_python_range_stop',
          evidence: [
            'Choosing 4 includes the stop value 8 (2, 4, 6, 8), but range '
                'excludes it.',
          ],
        ),
        MisconceptionRule(
          id: 'python_loops_2_count_values',
          errorCategory: 'conceptual_gap',
          concept: 'Iterations versus maximum value',
          triggerAnswers: ['6'],
          evidence: [
            'Choosing 6 reports the last generated value, not the number of '
                'iterations.',
          ],
        ),
        MisconceptionRule(
          id: 'python_loops_2_slip',
          errorCategory: 'careless_slip',
          concept: 'Counting the sequence',
          triggerAnswers: ['2'],
          evidence: ['Choosing 2 looks like a counting slip.'],
        ),
      ],
      followUpIds: ['python_loops_1', 'python_loops_3'],
      difficulty: Difficulty.medium,
    ),
    Question(
      id: 'python_loops_3',
      domain: pythonDomain,
      subject: pythonSubject,
      topic: pythonTopic,
      prompt:
          'What is the LAST value printed by this loop?\n\n'
          'for i in range(1, 10, 3):\n    print(i)',
      type: QuestionType.multipleChoice,
      options: ['7', '10', '9', '4'],
      correctAnswer: '7',
      explanation:
          'range(1, 10, 3) produces 1, 4 and 7. The next value would be 10, '
          'which reaches the stop value, and range() excludes the stop value. '
          'The last printed value is 7.',
      hints: [
        'Generate the sequence: 1, 4, 7, ...',
        'Stop when the next value would reach or pass the stop value.',
      ],
      misconceptionRules: [
        MisconceptionRule(
          id: 'python_loops_3_stop_inclusive',
          errorCategory: 'boundary_error',
          concept: 'range() excludes the stop value',
          triggerAnswers: ['10', '9'],
          hintId: 'hint_python_range_stop',
          evidence: [
            'Choosing 9 or 10 assumes the stop value can be printed, but range '
                'excludes it.',
          ],
        ),
        MisconceptionRule(
          id: 'python_loops_3_stopped_early',
          errorCategory: 'conceptual_gap',
          concept: 'Continuing the arithmetic sequence',
          triggerAnswers: ['4'],
          evidence: ['Choosing 4 stops one step too early.'],
        ),
      ],
      followUpIds: ['python_loops_2'],
      difficulty: Difficulty.hard,
    ),
  ];
}
