import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/router.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/audit.dart';
import '../../domain/entities/audit_response.dart';
import '../../domain/entities/question.dart';
import '../../../settings/presentation/state/settings_cubit.dart';
import '../state/audit_detail_cubit.dart';
import '../state/audit_detail_state.dart';
import '../state/audit_list_cubit.dart';
import '../widgets/question_card.dart';

class AuditDetailScreen extends StatefulWidget {
  final String auditId;

  const AuditDetailScreen({required this.auditId, super.key});

  @override
  State<AuditDetailScreen> createState() => _AuditDetailScreenState();
}

class _AuditDetailScreenState extends State<AuditDetailScreen> {
  static const Set<String> _viewerRoles = {
    'branch_manager',
    'district_manager',
    'department_head',
  };

  // Shared keys: both the info-panel TOC and the question list use these.
  final _categoryKeys = <String, GlobalKey>{};
  final _questionScrollController = ScrollController();
  final _questionListKey = GlobalKey();
  late final TextEditingController _managementSummaryController;
  Timer? _managementSummaryDebounce;

  @override
  void initState() {
    super.initState();
    _managementSummaryController = TextEditingController();
    context.read<AuditDetailCubit>().loadAudit(widget.auditId);
  }

  @override
  void dispose() {
    _managementSummaryDebounce?.cancel();
    _managementSummaryController.dispose();
    _questionScrollController.dispose();
    super.dispose();
  }

