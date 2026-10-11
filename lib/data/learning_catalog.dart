import '../models/learning_domain.dart';
import '../models/learning_subject.dart';
import '../models/learning_topic.dart';

/// Single local source of truth for the domain → subject → topic taxonomy.
///
/// Widgets must read from this catalog (or the services built on it) instead of
/// hardcoding lists. It is fully offline and requires no network.
class LearningCatalog {
  const LearningCatalog();

  static const LearningCatalog instance = LearningCatalog();

  /// All subjects, grouped by domain at query time.
  static const List<LearningSubject> subjects = [
    // 1. Mathematics
    LearningSubject(
      id: 'mathematics_algebra',
      domain: LearningDomain.mathematics,
      name: 'Algebra',
      description: 'Equations, expressions and inequalities.',
      isDemoPath: true,
    ),
    LearningSubject(
      id: 'mathematics_calculus',
      domain: LearningDomain.mathematics,
      name: 'Calculus',
      description: 'Limits, derivatives and integrals.',
    ),
    LearningSubject(
      id: 'mathematics_trigonometry',
      domain: LearningDomain.mathematics,
      name: 'Trigonometry',
      description: 'Ratios, identities and triangle rules.',
    ),
    LearningSubject(
      id: 'mathematics_geometry',
      domain: LearningDomain.mathematics,
      name: 'Geometry',
      description: 'Shapes, angles and coordinate geometry.',
    ),
    LearningSubject(
      id: 'mathematics_statistics',
      domain: LearningDomain.mathematics,
      name: 'Probability and Statistics',
      description: 'Chance, data and summary measures.',
    ),
    // 2. Science
    LearningSubject(
      id: 'science_physics',
      domain: LearningDomain.science,
      name: 'Physics',
      description: 'Motion, forces and energy.',
    ),
    LearningSubject(
      id: 'science_chemistry',
      domain: LearningDomain.science,
      name: 'Chemistry',
      description: 'Atoms, bonding and reactions.',
    ),
    LearningSubject(
      id: 'science_biology',
      domain: LearningDomain.science,
      name: 'Biology',
      description: 'Cells, systems and genetics.',
    ),
    LearningSubject(
      id: 'science_environmental',
      domain: LearningDomain.science,
      name: 'Environmental Science',
      description: 'Ecosystems and climate.',
    ),
    // 3. Computer Science & IT
    LearningSubject(
      id: 'computer_science_python',
      domain: LearningDomain.computerScience,
      name: 'Python',
      description: 'Core Python programming.',
      isDemoPath: true,
    ),
    LearningSubject(
      id: 'computer_science_java',
      domain: LearningDomain.computerScience,
      name: 'Java',
      description: 'Object-oriented Java.',
    ),
    LearningSubject(
      id: 'computer_science_c',
      domain: LearningDomain.computerScience,
      name: 'C',
      description: 'Pointers and memory in C.',
    ),
    LearningSubject(
      id: 'computer_science_dsa',
      domain: LearningDomain.computerScience,
      name: 'Data Structures & Algorithms',
      description: 'Arrays, lists and sorting.',
    ),
    LearningSubject(
      id: 'computer_science_dbms',
      domain: LearningDomain.computerScience,
      name: 'DBMS',
      description: 'Relational data and SQL.',
    ),
    LearningSubject(
      id: 'computer_science_os',
      domain: LearningDomain.computerScience,
      name: 'Operating Systems',
      description: 'Processes and scheduling.',
    ),
    LearningSubject(
      id: 'computer_science_aiml',
      domain: LearningDomain.computerScience,
      name: 'AI/ML',
      description: 'Learning from data.',
    ),
    LearningSubject(
      id: 'computer_science_networking',
      domain: LearningDomain.computerScience,
      name: 'Networking',
      description: 'Protocols and layers.',
    ),
    // 4. Competitive Exams
    LearningSubject(
      id: 'competitive_exams_quant',
      domain: LearningDomain.competitiveExams,
      name: 'Quantitative Aptitude',
      description: 'Speed maths and arithmetic.',
    ),
    LearningSubject(
      id: 'competitive_exams_reasoning',
      domain: LearningDomain.competitiveExams,
      name: 'Logical Reasoning',
      description: 'Series, puzzles and deduction.',
    ),
    LearningSubject(
      id: 'competitive_exams_verbal',
      domain: LearningDomain.competitiveExams,
      name: 'Verbal Ability',
      description: 'Grammar and comprehension for exams.',
    ),
    LearningSubject(
      id: 'competitive_exams_mock',
      domain: LearningDomain.competitiveExams,
      name: 'Exam Practice',
      description: 'Timed full-length practice.',
    ),
    // 5. Languages & Communication
    LearningSubject(
      id: 'languages_grammar',
      domain: LearningDomain.languages,
      name: 'Grammar',
      description: 'Tenses, articles and agreement.',
    ),
    LearningSubject(
      id: 'languages_vocabulary',
      domain: LearningDomain.languages,
      name: 'Vocabulary',
      description: 'Word roots, idioms and usage.',
    ),
    LearningSubject(
      id: 'languages_reading',
      domain: LearningDomain.languages,
      name: 'Reading Comprehension',
      description: 'Main idea and inference.',
    ),
    LearningSubject(
      id: 'languages_writing',
      domain: LearningDomain.languages,
      name: 'Writing',
      description: 'Structure, clarity and style.',
    ),
    LearningSubject(
      id: 'languages_communication',
      domain: LearningDomain.languages,
      name: 'Communication Skills',
      description: 'Speaking and listening.',
    ),
    // 6. Humanities & Social Sciences
    LearningSubject(
      id: 'humanities_history',
      domain: LearningDomain.humanities,
      name: 'History',
      description: 'Events, causes and consequences.',
    ),
    LearningSubject(
      id: 'humanities_geography',
      domain: LearningDomain.humanities,
      name: 'Geography',
      description: 'Places, climate and maps.',
    ),
    LearningSubject(
      id: 'humanities_economics',
      domain: LearningDomain.humanities,
      name: 'Economics',
      description: 'Markets, money and trade.',
    ),
    LearningSubject(
      id: 'humanities_civics',
      domain: LearningDomain.humanities,
      name: 'Civics',
      description: 'Citizenship and institutions.',
    ),
    LearningSubject(
      id: 'humanities_political_science',
      domain: LearningDomain.humanities,
      name: 'Political Science',
      description: 'Governance and systems.',
    ),
    // 7. Professional & Practical Skills
    LearningSubject(
      id: 'professional_skills_financial',
      domain: LearningDomain.professionalSkills,
      name: 'Financial Literacy',
      description: 'Budgeting, saving and interest.',
    ),
    LearningSubject(
      id: 'professional_skills_business',
      domain: LearningDomain.professionalSkills,
      name: 'Business Fundamentals',
      description: 'Models and markets.',
    ),
    LearningSubject(
      id: 'professional_skills_workplace',
      domain: LearningDomain.professionalSkills,
      name: 'Workplace Skills',
      description: 'Time management and teamwork.',
    ),
    LearningSubject(
      id: 'professional_skills_digital',
      domain: LearningDomain.professionalSkills,
      name: 'Digital Literacy',
      description: 'Online safety and tools.',
    ),
  ];

