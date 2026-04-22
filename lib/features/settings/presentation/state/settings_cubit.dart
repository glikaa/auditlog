import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void changeLocale(Locale locale) {
    emit(state.copyWith(locale: locale));
  }

  void changeThemeMode(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }

  void setProfile({
    required String userName,
    required String userEmail,
    required String userRole,
    required String userCountry,
  }) {
    emit(state.copyWith(
      userName: userName,
      userEmail: userEmail,
      userRole: userRole,
      userCountry: userCountry,
      isLoadingProfile: false,
    ));
  }

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoadingProfile: true));
    try {
      final dio = ApiClient.instance.dio;
      final response = await dio.get('/auth/me');
      final data = response.data as Map<String, dynamic>;

      emit(state.copyWith(
        userName: data['name'] as String? ?? '',
        userEmail: data['email'] as String? ?? '',
        userRole: data['role'] as String? ?? '',
        userCountry: data['country_code'] as String? ?? '',
        isLoadingProfile: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingProfile: false));
    }
  }
}