  void _scrollToCategory(String categoryKey) {
    final targetCtx = _categoryKeys[categoryKey]?.currentContext;
    if (targetCtx == null) return;

    Scrollable.ensureVisible(
      targetCtx,
      alignment: 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  bool _canManageAuditActions({
    required bool isLoadingProfile,
    required String? userRole,
  }) {
    if (isLoadingProfile) return false;
    final trimmedUserRole = userRole?.trim();
    return (trimmedUserRole?.isNotEmpty ?? false) &&
        !_viewerRoles.contains(trimmedUserRole);
  }

  bool _isAuditEditable(Audit audit) {
    return audit.status == AuditStatus.inProgress ||
        audit.status == AuditStatus.draft;
  }

  void _syncManagementSummaryController(Audit audit) {
    final nextText = audit.managementSummary ?? '';
    if (_managementSummaryController.text == nextText) return;

    _managementSummaryController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
  }

  void _onManagementSummaryChanged(Audit audit, String value) {
    _managementSummaryDebounce?.cancel();
    _managementSummaryDebounce = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      context.read<AuditDetailCubit>().saveAudit(
            audit.copyWith(managementSummary: value),
          );
    });
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
    _syncManagementSummaryController(state.audit);
    final categories = state.questionsByCategory;
    final settings = context.select(
      (SettingsCubit cubit) => (
        isLoadingProfile: cubit.state.isLoadingProfile,
        userRole: cubit.state.userRole,
      ),
    );
    final canManageAuditActions = _canManageAuditActions(
      isLoadingProfile: settings.isLoadingProfile,
      userRole: settings.userRole,
    );
    final userRole = settings.userRole?.trim() ?? '';
    final canViewInternalHints =
        userRole == 'auditor' || userRole == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.audit.branchName),
            if (state.audit.isNachrevision)
              Text(
                l10n.nachrevision,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.deepPurple,
                    ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF Export',
            onPressed: () => _exportPdf(context, state.audit.id),
          ),
          if (canManageAuditActions &&
              (state.audit.status == AuditStatus.completed ||
                  state.audit.status == AuditStatus.released) &&
              !state.audit.isNachrevision)
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              tooltip: l10n.startNachrevision,
              onPressed: () => _startNachrevision(context, state.audit.id),
            ),
          if (canManageAuditActions &&
              (state.audit.status == AuditStatus.draft ||
                  state.audit.status == AuditStatus.inProgress))
            TextButton.icon(
              onPressed: () => _completeAudit(context, state.audit.id),
              icon: const Icon(Icons.check),
              label: Text(l10n.completeAudit),
            ),
          if (canManageAuditActions && state.audit.status == AuditStatus.completed)
            TextButton.icon(
              onPressed: () => _releaseAudit(context, state.audit.id),
              icon: const Icon(Icons.verified),
              label: Text(l10n.releaseAudit),
            ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(categories, state, l10n, canViewInternalHints, userRole),
        tablet: _buildTabletLayout(categories, state, l10n, canViewInternalHints, userRole),
        desktop: _buildTabletLayout(categories, state, l10n, canViewInternalHints, userRole),
      ),
    );
  }

  Widget _buildMobileLayout(
    Map<String, List<Question>> categories,
    AuditDetailLoaded state,
    AppLocalizations l10n,
    bool canViewInternalHints,
    String userRole,
  ) {
    return _buildQuestionList(categories, state, l10n,
        canViewInternalHints: canViewInternalHints, userRole: userRole);
  }

  Widget _buildTabletLayout(
    Map<String, List<Question>> categories,
    AuditDetailLoaded state,
    AppLocalizations l10n,
    bool canViewInternalHints,
    String userRole,
  ) {
    return Row(
      children: [
        // Left: Audit info panel
        SizedBox(
          width: 300,
          child: _buildAuditInfoPanel(state.audit, state, l10n, categories),
        ),
        const VerticalDivider(width: 1),
        // Right: Questions list (TOC is in the info panel on tablet/desktop)
        Expanded(
          child: _buildQuestionList(categories, state, l10n,
              showToc: false, canViewInternalHints: canViewInternalHints, userRole: userRole),
        ),
      ],
    );
  }

  Widget _buildAuditInfoPanel(
    Audit audit,
    AuditDetailLoaded state,
    AppLocalizations l10n,
    Map<String, List<Question>> categories,
  ) {
    // Compute live stats from current responses
    int countYes = 0;
    int countNo = 0;
    int countNA = 0;
    for (final r in state.responses.values) {
      switch (r.rating) {
        case Rating.yes:
          countYes++;
          break;
        case Rating.no:
          countNo++;
          break;
        case Rating.na:
          countNA++;
          break;
        default:
          break;
      }
    }
    final totalRated = countYes + countNo;
    final livePercent = totalRated > 0 ? (countYes / totalRated * 100) : 0.0;
    final answered = countYes + countNo + countNA;
    final total = state.questions.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.auditInfo, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _InfoRow(label: l10n.branch, value: audit.branchName),
        _InfoRow(label: l10n.auditor, value: audit.auditorName),
        _InfoRow(label: l10n.date, value: _formatDate(audit.createdAt)),
        _InfoRow(label: l10n.status, value: _statusLabel(l10n, audit.status)),
        const Divider(height: 32),
        Text(l10n.statistics, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _InfoRow(label: l10n.yes, value: '$countYes'),
        _InfoRow(label: l10n.no, value: '$countNo'),
        _InfoRow(label: l10n.notApplicable, value: '$countNA'),
        const Divider(height: 16),
        _InfoRow(
          label: l10n.answered,
          value: '$answered / $total',
        ),
        _InfoRow(
          label: l10n.result,
          value: '${livePercent.toStringAsFixed(1)}%',
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: total > 0 ? answered / total : 0,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const Divider(height: 32),
        // Table of Contents
        Row(
          children: [
            const Icon(Icons.list_alt, size: 18),
            const SizedBox(width: 8),
            Text(
              l10n.tableOfContents,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...categories.entries.map((entry) {
          final label = entry.value.first
              .categoryText(Localizations.localeOf(context).languageCode);
          return InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              _scrollToCategory(entry.key);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  Text(
                    '${entry.value.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuestionList(
    Map<String, List<Question>> categories,
    AuditDetailLoaded state,
    AppLocalizations l10n, {
    bool showToc = true,
    bool canViewInternalHints = false,
    String userRole = '',
  }) {
    final entries = categories.entries.toList();
    final lang = Localizations.localeOf(context).languageCode;

    // Pre-register all keys so they exist before any TOC tap fires.
    for (final entry in entries) {
      _categoryKeys.putIfAbsent(entry.key, () => GlobalKey());
    }

    // Non-lazy ListView – cacheExtent forces all sections to be laid out
    // so that localToGlobal works for every category from any scroll position.
    return ListView(
      key: _questionListKey,
      controller: _questionScrollController,
      cacheExtent: double.infinity,
      padding: const EdgeInsets.all(16),
      children: [
        // --- Table of Contents (mobile only) ---
        if (showToc)
          Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.list_alt, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        l10n.tableOfContents,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...entries.map((entry) {
                    final label = entry.value.first.categoryText(lang);
                    return InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        _scrollToCategory(entry.key);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_right, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                label,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                              ),
                            ),
                            Text(
                              '${entry.value.length}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

        // --- Category sections ---
        ...entries.map((entry) {
          final categoryLabel = entry.value.first.categoryText(lang);
          final sectionKey = _categoryKeys[entry.key]!;
          return Column(
            key: sectionKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  categoryLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ...entry.value.map((question) {
                final response = state.responses[question.id];
                return QuestionCard(
                  question: question,
                  response: response,
                  auditId: state.audit.id,
                  canViewInternalHints: canViewInternalHints,
                  isEditable: _isAuditEditable(state.audit),
                );
              }),
            ],
          );
        }),
        const SizedBox(height: 12),
        _ManagementSummaryCard(
          controller: _managementSummaryController,
          isEditable: _isAuditEditable(state.audit),
          label: l10n.auditClosingNote,
          hintText: l10n.auditClosingNoteHint,
          onChanged: (value) => _onManagementSummaryChanged(state.audit, value),
        ),
        // Acknowledge button for branch managers on released, unacknowledged audits
        if (userRole == 'branch_manager' &&
            state.audit.status == AuditStatus.released &&
            state.audit.acknowledgedAt == null)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<AuditDetailCubit>()
                      .acknowledgeAudit(state.audit.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.auditAcknowledged)),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: Text(l10n.acknowledgeAuditButton),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
      ],
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
      Navigator.pushReplacementNamed(
        context,
        AppRouter.auditDetail,
        arguments: newId,
      );
    }
  }

  Future<void> _exportPdf(BuildContext context, String auditId) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.pdfCreating)),
    );

    try {
      final dio = ApiClient.instance.dio;
      final response = await dio.get(
        '/audits/$auditId/export/pdf',
        options: Options(responseType: ResponseType.bytes),
      );

      // Trigger download in browser
      final bytes = response.data as List<int>;
      final uint8Array = Uint8List.fromList(bytes);
      final blob = web.Blob(
        [uint8Array.buffer.toJS].toJS,
        web.BlobPropertyBag(type: 'application/pdf'),
      );
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.setAttribute('download', 'audit-$auditId.pdf');
      anchor.click();
      web.URL.revokeObjectURL(url);

      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.pdfDownloaded)),
      );
    } catch (e) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.pdfExportFailed}: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
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
}

class _ManagementSummaryCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditable;
  final String label;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _ManagementSummaryCard({
    required this.controller,
    required this.isEditable,
    required this.label,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              enabled: isEditable,
              decoration: InputDecoration(
                labelText: label,
                hintText: hintText,
                alignLabelWithHint: true,
              ),
              maxLines: null,
              minLines: 4,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
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
