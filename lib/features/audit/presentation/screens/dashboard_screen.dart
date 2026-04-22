import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../settings/presentation/state/settings_cubit.dart';
import '../../../settings/presentation/state/settings_state.dart';
import '../../domain/entities/audit.dart';
import '../../domain/repositories/audit_repository.dart';
import '../state/audit_list_cubit.dart';
import '../state/audit_list_state.dart';
import '../state/create_audit_cubit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuditListCubit>().loadAudits();
    context.read<SettingsCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.appTitle),
        actions: [
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settings) {
              const reportRoles = {'department_head', 'branch_manager', 'district_manager'};
              if (reportRoles.contains(settings.userRole)) {
                return IconButton(
                  icon: const Icon(Icons.bar_chart),
                  tooltip: l10n.reporting,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.reports);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.settings);
            },
          ),
        ],
      ),
      body: BlocBuilder<AuditListCubit, AuditListState>(
        builder: (context, state) {
          if (state is AuditListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AuditListError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AuditListCubit>().loadAudits(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }
          if (state is AuditListLoaded) {
            if (state.audits.isEmpty) {
              return Center(child: Text(l10n.noAuditsFound));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.audits.length,
              itemBuilder: (context, index) {
                final audit = state.audits[index];
                return _AuditCard(audit: audit);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          const viewerRoles = {'branch_manager', 'district_manager', 'department_head'};
          final userRole = settings.userRole?.trim();
          if (settings.isLoadingProfile || userRole == null || userRole.isEmpty) {
            return const SizedBox.shrink();
          }
          if (viewerRoles.contains(userRole)) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () {
              final repository = context.read<AuditListCubit>().repository;
              Navigator.pushNamed(
                context,
                AppRouter.createAudit,
                arguments: CreateAuditCubit(repository: repository),
              );
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.newAudit),
          );
        },
      ),
    );
  }
}

class _AuditCard extends StatelessWidget {
  final Audit audit;

  const _AuditCard({required this.audit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(audit.status),
          child: Icon(_statusIcon(audit.status), color: Colors.white, size: 20),
        ),
        title: Row(
          children: [
            Expanded(child: Text(audit.branchName)),
            if (audit.isNachrevision)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Chip(
                  label: Text(l10n.nachrevision, style: const TextStyle(fontSize: 10)),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.deepPurple.shade50,
                ),
              ),
          ],
        ),
        subtitle: Text(
          '${audit.auditorName} • ${_formatDate(audit.createdAt)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((audit.status == AuditStatus.completed ||
                    audit.status == AuditStatus.released) &&
                !audit.isNachrevision)
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settings) {
                  const viewerRoles = {'branch_manager', 'district_manager', 'department_head'};
                  final role = settings.userRole?.trim();
                  if (settings.isLoadingProfile || role == null || role.isEmpty || viewerRoles.contains(role)) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.compare_arrows, size: 20),
                    tooltip: l10n.startNachrevision,
                    onPressed: () => _startNachrevision(context, audit.id),
                  );
                },
              ),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settings) {
                if (settings.userRole == 'admin') {
                  return IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                    tooltip: l10n.deleteAudit,
                    onPressed: () => _deleteAudit(context, audit.id),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            if (audit.resultPercent != null)
              Text(
                '${audit.resultPercent!.toStringAsFixed(1)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _percentColor(audit.resultPercent!),
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              _StatusChip(status: audit.status),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.auditDetail,
            arguments: audit.id,
          );
        },
      ),
    );
  }

  Future<void> _deleteAudit(BuildContext context, String auditId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAudit),
        content: Text(l10n.deleteAuditConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteAudit),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await context.read<AuditListCubit>().deleteAudit(auditId);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.auditDeleted)),
      );
    }
  }

  Future<void> _startNachrevision(BuildContext context, String auditId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.nachrevision),
        content: Text(l10n.startNachrevisionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final newId = await context.read<AuditListCubit>().createNachrevision(auditId);
    if (newId != null && context.mounted) {
      Navigator.pushNamed(context, AppRouter.auditDetail, arguments: newId);
    }
  }

  Color _statusColor(AuditStatus status) {
    switch (status) {
      case AuditStatus.draft:
        return Colors.grey;
      case AuditStatus.inProgress:
        return Colors.orange;
      case AuditStatus.completed:
        return Colors.blue;
      case AuditStatus.released:
        return Colors.green;
    }
  }

  IconData _statusIcon(AuditStatus status) {
    switch (status) {
      case AuditStatus.draft:
        return Icons.edit_note;
      case AuditStatus.inProgress:
        return Icons.play_arrow;
      case AuditStatus.completed:
        return Icons.check;
      case AuditStatus.released:
        return Icons.verified;
    }
  }

  Color _percentColor(double percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final AuditStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Chip(
      label: Text(
        _statusLabel(l10n, status),
        style: const TextStyle(fontSize: 12),
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

String _statusLabel(AppLocalizations l10n, AuditStatus status) {
  switch (status) {
    case AuditStatus.draft:
      return l10n.statusDraft;
    case AuditStatus.inProgress:
      return l10n.statusInProgress;
    case AuditStatus.completed:
      return l10n.statusCompleted;
    case AuditStatus.released:
      return l10n.statusReleased;
  }
}
