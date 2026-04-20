import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/user_profile/data/datasources/user_profile_local_data_source.dart';
import 'features/user_profile/data/datasources/user_profile_remote_data_source.dart';
import 'features/user_profile/data/repositories/user_profile_repository_impl.dart';
import 'features/user_profile/domain/usecases/get_user_profile.dart';
import 'features/user_profile/domain/usecases/update_user_profile.dart';
import 'features/user_profile/domain/usecases/upload_avatar.dart';
import 'features/user_profile/presentation/screens/user_profile_screen.dart';
import 'features/user_profile/presentation/state/user_profile_cubit.dart';
import 'generated/l10n/app_localizations.dart';

// Replace with your real base URL when the API is ready.
const _baseUrl = 'https://api.example.com/v1';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiClient.init(baseUrl: _baseUrl);

  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.prefs, super.key});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    // Dependency injection (manual; swap for get_it/injectable if preferred)
    final remoteDataSource = UserProfileRemoteDataSourceImpl();
    final localDataSource = UserProfileLocalDataSourceImpl(prefs: prefs);
    final repository = UserProfileRepositoryImpl(
      remote: remoteDataSource,
      local: localDataSource,
    );

    return MaterialApp(
      title: 'My App',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider(
        create: (_) => UserProfileCubit(
          getUserProfile: GetUserProfile(repository),
          updateUserProfile: UpdateUserProfile(repository),
          uploadAvatar: UploadAvatar(repository),
        ),
        child: const UserProfileScreen(userId: 'me'),
      ),
    );
  }
}
