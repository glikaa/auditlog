import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/audit.dart';
import '../../domain/entities/question.dart';
import '../state/audit_detail_cubit.dart';
import '../state/audit_detail_state.dart';
import '../widgets/question_card.dart';

class AuditDetailScreen extends StatefulWidget {
  final String auditId;

  const AuditDetailScreen({required this.auditId, super.key});

  @override
  State<AuditDetailScreen> createState() => _AuditDetailScreenState();
}

class _AuditDetailScreenState extends State<AuditDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuditDetailCubit>().loadAudit(widget.auditId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuditDetailCubit, AuditDetailState>(
      builder: (context, state) {
        if (state is AuditDetailLoading) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.auditDetail)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuditDetailError) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.auditDetail)),
            body: Center(child: Text(state.message)),
          );
        }
        if (state is AuditDetailLoaded) {
          return _buildLoaded(context, state, l10n);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    AuditDetailLoaded state,
    AppLocalizations l10n,
  ) {
    final categories = state.questionsByCategory;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.audit.branchName),
        actions: [
          if (state.audit.status == AuditStatus.inProgress)
            TextButton.icon(
              onPressed: () => _completeAudit(context, state.audit.id),
              icon: const Icon(Icons.check),
              label: Text(l10n.completeAudit),
            ),
          if (state.audit.status == AuditStatus.completed)
            TextButton.icon(
              onPressed: () => _releaseAudit(context, state.audit.id),
              icon: const Icon(Icons.verified),
              label: Text(l10n.releaseAudit),
            ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(categories, state, l10n),
        tablet: _buildTabletLayout(categories, state, l10n),
        desktop: _buildTabletLayout(categories, state, l10n),
      ),
    );
  }

  Widget _buildMobileLayout(
    Map<String, List<Question>> categories,
    AuditDetailLoaded state,
    AppLocalizations l10n,
  ) {
    return _buildQuestionList(categories, state, l10n);
  }

  Widget _buildTabletLayout(
    Map<String, List<Question>> categories,
    AuditDetailLoaded state,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        // Left: Audit info panel
        SizedBox(
          width: 300,
          child: _buildAuditInfoPanel(state.audit, l10n),
        ),
        const VerticalDivider(width: 1),
        // Right: Questions list
        Expanded(
          child: _buildQuestionList(categories, state, l10n),
        ),
      ],
    );
  }

  Widget _buildAuditInfoPanel(Audit audit, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.auditInfo, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _InfoRow(label: l10n.branch, value: audit.branchName),
        _InfoRow(label: l10n.auditor, value: audit.auditorName),
        _InfoRow(label: l10n.date, value: _formatDate(audit.createdAt)),
        _InfoRow(label: l10n.status, value: audit.status.name),
        if (audit.resultPercent != null)
          _InfoRow(
            label: l10n.result,
            value: '${audit.resultPercent!.toStringAsFixed(1)}%',
          ),
        const Divider(height: 32),
        Text(l10n.statistics, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _InfoRow(label: l10n.yes, value: '${audit.countYes}'),
        _InfoRow(label: l10n.no, value: '${audit.countNo}'),
        _InfoRow(label: l10n.notApplicable, value: '${audit.countNA}'),
      ],
    );
  }

  Widget _buildQuestionList(
    Map<String, List<Question>> categories,
    AuditDetailLoaded state,
    AppLocalizations l10n,
  ) {
    final entries = categories.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final category = entries[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                category.key,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...category.value.map((question) {
              final response = state.responses[question.id];
              return QuestionCard(
                question: question,
                response: response,
                auditId: state.audit.id,
                isEditable: state.audit.status == AuditStatus.inProgress ||
                    state.audit.status == AuditStatus.draft,
              );
            }),
          ],
        );
      },
    );
  }

  void _completeAudit(BuildContext context, String auditId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.completeAudit),
        content: Text(AppLocalizations.of(context)!.completeAuditConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuditDetailCubit>().completeAudit(auditId);
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  void _releaseAudit(BuildContext context, String auditId) {
    context.read<AuditDetailCubit>().releaseAudit(auditId);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
