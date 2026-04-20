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
import 'generated/l10n/app_localizations.dart';

// Replace with your real base URL when the API is ready.
const _baseUrl = 'https://api.example.com/v1';

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

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuditListCubit(repository: repository),
        ),
        BlocProvider(
          create: (_) => AuditDetailCubit(repository: repository),
        ),
      ],
      child: MaterialApp(
        title: 'Audit App',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
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
        locale: const Locale('de'),
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRouter.login,
      ),
    );
  }
}
