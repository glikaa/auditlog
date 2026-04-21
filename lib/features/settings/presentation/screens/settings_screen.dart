import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/router.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../state/settings_cubit.dart';
import '../state/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // --- Profile Section ---
              _SectionHeader(title: l10n.profile),
              if (state.isLoadingProfile)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _ProfileCard(
                  name: state.userName ?? '-',
                  email: state.userEmail ?? '-',
                  role: _translateRole(state.userRole, l10n),
                  country: state.userCountry ?? '-',
                  l10n: l10n,
                  theme: theme,
                ),
              const Divider(),

              // --- Language Section ---
              _SectionHeader(title: l10n.language),
              _LanguageTile(
                title: l10n.german,
                flag: '🇩🇪',
                locale: const Locale('de'),
                current: state.locale,
                onTap: () => _setLocale(const Locale('de')),
              ),
              _LanguageTile(
                title: l10n.croatian,
                flag: '🇭🇷',
                locale: const Locale('hr'),
                current: state.locale,
                onTap: () => _setLocale(const Locale('hr')),
              ),
              _LanguageTile(
                title: l10n.english,
                flag: '🇬🇧',
                locale: const Locale('en'),
                current: state.locale,
                onTap: () => _setLocale(const Locale('en')),
              ),
              const Divider(),

              // --- Appearance Section ---
              _SectionHeader(title: l10n.appearance),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: Text(l10n.darkMode),
                value: state.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  context.read<SettingsCubit>().changeThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                },
              ),
              const Divider(),

              // --- App Info ---
              _SectionHeader(title: l10n.version),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Audit App'),
                subtitle: Text('v1.0.0'),
              ),
              const SizedBox(height: 24),

              // --- Logout ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, l10n),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    l10n.logout,
                    style: const TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _setLocale(Locale locale) {
    context.read<SettingsCubit>().changeLocale(locale);
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.languageChanged), duration: const Duration(seconds: 1)),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ApiClient.updateAuthToken('');
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.login,
                (_) => false,
              );
            },
            child: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _translateRole(String? role, AppLocalizations l10n) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'auditor':
        return 'Prüfer / Revision';
      case 'preparer':
        return 'Vorbereitende Person';
      case 'department_head':
        return 'Abteilungsleitung';
      case 'branch_manager':
        return 'Filialleitung';
      case 'district_manager':
        return 'Bezirksleitung';
      default:
        return role ?? '-';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String country;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _ProfileCard({
    required this.name,
    required this.email,
    required this.role,
    required this.country,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(email, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(role, style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(country, style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final String flag;
  final Locale locale;
  final Locale current;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.flag,
    required this.locale,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = locale == current;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      selected: isSelected,
      onTap: onTap,
    );
  }
}
