import 'package:flutter/material.dart';

import '../models/learning_domain.dart';
import '../models/learning_subject.dart';
import '../models/learning_topic.dart';
import '../screens/adaptive/adaptive_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/detective/detective_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/lesson/lesson_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../screens/subjects/subject_list_screen.dart';
import '../screens/subjects/topic_list_screen.dart';
import '../widgets/state_views.dart';
import 'route_args.dart';

/// Central route name constants. Screens are constructed here so navigation
/// arguments stay typed and in one place.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String subjects = '/subjects';
  static const String topics = '/topics';
  static const String lesson = '/lesson';
  static const String quiz = '/quiz';
  static const String detective = '/detective';
  static const String adaptive = '/adaptive';
  static const String dashboard = '/dashboard';
}

/// Builds routes for the app. Unknown routes and malformed arguments return an
/// offline-friendly placeholder instead of crashing.
class AppRouter {
  const AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.subjects:
        final domain = settings.arguments;
        if (domain is LearningDomain) {
          return MaterialPageRoute(
            builder: (_) => SubjectListScreen(domain: domain),
          );
        }
        return _errorRoute('We could not open that domain.');
      case AppRoutes.topics:
        final subject = settings.arguments;
        if (subject is LearningSubject) {
          return MaterialPageRoute(
            builder: (_) => TopicListScreen(subject: subject),
          );
        }
        return _errorRoute('We could not open that subject.');
      case AppRoutes.lesson:
        final topic = settings.arguments;
        if (topic is LearningTopic) {
          return MaterialPageRoute(builder: (_) => LessonScreen(topic: topic));
        }
        return _errorRoute('We could not open that lesson.');
      case AppRoutes.quiz:
        final args = settings.arguments;
        if (args is QuizArgs) {
          return MaterialPageRoute(builder: (_) => QuizScreen(args: args));
        }
        return _errorRoute('We could not open that quiz.');
      case AppRoutes.detective:
        final args = settings.arguments;
        if (args is DetectiveArgs) {
          return MaterialPageRoute(builder: (_) => DetectiveScreen(args: args));
        }
        return _errorRoute('We could not open the detective.');
      case AppRoutes.adaptive:
        final args = settings.arguments;
        if (args is AdaptiveArgs) {
          return MaterialPageRoute(builder: (_) => AdaptiveScreen(args: args));
        }
        return _errorRoute('We could not open the next step.');
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: SafeArea(child: AppUnavailableView())),
        );
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: AppErrorView(title: 'Navigation error', message: message),
        ),
      ),
    );
  }
}
