# LearnLoop AI — The Wrong Answer Detective

A VORTEXA 3.0 hackathon build. LearnLoop AI is an offline-first learning app that
does not stop at "wrong". When a learner misses a question, it investigates *why*
and adapts the next step to the specific cause — without ever pretending to be
more certain than the evidence allows.

## The problem

Most study apps mark an answer right or wrong and move on. A wrong answer is
treated as one event, when it is really a clue. Did the learner misread the
question, slip on arithmetic, or hold a genuine misconception? Each cause needs a
different response, and guessing wrong demoralises learners.

## What LearnLoop AI does

The core loop is five steps:

1. **Learn** — a short offline lesson: objective, explanation and worked example.
2. **Practise** — a multiple-choice quiz records every attempt honestly.
3. **Diagnose** — the *Wrong Answer Detective* separates what is **certain** (the
   answer differs from the verified answer) from what is **inferred** (a likely
   cause), and asks a clarification question when it is not confident.
4. **Adapt** — the next step is chosen from the diagnosis: a simpler explanation
   and targeted practice, a worked example, a revision exercise, a harder
   challenge, or a clarification request.
5. **Track** — a progress dashboard summarises mastery cautiously and surfaces
   repeated misconceptions and topics that need revision.

## Design principles

- **Offline-first.** Lessons, questions, diagnosis and adaptation all run
  locally. No network or AI service is required to complete the loop.
- **Honest about uncertainty.** An inferred cause is never shown as fact. Low
  confidence routes to a clarification question instead of a guess.
- **Cautious mastery.** A single correct answer is progress, not proof. Mastery
  bands require accumulated evidence.
- **Causality in check.** Pre/post comparisons always show the sample size and a
  note that improvement alone does not prove the app caused it.
- **No blame.** Feedback is supportive and specific.

## Screens

| Screen | Route | Purpose |
| --- | --- | --- |
| Home | `/` | Branding, continue learning, demo paths, all seven domains |
| Subjects | `/subjects` | Subjects within a domain |
| Topics | `/topics` | Topics within a subject; unavailable content is marked |
| Lesson | `/lesson` | Objective, explanation, worked example, hints |
| Quiz | `/quiz` | Multiple-choice practice, records attempts |
| Detective | `/detective` | Wrong-answer diagnosis with certainty separation |
| Adaptive | `/adaptive` | Renders the next-step decision |
| Dashboard | `/dashboard` | Progress, misconceptions, revision, pre/post |

## Architecture

UI, domain logic and data access are kept separate so the same screens work
against mock or real services.

```
lib/
  app/            App shell: theme, routes, typed route args, service scope
  models/         Shared contracts (see below)
  services/       Abstract interfaces the UI depends on
  data/           Offline mock implementations, question/lesson banks, catalog
  screens/        One folder per screen
  widgets/        Reusable presentation widgets
  utils/          Service exceptions
```

Screens never contain diagnosis or adaptation rules; they render results. All
content comes from a single catalog (`lib/data/learning_catalog.dart`) rather
than hardcoded lists.

### Dependency injection

`AppServices` (in `lib/app/services_scope.dart`) is provided through a
`ServicesScope` inherited widget. Screens read interfaces from it, so a real
implementation can replace a mock without touching the UI:

```dart
LearnLoopApp(
  services: AppServices(
    questions: RealQuestionService(),
    diagnosis: RealDiagnosisService(),
    progress: RealProgressService(),
    // ...
  ),
)
```

### Shared contracts

These field names are the team agreement and must not change without a
documented, backward-compatible migration:

- `Question`: id, domain, subject, topic, prompt, type, options, correctAnswer,
  explanation, misconceptionRules, hints, followUpIds, difficulty
- `DiagnosisResult`: concept, errorCategory, evidence, confidence,
  needsClarification, clarificationQuestionId, recommendedHintId
- `AdaptiveDecision`: explanationId, activityType, nextQuestionId, difficulty

Notable decisions:

- `errorCategory` is a free-form `String`, so the real service can introduce new
  categories without a schema change. Unknown categories render neutrally via
  `errorCategoryLabel`.
- `domain`, `subject` and `topic` are `String` ids resolved through the catalog.
- `DiagnosisRequest` and `AdaptiveContext` carry the extra evidence the services
  need. `LearningProgress` / `AttemptRecord` are the coordination models for
  persistence, and additions remain optional for backward compatibility.

## Getting started

Requires Flutter (stable) with the Dart SDK `^3.13.0`.

```powershell
flutter pub get

# Run in a browser (no device required):
flutter run -d chrome

# Run on Android (if a device/emulator is available):
flutter run -d android
```

## Quality gates

```powershell
dart format lib test
flutter analyze   # must report: No issues found!
flutter test      # 73 tests
```

The tests cover the shared models, the offline services, catalog integrity, each
screen's states, and full end-to-end journeys (lesson to quiz to detective to
adaptive, correct and incorrect paths, and graceful handling of missing content).

## Build

```powershell
flutter build apk --debug   # build\app\outputs\flutter-apk\app-debug.apk
flutter build web           # build\web
```

## Content coverage

Fully curated, hand-verified demo content:

- **Mathematics → Algebra → Linear Equations**
- **Python → Loops and Range**

The other domains, subjects and topics are present in the catalog and browse
smoothly; topics without curated content are clearly marked "Content coming
soon" rather than opening empty screens.

## Team ownership

- **Member 1 (this build):** Flutter UI, navigation, reusable widgets, app state,
  screen integration, mock services.
- **Member 2:** diagnosis service (drop-in for `DiagnosisService`).
- **Member 3:** adaptive learning service (drop-in for `AdaptiveLearningService`).
- **Member 4:** persistence (drop-in for `ProgressService`).

The mocks exist precisely so these can be developed and swapped independently.

## License

Built for VORTEXA 3.0. Not for production use.
