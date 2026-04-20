import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final Locale locale;
  final ThemeMode themeMode;
  final String? userName;
  final String? userEmail;
  final String? userRole;
  final String? userCountry;
  final bool isLoadingProfile;

  const SettingsState({
    this.locale = const Locale('de'),
    this.themeMode = ThemeMode.system,
    this.userName,
    this.userEmail,
    this.userRole,
    this.userCountry,
    this.isLoadingProfile = false,
  });

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    String? userName,
    String? userEmail,
    String? userRole,
    String? userCountry,
    bool? isLoadingProfile,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userRole: userRole ?? this.userRole,
      userCountry: userCountry ?? this.userCountry,
      isLoadingProfile: isLoadingProfile ?? this.isLoadingProfile,
    );
  }

  @override
  List<Object?> get props => [
        locale,
        themeMode,
        userName,
        userEmail,
        userRole,
        userCountry,
        isLoadingProfile,
      ];
}
