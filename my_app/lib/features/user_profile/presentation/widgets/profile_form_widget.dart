import 'package:flutter/material.dart';

import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/user_profile.dart';

/// Editable form for user profile fields.
/// Calls [onSave] with the updated [UserProfile] when the form is valid.
class ProfileFormWidget extends StatefulWidget {
  const ProfileFormWidget({
    required this.profile,
    required this.onSave,
    required this.onCancel,
    this.isSaving = false,
    super.key,
  });

  final UserProfile profile;
  final void Function(UserProfile updatedProfile) onSave;
  final VoidCallback onCancel;
  final bool isSaving;

  @override
  State<ProfileFormWidget> createState() => _ProfileFormWidgetState();
}

class _ProfileFormWidgetState extends State<ProfileFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.profile.firstName);
    _lastNameCtrl = TextEditingController(text: widget.profile.lastName);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _bioCtrl = TextEditingController(text: widget.profile.bio ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(
        widget.profile.copyWith(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _ProfileField(
                  controller: _firstNameCtrl,
                  label: l10n.firstName,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.fieldRequired(l10n.firstName)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfileField(
                  controller: _lastNameCtrl,
                  label: l10n.lastName,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.fieldRequired(l10n.lastName)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProfileField(
            controller: _emailCtrl,
            label: l10n.email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return l10n.fieldRequired(l10n.email);
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              return emailRegex.hasMatch(v.trim()) ? null : l10n.invalidEmail;
            },
          ),
          const SizedBox(height: 16),
          _ProfileField(
            controller: _bioCtrl,
            label: l10n.bio,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.isSaving ? null : widget.onCancel,
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.isSaving ? null : _submit,
                  child: widget.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.saveChanges),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}
