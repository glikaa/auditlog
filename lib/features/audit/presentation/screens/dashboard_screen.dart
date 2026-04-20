import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/audit.dart';
import '../state/audit_list_cubit.dart';
import '../state/audit_list_state.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to create audit
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newAudit),
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

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(audit.status),
          child: Icon(_statusIcon(audit.status), color: Colors.white, size: 20),
        ),
        title: Text(audit.branchName),
        subtitle: Text(
          '${audit.auditorName} • ${_formatDate(audit.createdAt)}',
        ),
        trailing: audit.resultPercent != null
            ? Text(
                '${audit.resultPercent!.toStringAsFixed(1)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _percentColor(audit.resultPercent!),
                  fontWeight: FontWeight.bold,
                ),
              )
            : _StatusChip(status: audit.status),
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
    return Chip(
      label: Text(
        status.name,
        style: const TextStyle(fontSize: 12),
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
