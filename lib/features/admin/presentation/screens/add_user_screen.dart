import 'package:flutter/material.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../data/admin_remote_data_source.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String _role = 'auditor';
  String _language = 'de';
  String _countryCode = 'DE';
  bool _loading = false;
  bool _obscurePassword = true;

  final _dataSource = AdminRemoteDataSource();

  static const _roles = [
    'admin',
    'auditor',
    'preparer',
    'department_head',
    'branch_manager',
    'district_manager',
  ];

  static const _languages = ['de', 'hr', 'en'];

  static const _countries = ['DE', 'AT', 'HR', 'CH'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _roleLabel(AppLocalizations l10n, String role) {
    switch (role) {
      case 'admin':
        return l10n.roleAdmin;
      case 'auditor':
        return l10n.roleAuditor;
      case 'preparer':
        return l10n.rolePreparer;
      case 'department_head':
        return l10n.roleDepartmentHead;
      case 'branch_manager':
        return l10n.roleBranchManager;
      case 'district_manager':
        return l10n.roleDistrictManager;
      default:
        return role;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _dataSource.createUser(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: _role,
        language: _language,
        countryCode: _countryCode,
      );
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.userCreated)),
        );
        Navigator.pop(context);
      }
    } on ServerException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorUnknown),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addUser)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l10n.name),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(labelText: l10n.email),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                  if (!v.contains('@')) return l10n.invalidEmail;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.fieldRequired;
                  if (v.length < 8) return '≥ 8 Zeichen erforderlich';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey(_role),
                initialValue: _role,
                decoration: InputDecoration(labelText: l10n.selectRole),
                items: _roles
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(_roleLabel(l10n, r)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _role = v!),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(_language),
                      initialValue: _language,
                      decoration: InputDecoration(labelText: l10n.language),
                      items: _languages
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _language = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(_countryCode),
                      initialValue: _countryCode,
                      decoration: InputDecoration(labelText: l10n.country),
                      items: _countries
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _countryCode = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
