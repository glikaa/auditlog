import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/network/api_client.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'features/audit/data/datasources/audit_remote_data_source.dart';
import 'features/audit/data/repositories/audit_repository_impl.dart';
import 'features/audit/presentation/state/audit_detail_cubit.dart';
import 'features/audit/presentation/state/audit_list_cubit.dart';
import 'features/reporting/data/datasources/report_remote_data_source.dart';
import 'features/reporting/data/repositories/report_repository_impl.dart';
import 'features/reporting/presentation/state/report_cubit.dart';
import 'features/settings/presentation/state/settings_cubit.dart';
import 'features/settings/presentation/state/settings_state.dart';
import 'generated/l10n/app_localizations.dart';

// Local backend URL – change to production URL before deploy.
const _baseUrl = 'http://127.0.0.1:8000';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiClient.init(baseUrl: _baseUrl);

  runApp(const AuditApp());
}

class AuditApp extends StatelessWidget {
  const AuditApp({super.key});

  @override
  Widget build(BuildContext context) {
    final remoteDataSource = AuditRemoteDataSource();
    final repository = AuditRepositoryImpl(remote: remoteDataSource);
    final reportRemote = ReportRemoteDataSource();
    final reportRepository = ReportRepositoryImpl(remote: reportRemote);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuditListCubit(repository: repository),
        ),
        BlocProvider(
          create: (_) => AuditDetailCubit(repository: repository),
        ),
        BlocProvider(
          create: (_) => SettingsCubit()..init(),
        ),
        BlocProvider(
          create: (_) => ReportCubit(repository: reportRepository),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            title: 'Audit App',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('de'),
              Locale('hr'),
              Locale('en'),
            ],
            locale: settings.locale,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRouter.login,
          );
        },
      ),
    );
  }
}