  static const List<LearningTopic> topics = [
    // Mathematics → Algebra
    LearningTopic(
      id: 'mathematics_algebra_linear_equations',
      subjectId: 'mathematics_algebra',
      name: 'Linear Equations',
      objective: 'Solve single-variable linear equations accurately.',
      description: 'Balance both sides to isolate the unknown.',
      hasLesson: true,
      isDemoPath: true,
    ),
    LearningTopic(
      id: 'mathematics_algebra_quadratic_equations',
      subjectId: 'mathematics_algebra',
      name: 'Quadratic Equations',
      objective: 'Solve and factorise quadratic equations.',
      description: 'Roots, factoring and the quadratic formula.',
    ),
    LearningTopic(
      id: 'mathematics_algebra_inequalities',
      subjectId: 'mathematics_algebra',
      name: 'Inequalities',
      objective: 'Solve and graph linear inequalities.',
      description: 'Flip the sign when multiplying by a negative.',
    ),
    // Mathematics → Calculus
    LearningTopic(
      id: 'mathematics_calculus_limits',
      subjectId: 'mathematics_calculus',
      name: 'Limits',
      objective: 'Evaluate limits of functions.',
      description: 'Approach behaviour near a point.',
    ),
    LearningTopic(
      id: 'mathematics_calculus_derivatives',
      subjectId: 'mathematics_calculus',
      name: 'Derivatives',
      objective: 'Differentiate common functions.',
      description: 'Rates of change and rules.',
    ),
    LearningTopic(
      id: 'mathematics_calculus_integrals',
      subjectId: 'mathematics_calculus',
      name: 'Integrals',
      objective: 'Integrate basic functions.',
      description: 'Accumulation and area.',
    ),
    // Mathematics → Trigonometry
    LearningTopic(
      id: 'mathematics_trigonometry_ratios',
      subjectId: 'mathematics_trigonometry',
      name: 'Ratios and Identities',
      objective: 'Use trigonometric ratios and identities.',
      description: 'Sine, cosine and tangent relationships.',
    ),
    LearningTopic(
      id: 'mathematics_trigonometry_triangles',
      subjectId: 'mathematics_trigonometry',
      name: 'Triangle Rules',
      objective: 'Apply sine and cosine rules.',
      description: 'Solve non-right triangles.',
    ),
    // Mathematics → Geometry
    LearningTopic(
      id: 'mathematics_geometry_triangles',
      subjectId: 'mathematics_geometry',
      name: 'Triangles',
      objective: 'Apply triangle properties and theorems.',
      description: 'Angles, congruence and similarity.',
    ),
    LearningTopic(
      id: 'mathematics_geometry_circles',
      subjectId: 'mathematics_geometry',
      name: 'Circles',
      objective: 'Use circle theorems.',
      description: 'Chords, tangents and arcs.',
    ),
    LearningTopic(
      id: 'mathematics_geometry_coordinate',
      subjectId: 'mathematics_geometry',
      name: 'Coordinate Geometry',
      objective: 'Work with points, lines and distances.',
      description: 'Gradients, midpoints and equations of lines.',
    ),
    // Mathematics → Probability and Statistics
    LearningTopic(
      id: 'mathematics_statistics_probability',
      subjectId: 'mathematics_statistics',
      name: 'Basic Probability',
      objective: 'Compute simple probabilities.',
      description: 'Favourable outcomes over total outcomes.',
    ),
    LearningTopic(
      id: 'mathematics_statistics_measures',
      subjectId: 'mathematics_statistics',
      name: 'Mean, Median and Mode',
      objective: 'Summarise data with averages.',
      description: 'Central tendency of a data set.',
    ),
    // Science → Physics
    LearningTopic(
      id: 'science_physics_kinematics',
      subjectId: 'science_physics',
      name: 'Kinematics',
      objective: 'Describe motion with equations.',
      description: 'Displacement, velocity and acceleration.',
    ),
    LearningTopic(
      id: 'science_physics_newtons_laws',
      subjectId: 'science_physics',
      name: "Newton's Laws",
      objective: 'Apply Newton\'s three laws of motion.',
      description: 'Forces and motion.',
    ),
    LearningTopic(
      id: 'science_physics_energy',
      subjectId: 'science_physics',
      name: 'Energy',
      objective: 'Apply conservation of energy.',
      description: 'Kinetic and potential energy.',
    ),
    // Science → Chemistry
    LearningTopic(
      id: 'science_chemistry_atomic_structure',
      subjectId: 'science_chemistry',
      name: 'Atomic Structure',
      objective: 'Describe atoms and subatomic particles.',
      description: 'Protons, neutrons and electrons.',
    ),
    LearningTopic(
      id: 'science_chemistry_bonding',
      subjectId: 'science_chemistry',
      name: 'Chemical Bonding',
      objective: 'Explain ionic and covalent bonds.',
      description: 'How atoms combine.',
    ),
    LearningTopic(
      id: 'science_chemistry_acids_bases',
      subjectId: 'science_chemistry',
      name: 'Acids and Bases',
      objective: 'Identify acids, bases and pH.',
      description: 'Neutralisation and indicators.',
    ),
    // Science → Biology
    LearningTopic(
      id: 'science_biology_cells',
      subjectId: 'science_biology',
      name: 'Cell Structure',
      objective: 'Identify cell organelles and functions.',
      description: 'The building blocks of life.',
    ),
    LearningTopic(
      id: 'science_biology_human_body',
      subjectId: 'science_biology',
      name: 'Human Body Systems',
      objective: 'Describe major organ systems.',
      description: 'Circulation, respiration and digestion.',
    ),
    LearningTopic(
      id: 'science_biology_genetics',
      subjectId: 'science_biology',
      name: 'Genetics',
      objective: 'Explain inheritance and DNA.',
      description: 'Genes, alleles and traits.',
    ),
    // Science → Environmental Science
    LearningTopic(
      id: 'science_environmental_ecosystems',
      subjectId: 'science_environmental',
      name: 'Ecosystems',
      objective: 'Describe energy flow in ecosystems.',
      description: 'Food chains and biodiversity.',
    ),
    LearningTopic(
      id: 'science_environmental_climate',
      subjectId: 'science_environmental',
      name: 'Climate Change',
      objective: 'Explain causes and effects of climate change.',
      description: 'Greenhouse gases and impacts.',
    ),
    // Computer Science → Python
    LearningTopic(
      id: 'computer_science_python_basics',
      subjectId: 'computer_science_python',
      name: 'Variables and Data Types',
      objective: 'Store and use values in Python.',
      description: 'Integers, floats, strings and booleans.',
    ),
    LearningTopic(
      id: 'computer_science_python_loops',
      subjectId: 'computer_science_python',
      name: 'Loops and Range',
      objective: 'Control repetition and range boundaries in Python.',
      description: 'for/while loops and the range() function.',
      hasLesson: true,
      isDemoPath: true,
    ),
    LearningTopic(
      id: 'computer_science_python_functions',
      subjectId: 'computer_science_python',
      name: 'Functions',
      objective: 'Define and call functions.',
      description: 'Parameters, returns and scope.',
    ),
    LearningTopic(
      id: 'computer_science_python_collections',
      subjectId: 'computer_science_python',
      name: 'Lists and Dictionaries',
      objective: 'Use Python collections.',
      description: 'Indexing, keys and iteration.',
    ),
    // Computer Science → Java
    LearningTopic(
      id: 'computer_science_java_oop',
      subjectId: 'computer_science_java',
      name: 'OOP Basics',
      objective: 'Apply classes and objects.',
      description: 'Encapsulation and inheritance.',
    ),
    LearningTopic(
      id: 'computer_science_java_collections',
      subjectId: 'computer_science_java',
      name: 'Collections',
      objective: 'Use Java collection types.',
      description: 'Lists, sets and maps.',
    ),
    // Computer Science → C
    LearningTopic(
      id: 'computer_science_c_pointers',
      subjectId: 'computer_science_c',
      name: 'Pointers',
      objective: 'Use pointers and addresses safely.',
      description: 'References and dereferencing.',
    ),
    LearningTopic(
      id: 'computer_science_c_memory',
      subjectId: 'computer_science_c',
      name: 'Memory Management',
      objective: 'Allocate and free memory.',
      description: 'Stack, heap and leaks.',
    ),
    // Computer Science → DSA
    LearningTopic(
      id: 'computer_science_dsa_arrays',
      subjectId: 'computer_science_dsa',
      name: 'Arrays',
      objective: 'Traverse and manipulate arrays.',
      description: 'Indexing and complexity.',
    ),
    LearningTopic(
      id: 'computer_science_dsa_linked_lists',
      subjectId: 'computer_science_dsa',
      name: 'Linked Lists',
      objective: 'Build and traverse linked lists.',
      description: 'Nodes and pointers.',
    ),
    LearningTopic(
      id: 'computer_science_dsa_sorting',
      subjectId: 'computer_science_dsa',
      name: 'Sorting',
      objective: 'Compare sorting algorithms.',
      description: 'Bubble, merge and quick sort.',
    ),
    // Computer Science → DBMS
    LearningTopic(
      id: 'computer_science_dbms_normalization',
      subjectId: 'computer_science_dbms',
      name: 'Normalisation',
      objective: 'Normalise relational schemas.',
      description: 'Reduce redundancy with normal forms.',
    ),
    LearningTopic(
      id: 'computer_science_dbms_sql',
      subjectId: 'computer_science_dbms',
      name: 'SQL Basics',
      objective: 'Write basic SQL queries.',
      description: 'Select, filter and join.',
    ),
    // Computer Science → OS
    LearningTopic(
      id: 'computer_science_os_processes',
      subjectId: 'computer_science_os',
      name: 'Processes',
      objective: 'Explain process states.',
      description: 'Creation, scheduling and termination.',
    ),
    LearningTopic(
      id: 'computer_science_os_scheduling',
      subjectId: 'computer_science_os',
      name: 'Scheduling',
      objective: 'Compare CPU scheduling algorithms.',
      description: 'FCFS, SJF and round robin.',
    ),
    // Computer Science → AI/ML
    LearningTopic(
      id: 'computer_science_aiml_supervised',
      subjectId: 'computer_science_aiml',
      name: 'Supervised Learning',
      objective: 'Distinguish classification and regression.',
      description: 'Learning from labelled data.',
    ),
    LearningTopic(
      id: 'computer_science_aiml_neural_networks',
      subjectId: 'computer_science_aiml',
      name: 'Neural Networks',
      objective: 'Describe basic neural networks.',
      description: 'Layers, weights and activation.',
    ),
    // Computer Science → Networking
    LearningTopic(
      id: 'computer_science_networking_osi',
      subjectId: 'computer_science_networking',
      name: 'OSI Model',
      objective: 'Describe the seven OSI layers.',
      description: 'Layer responsibilities.',
    ),
    LearningTopic(
      id: 'computer_science_networking_tcpip',
      subjectId: 'computer_science_networking',
      name: 'TCP/IP',
      objective: 'Explain the TCP/IP stack.',
      description: 'Addressing and protocols.',
    ),
    // Competitive Exams
    LearningTopic(
      id: 'competitive_exams_quant_percentages',
      subjectId: 'competitive_exams_quant',
      name: 'Percentages',
      objective: 'Solve percentage problems quickly.',
      description: 'Increase, decrease and change.',
    ),
    LearningTopic(
      id: 'competitive_exams_quant_ratios',
      subjectId: 'competitive_exams_quant',
      name: 'Ratios and Proportions',
      objective: 'Apply ratio techniques.',
      description: 'Sharing and scaling.',
    ),
    LearningTopic(
      id: 'competitive_exams_quant_time_work',
      subjectId: 'competitive_exams_quant',
      name: 'Time and Work',
      objective: 'Solve rate-and-work problems.',
      description: 'Combined rates and efficiencies.',
    ),
    LearningTopic(
      id: 'competitive_exams_reasoning_series',
      subjectId: 'competitive_exams_reasoning',
      name: 'Number Series',
      objective: 'Find the next term in a series.',
      description: 'Pattern recognition.',
    ),
    LearningTopic(
      id: 'competitive_exams_reasoning_blood_relations',
      subjectId: 'competitive_exams_reasoning',
      name: 'Blood Relations',
      objective: 'Solve family relationship puzzles.',
      description: 'Mapping relations.',
    ),
    LearningTopic(
      id: 'competitive_exams_reasoning_syllogisms',
      subjectId: 'competitive_exams_reasoning',
      name: 'Syllogisms',
      objective: 'Draw valid conclusions.',
      description: 'Venn-based reasoning.',
    ),
    LearningTopic(
      id: 'competitive_exams_verbal_synonyms',
      subjectId: 'competitive_exams_verbal',
      name: 'Synonyms',
      objective: 'Identify word meanings.',
      description: 'Vocabulary in context.',
    ),
    LearningTopic(
      id: 'competitive_exams_verbal_sentence',
      subjectId: 'competitive_exams_verbal',
      name: 'Sentence Correction',
      objective: 'Correct grammatical errors.',
      description: 'Usage and agreement.',
    ),
    LearningTopic(
      id: 'competitive_exams_mock_full',
      subjectId: 'competitive_exams_mock',
      name: 'Full Mock Practice',
      objective: 'Attempt a timed mixed paper.',
      description: 'Exam-style practice set.',
    ),
    // Languages
    LearningTopic(
      id: 'languages_grammar_tenses',
      subjectId: 'languages_grammar',
      name: 'Tenses',
      objective: 'Use verb tenses correctly.',
      description: 'Past, present and future.',
    ),
    LearningTopic(
      id: 'languages_grammar_articles',
      subjectId: 'languages_grammar',
      name: 'Articles',
      objective: 'Choose a, an and the correctly.',
      description: 'Definite and indefinite articles.',
    ),
    LearningTopic(
      id: 'languages_grammar_agreement',
      subjectId: 'languages_grammar',
      name: 'Subject-Verb Agreement',
      objective: 'Match subjects and verbs.',
      description: 'Number and person agreement.',
    ),
    LearningTopic(
      id: 'languages_vocabulary_roots',
      subjectId: 'languages_vocabulary',
      name: 'Word Roots',
      objective: 'Decode unfamiliar words.',
      description: 'Prefixes, suffixes and roots.',
    ),
    LearningTopic(
      id: 'languages_vocabulary_idioms',
      subjectId: 'languages_vocabulary',
      name: 'Idioms',
      objective: 'Interpret common idioms.',
      description: 'Non-literal meaning.',
    ),
    LearningTopic(
      id: 'languages_reading_main_idea',
      subjectId: 'languages_reading',
      name: 'Main Idea',
      objective: 'Identify the central idea.',
      description: 'Summarising a passage.',
    ),
    LearningTopic(
      id: 'languages_reading_inference',
      subjectId: 'languages_reading',
      name: 'Inference',
      objective: 'Draw supported inferences.',
      description: 'Reading between the lines.',
    ),
    LearningTopic(
      id: 'languages_writing_structure',
      subjectId: 'languages_writing',
      name: 'Essay Structure',
      objective: 'Organise an essay.',
      description: 'Introduction, body and conclusion.',
    ),
    LearningTopic(
      id: 'languages_writing_paragraphs',
      subjectId: 'languages_writing',
      name: 'Paragraph Coherence',
      objective: 'Write coherent paragraphs.',
      description: 'Topic sentences and flow.',
    ),
    LearningTopic(
      id: 'languages_communication_email',
      subjectId: 'languages_communication',
      name: 'Email Etiquette',
      objective: 'Write clear professional emails.',
      description: 'Tone, structure and clarity.',
    ),
    LearningTopic(
      id: 'languages_communication_speaking',
      subjectId: 'languages_communication',
      name: 'Public Speaking',
      objective: 'Present ideas confidently.',
      description: 'Structure and delivery.',
    ),
    // Humanities
    LearningTopic(
      id: 'humanities_history_world_wars',
      subjectId: 'humanities_history',
      name: 'World Wars',
      objective: 'Explain causes and outcomes.',
      description: 'Major global conflicts.',
    ),
    LearningTopic(
      id: 'humanities_history_independence',
      subjectId: 'humanities_history',
      name: 'Indian Independence',
      objective: 'Describe the independence movement.',
      description: 'Key events and figures.',
    ),
    LearningTopic(
      id: 'humanities_geography_climate',
      subjectId: 'humanities_geography',
      name: 'Climatic Zones',
      objective: 'Identify world climate zones.',
      description: 'Weather and vegetation.',
    ),
    LearningTopic(
      id: 'humanities_geography_maps',
      subjectId: 'humanities_geography',
      name: 'Maps and Latitude',
      objective: 'Use latitude and longitude.',
      description: 'Coordinates and time zones.',
    ),
    LearningTopic(
      id: 'humanities_economics_demand_supply',
      subjectId: 'humanities_economics',
      name: 'Demand and Supply',
      objective: 'Explain market equilibrium.',
      description: 'Price signals and shifts.',
    ),
    LearningTopic(
      id: 'humanities_economics_inflation',
      subjectId: 'humanities_economics',
      name: 'Inflation',
      objective: 'Explain causes of inflation.',
      description: 'Money, prices and purchasing power.',
    ),
    LearningTopic(
      id: 'humanities_civics_constitution',
      subjectId: 'humanities_civics',
      name: 'Constitution',
      objective: 'Describe constitutional principles.',
      description: 'Structure of government.',
    ),
    LearningTopic(
      id: 'humanities_civics_rights',
      subjectId: 'humanities_civics',
      name: 'Fundamental Rights',
      objective: 'List fundamental rights.',
      description: 'Rights and duties.',
    ),
    LearningTopic(
      id: 'humanities_political_science_democracy',
      subjectId: 'humanities_political_science',
      name: 'Democracy',
      objective: 'Explain democratic principles.',
      description: 'Elections and representation.',
    ),
    LearningTopic(
      id: 'humanities_political_science_systems',
      subjectId: 'humanities_political_science',
      name: 'Political Systems',
      objective: 'Compare political systems.',
      description: 'Federal, unitary and more.',
    ),
    // Professional & Practical Skills
    LearningTopic(
      id: 'professional_skills_financial_budgeting',
      subjectId: 'professional_skills_financial',
      name: 'Budgeting',
      objective: 'Create and adjust a budget.',
      description: 'Income, expenses and savings.',
    ),
    LearningTopic(
      id: 'professional_skills_financial_interest',
      subjectId: 'professional_skills_financial',
      name: 'Compound Interest',
      objective: 'Compute compound interest.',
      description: 'Growth over time.',
    ),
    LearningTopic(
      id: 'professional_skills_business_models',
      subjectId: 'professional_skills_business',
      name: 'Business Models',
      objective: 'Describe how businesses create value.',
      description: 'Revenue and cost structures.',
    ),
    LearningTopic(
      id: 'professional_skills_business_marketing',
      subjectId: 'professional_skills_business',
      name: 'Marketing Basics',
      objective: 'Explain the marketing mix.',
      description: 'Product, price, place and promotion.',
    ),
    LearningTopic(
      id: 'professional_skills_workplace_time',
      subjectId: 'professional_skills_workplace',
      name: 'Time Management',
      objective: 'Prioritise tasks effectively.',
      description: 'Planning and focus.',
    ),
    LearningTopic(
      id: 'professional_skills_workplace_teamwork',
      subjectId: 'professional_skills_workplace',
      name: 'Teamwork',
      objective: 'Collaborate productively.',
      description: 'Roles, feedback and conflict.',
    ),
    LearningTopic(
      id: 'professional_skills_digital_safety',
      subjectId: 'professional_skills_digital',
      name: 'Online Safety',
      objective: 'Stay safe online.',
      description: 'Passwords, privacy and phishing.',
    ),
    LearningTopic(
      id: 'professional_skills_digital_spreadsheets',
      subjectId: 'professional_skills_digital',
      name: 'Spreadsheets',
      objective: 'Use spreadsheets for basic analysis.',
      description: 'Formulas and charts.',
    ),
  ];

  /// Subjects that belong to [domain].
  List<LearningSubject> subjectsFor(LearningDomain domain) =>
      subjects.where((s) => s.domain == domain).toList(growable: false);

  /// Topics that belong to [subjectId].
  List<LearningTopic> topicsFor(String subjectId) =>
      topics.where((t) => t.subjectId == subjectId).toList(growable: false);

  /// Resolves a subject by id, or null when unknown.
  LearningSubject? subjectById(String? id) {
    if (id == null) return null;
    for (final subject in subjects) {
      if (subject.id == id) return subject;
    }
    return null;
  }

  /// Resolves a topic by id, or null when unknown.
  LearningTopic? topicById(String? id) {
    if (id == null) return null;
    for (final topic in topics) {
      if (topic.id == id) return topic;
    }
    return null;
  }

  /// Topics flagged as the guided demo path.
  List<LearningTopic> get demoTopics =>
      topics.where((t) => t.isDemoPath).toList(growable: false);
}
