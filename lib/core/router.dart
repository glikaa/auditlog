import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/audit/presentation/screens/audit_detail_screen.dart';
import '../features/audit/presentation/screens/dashboard_screen.dart';

/// Simple named-route based router.
/// Can be upgraded to GoRouter later.
class AppRouter {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String auditDetail = '/audit';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case auditDetail:
        final auditId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AuditDetailScreen(auditId: auditId),
        );

      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
