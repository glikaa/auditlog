import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../features/auth/domain/entities/app_user.dart';
import '../../domain/entities/branch.dart';
import '../state/create_audit_cubit.dart';
import '../state/create_audit_state.dart';

class CreateAuditScreen extends StatefulWidget {
  const CreateAuditScreen({super.key});

  @override
  State<CreateAuditScreen> createState() => _CreateAuditScreenState();
}

class _CreateAuditScreenState extends State<CreateAuditScreen> {
  String? _selectedCatalogId;

  @override
  void initState() {
    super.initState();
    context.read<CreateAuditCubit>().loadFormData();
  }

  void _onBranchChanged(Branch? branch) {
    if (branch == null) return;
    setState(() => _selectedCatalogId = null);
    context.read<CreateAuditCubit>().selectBranch(branch);
  }

  void _onAuditorChanged(AppUser? auditor) {
    if (auditor == null) return;
    context.read<CreateAuditCubit>().selectAuditor(auditor);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newAudit)),
      body: BlocConsumer<CreateAuditCubit, CreateAuditState>(
        listener: (context, state) {
          if (state is CreateAuditSuccess) {
            Navigator.pushReplacementNamed(
              context,
              AppRouter.auditDetail,
              arguments: state.auditId,
            );
          }
        },
        builder: (context, state) {
          if (state is CreateAuditLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CreateAuditLoadError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CreateAuditCubit>().loadFormData(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }
          if (state is CreateAuditFormReady) {
            return _buildForm(context, l10n, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    CreateAuditFormReady state,
  ) {
    final canSubmit = state.selectedBranch != null &&
        _selectedCatalogId != null &&
        state.selectedAuditor != null &&
        !state.isSubmitting &&
        !state.isCatalogsLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step 1: Branch dropdown (always shown first)
          Text(l10n.branch, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<Branch>(
            value: state.selectedBranch,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l10n.selectBranch,
            ),
            items: state.branches
                .map((b) => DropdownMenuItem(
                      value: b,
                      child: Text(b.name),
                    ))
                .toList(),
            onChanged: _onBranchChanged,
          ),
          const SizedBox(height: 24),

          // Step 2: Catalog dropdown (shown after branch selected)
          if (state.selectedBranch != null) ...[
            Text(l10n.auditCatalog, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (state.isCatalogsLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedCatalogId,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: l10n.selectCatalog,
                ),
                items: state.catalogs
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.displayLabel),
                        ))
                    .toList(),
                onChanged: state.catalogs.isNotEmpty
                    ? (v) => setState(() => _selectedCatalogId = v)
                    : null,
              ),
            const SizedBox(height: 24),
          ],

          // Auditor dropdown
          Text(l10n.auditor, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<AppUser>(
            value: state.selectedAuditor,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l10n.selectAuditor,
              prefixIcon: const Icon(Icons.person),
            ),
            items: state.auditors
                .map((u) => DropdownMenuItem(
                      value: u,
                      child: Text(u.name),
                    ))
                .toList(),
            onChanged: state.auditors.isNotEmpty ? _onAuditorChanged : null,
          ),
          const SizedBox(height: 32),

          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),

          ElevatedButton(
            onPressed: canSubmit
                ? () {
                    context.read<CreateAuditCubit>().createAudit(
                          catalogId: _selectedCatalogId!,
                        );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: state.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.createAudit),
          ),
        ],
      ),
    );
  }
}
