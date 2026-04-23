import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/admin/presentation/screens/add_question_screen.dart';
import '../features/admin/presentation/screens/add_user_screen.dart';
import '../features/admin/presentation/screens/create_catalog_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/audit/presentation/screens/audit_detail_screen.dart';
import '../features/audit/presentation/screens/create_audit_screen.dart';
import '../features/audit/presentation/screens/dashboard_screen.dart';
import '../features/audit/presentation/state/create_audit_cubit.dart';
import '../features/reporting/presentation/screens/report_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

/// Simple named-route based router.
/// Can be upgraded to GoRouter later.
class AppRouter {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String auditDetail = '/audit';
  static const String createAudit = '/audit/new';
  static const String settings = '/settings';
  static const String reports = '/reports';
  static const String adminAddUser = '/admin/add-user';
  static const String adminAddQuestion = '/admin/add-question';
  static const String adminCreateCatalog = '/admin/create-catalog';

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

      case createAudit:
        final cubit = settings.arguments as CreateAuditCubit;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: const CreateAuditScreen(),
          ),
        );

      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case reports:
        return MaterialPageRoute(builder: (_) => const ReportScreen());

      case adminAddUser:
        return MaterialPageRoute(builder: (_) => const AddUserScreen());

      case adminAddQuestion:
        return MaterialPageRoute(builder: (_) => const AddQuestionScreen());

      case adminCreateCatalog:
        return MaterialPageRoute(builder: (_) => const CreateCatalogScreen());

      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
