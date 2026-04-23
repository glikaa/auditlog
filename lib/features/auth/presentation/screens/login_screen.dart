import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/router.dart';
import '../../../settings/presentation/state/settings_cubit.dart';
import '../../../../generated/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Staff login
  final _staffFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Branch login
  final _branchFormKey = GlobalKey<FormState>();
  final _branchIdController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _branchIdController.dispose();
    super.dispose();
  }

  Future<void> _loginStaff() async {
    if (!_staffFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = ApiClient.instance.dio;
      final settingsCubit = context.read<SettingsCubit>();
      final navigator = Navigator.of(context);
      final response = await dio.post('/auth/login', data: {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });

      final data = response.data as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>? ?? const {};
      final token = data['access_token'];
      if (token is! String || token.isEmpty) {
        throw Exception('Ungültige Anmeldeantwort: Zugriffstoken fehlt.');
      }
      ApiClient.updateAuthToken(token);

      settingsCubit.setProfile(
        userName: user['name'] as String? ?? '',
        userEmail: user['email'] as String? ?? _emailController.text.trim(),
        userRole: user['role'] as String? ?? '',
        userCountry: user['country_code'] as String? ?? '',
      );

      if (!mounted) return;
      navigator.pushReplacementNamed(AppRouter.dashboard);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['detail'] as String? ?? 'Login fehlgeschlagen';
      if (mounted) setState(() => _errorMessage = msg);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Verbindungsfehler: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginBranch() async {
    if (!_branchFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = ApiClient.instance.dio;
      final settingsCubit = context.read<SettingsCubit>();
      final navigator = Navigator.of(context);
      final response = await dio.post('/auth/branch-login', data: {
        'branch_id': _branchIdController.text.trim(),
      });

      final data = response.data as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>? ?? const {};
      final token = data['access_token'];
      if (token is! String || token.isEmpty) {
        throw Exception('Ungültige Anmeldeantwort: Zugriffstoken fehlt.');
      }
      ApiClient.updateAuthToken(token);

      settingsCubit.setProfile(
        userName: user['name'] as String? ?? '',
        userEmail: '',
        userRole: user['role'] as String? ?? 'branch_manager',
        userCountry: user['country_code'] as String? ?? '',
      );

      if (!mounted) return;
      navigator.pushReplacementNamed(AppRouter.dashboard);
    } on DioException catch (e) {
      final l10n = AppLocalizations.of(context)!;
      final msg = e.response?.statusCode == 401
          ? l10n.branchNotFound
          : (e.response?.data?['detail'] as String? ?? 'Login fehlgeschlagen');
      if (mounted) setState(() => _errorMessage = msg);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Verbindungsfehler: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.loginSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Tab bar
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: l10n.loginTabStaff),
                    Tab(text: l10n.loginTabBranch),
                  ],
                ),
                const SizedBox(height: 16),

                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Tab content
                SizedBox(
                  height: 220,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStaffForm(l10n, theme),
                      _buildBranchForm(l10n, theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffForm(AppLocalizations l10n, ThemeData theme) {
    return Form(
      key: _staffFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: l10n.email,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.fieldRequired;
              if (!value.contains('@')) return l10n.invalidEmail;
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: l10n.password,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.fieldRequired;
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _loginStaff,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.login),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchForm(AppLocalizations l10n, ThemeData theme) {
    return Form(
      key: _branchFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _branchIdController,
            keyboardType: TextInputType.number,
            maxLength: 7,
            decoration: InputDecoration(
              labelText: l10n.branchNumber,
              hintText: l10n.branchNumberHint,
              prefixIcon: const Icon(Icons.store_outlined),
              counterText: '', // hide "0/7" counter
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.fieldRequired;
              }
              if (!RegExp(r'^\d{7}$').hasMatch(value.trim())) {
                return l10n.branchNumberInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _loginBranch,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.branchLogin),
            ),
          ),
        ],
      ),
    );
  }
}
