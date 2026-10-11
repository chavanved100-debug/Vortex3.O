import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'app_theme.dart';
import 'services_scope.dart';

/// Root widget. Wires the theme, service scope and routing.
class LearnLoopApp extends StatelessWidget {
  const LearnLoopApp({super.key, this.services});

  /// Optional injected services (used by tests). Defaults to mock services.
  final AppServices? services;

  @override
  Widget build(BuildContext context) {
    return ServicesScope(
      services: services ?? AppServices.mock(),
      child: MaterialApp(
        title: 'LearnLoop AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
