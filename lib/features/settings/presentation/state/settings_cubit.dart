import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const _localeKey = 'app_locale';
  static const _themeKey = 'app_theme_mode';

  SettingsCubit() : super(const SettingsState());

  /// Load persisted locale and theme from SharedPreferences.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLocale = prefs.getString(_localeKey);
    final savedTheme = prefs.getString(_themeKey);

    emit(state.copyWith(
      locale: savedLocale != null ? Locale(savedLocale) : null,
      themeMode: _themeModeFromString(savedTheme),
    ));
  }

  void changeLocale(Locale locale) {
    _persistLocale(locale);
    emit(state.copyWith(locale: locale));
  }

  void changeThemeMode(ThemeMode mode) {
    _persistThemeMode(mode);
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
  Future<void> _persistLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> _persistThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  static ThemeMode? _themeModeFromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
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
