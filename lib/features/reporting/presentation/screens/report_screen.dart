import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants.dart';
import '../../../../core/router.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/branch_report.dart';
import '../../domain/entities/country_comparison.dart';
import '../../domain/entities/master_question.dart';
import '../../domain/entities/question_stat.dart';
import '../state/report_cubit.dart';
import '../state/report_state.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1 – Branch Results filters
  String? _selectedCountry;

  // Tab 2 – Top-5 filters
  String? _top5Country;
  int? _top5Year;

  // Tab 3 – Country comparison
  final _masterIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Load first tab on start
    context.read<ReportCubit>().loadBranchResults();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final cubit = context.read<ReportCubit>();
    switch (_tabController.index) {
      case 0:
        cubit.loadBranchResults(country: _selectedCountry);
        break;
      case 1:
        cubit.loadTop5(country: _top5Country, year: _top5Year);
        break;
      case 2:
        cubit.loadMasterQuestions();
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _masterIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRouter.dashboard),
        ),
        title: Text(l10n.reporting),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.reportBranchResults),
            Tab(text: l10n.reportTop5),
            Tab(text: l10n.reportCountryComparison),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BranchResultsTab(
            selectedCountry: _selectedCountry,
            onCountryChanged: (c) {
              setState(() => _selectedCountry = c);
              context.read<ReportCubit>().loadBranchResults(country: c);
            },
          ),
          _Top5Tab(
            selectedCountry: _top5Country,
            selectedYear: _top5Year,
            onCountryChanged: (c) {
              setState(() => _top5Country = c);
              context.read<ReportCubit>().loadTop5(
                    country: c,
                    year: _top5Year,
                  );
            },
            onYearChanged: (y) {
              setState(() => _top5Year = y);
              context.read<ReportCubit>().loadTop5(
                    country: _top5Country,
                    year: y,
                  );
            },
          ),
          _CountryComparisonTab(
            controller: _masterIdController,
            onSearch: (id) =>
                context.read<ReportCubit>().loadCountryComparison(id),
            onLoadQuestions: () =>
                context.read<ReportCubit>().loadMasterQuestions(),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 1: Branch Results ─────────────────────────────────────────────────

class _BranchResultsTab extends StatelessWidget {
  final String? selectedCountry;
  final ValueChanged<String?> onCountryChanged;

  const _BranchResultsTab({
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _CountryFilter(
          selected: selectedCountry,
          onChanged: onCountryChanged,
        ),
        Expanded(
          child: BlocBuilder<ReportCubit, ReportState>(
            buildWhen: (_, s) =>
                s is BranchResultsLoaded ||
                s is ReportLoading ||
                s is ReportError,
            builder: (context, state) {
              if (state is ReportLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ReportError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<ReportCubit>()
                      .loadBranchResults(country: selectedCountry),
                );
              }
              if (state is BranchResultsLoaded) {
                if (state.reports.isEmpty) {
                  return Center(child: Text(l10n.reportNoData));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.reports.length,
                  itemBuilder: (_, i) =>
                      _BranchResultCard(report: state.reports[i]),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _BranchResultCard extends StatelessWidget {
  final BranchReport report;

  const _BranchResultCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final latest = report.latestResult;
    final percent = latest != null ? latest / 100.0 : 0.0;
    final latestLabel =
        latest != null ? '${latest.toStringAsFixed(1)} %' : '–';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report.branchName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${l10n.reportLatestResult}: $latestLabel',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                latest == null
                    ? cs.outline
                    : latest >= 80
                        ? Colors.green
                        : latest >= 60
                            ? Colors.orange
                            : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.reportAuditCount}: ${report.entries.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            // Audit history rows
            if (report.entries.isNotEmpty) ...[
              const Divider(height: 16),
              _AuditHistoryTable(entries: report.entries),
            ],
          ],
        ),
      ),
    );
  }
}

class _AuditHistoryTable extends StatelessWidget {
  final List<BranchAuditEntry> entries;

  const _AuditHistoryTable({required this.entries});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sorted = [...entries]
      ..sort((a, b) => (a.completedAt ?? DateTime(0))
          .compareTo(b.completedAt ?? DateTime(0)));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 32,
        dataRowMinHeight: 28,
        dataRowMaxHeight: 36,
        columns: [
          DataColumn(label: Text(l10n.date)),
          DataColumn(label: Text(l10n.result)),
          DataColumn(label: Text(l10n.status)),
        ],
        rows: sorted.map((e) {
          final dateStr = e.completedAt != null
              ? '${e.completedAt!.day.toString().padLeft(2, '0')}.'
                  '${e.completedAt!.month.toString().padLeft(2, '0')}.'
                  '${e.completedAt!.year}'
              : '–';
          final resStr = e.resultPercent != null
              ? '${e.resultPercent!.toStringAsFixed(1)} %'
              : '–';
          return DataRow(cells: [
            DataCell(Text(dateStr)),
            DataCell(Text(resStr)),
            DataCell(Text(e.type)),
          ]);
        }).toList(),
      ),
    );
  }
}

// ─── Tab 2: Top-5 Questions ────────────────────────────────────────────────

class _Top5Tab extends StatelessWidget {
  final String? selectedCountry;
  final int? selectedYear;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<int?> onYearChanged;

  const _Top5Tab({
    required this.selectedCountry,
    required this.selectedYear,
    required this.onCountryChanged,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentYear = DateTime.now().year;
    final years = <int?>[null, currentYear, currentYear - 1, currentYear - 2];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _CountryFilter(
                  selected: selectedCountry,
                  onChanged: onCountryChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  key: ValueKey(selectedYear),
                  initialValue: selectedYear,
                  decoration: InputDecoration(
                    labelText: l10n.reportAllYears,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: years.map((y) {
                    return DropdownMenuItem(
                      value: y,
                      child: Text(y?.toString() ?? l10n.reportAllYears),
                    );
                  }).toList(),
                  onChanged: onYearChanged,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ReportCubit, ReportState>(
            buildWhen: (_, s) =>
                s is Top5Loaded || s is ReportLoading || s is ReportError,
            builder: (context, state) {
              if (state is ReportLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ReportError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () => context.read<ReportCubit>().loadTop5(
                        country: selectedCountry,
                        year: selectedYear,
                      ),
                );
              }
              if (state is Top5Loaded) {
                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _Top5Section(
                      title: l10n.reportTop5YesTitle,
                      stats: state.report.topYes,
                      barColor: Colors.green,
                    ),
                    const SizedBox(height: 24),
                    _Top5Section(
                      title: l10n.reportTop5NoTitle,
                      stats: state.report.topNo,
                      barColor: Colors.red,
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _Top5Section extends StatelessWidget {
  final String title;
  final List<QuestionStat> stats;
  final Color barColor;

  const _Top5Section({
    required this.title,
    required this.stats,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final maxCount =
        stats.isEmpty ? 1 : stats.map((s) => s.yesCount + s.noCount).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 16),
            if (stats.isEmpty)
              Text(l10n.reportNoData)
            else
              ...stats.asMap().entries.map((entry) {
                final idx = entry.key;
                final s = entry.value;
                final count = barColor == Colors.green ? s.yesCount : s.noCount;
                final fraction = maxCount == 0 ? 0.0 : count / maxCount;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${idx + 1}.',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.questionText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text('$count'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: fraction,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 3: Country Comparison ─────────────────────────────────────────────

class _CountryComparisonTab extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final VoidCallback onLoadQuestions;

  const _CountryComparisonTab({
    required this.controller,
    required this.onSearch,
    required this.onLoadQuestions,
  });

  @override
  State<_CountryComparisonTab> createState() => _CountryComparisonTabState();
}

class _CountryComparisonTabState extends State<_CountryComparisonTab> {
  List<MasterQuestion> _masterQuestions = [];
  String? _selectedMasterId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: BlocListener<ReportCubit, ReportState>(
            listenWhen: (_, s) => s is MasterQuestionsLoaded,
            listener: (context, state) {
              if (state is MasterQuestionsLoaded) {
                setState(() => _masterQuestions = state.questions);
              }
            },
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(_selectedMasterId),
                    initialValue: _selectedMasterId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.reportMasterQuestionId,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _masterQuestions.map((mq) {
                      return DropdownMenuItem(
                        value: mq.masterQuestionId,
                        child: Text(
                          mq.textDe,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() => _selectedMasterId = v);
                      if (v != null) widget.onSearch(v);
                    },
                    hint: _masterQuestions.isEmpty
                        ? Text(l10n.reportNoData)
                        : null,
                  ),
                ),
                if (_masterQuestions.isEmpty) ...[
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: widget.onLoadQuestions,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<ReportCubit, ReportState>(
            buildWhen: (_, s) =>
                s is CountryComparisonLoaded ||
                s is ReportLoading ||
                s is ReportError,
            builder: (context, state) {
              if (state is ReportLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ReportError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () {
                    if (_selectedMasterId != null) {
                      widget.onSearch(_selectedMasterId!);
                    }
                  },
                );
              }
              if (state is CountryComparisonLoaded) {
                return _ComparisonResult(comparison: state.comparison);
              }
              return Center(
                child: Text(
                  l10n.reportNoData,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ComparisonResult extends StatelessWidget {
  final CountryComparison comparison;

  const _ComparisonResult({required this.comparison});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comparison.masterQuestionText.isNotEmpty
                      ? comparison.masterQuestionText
                      : comparison.masterQuestionId,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.reportMasterQuestionId}: ${comparison.masterQuestionId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text(l10n.country)),
                      DataColumn(label: Text(l10n.reportLocalQuestionNo)),
                      DataColumn(label: Text(l10n.yes)),
                      DataColumn(label: Text(l10n.no)),
                      DataColumn(label: Text(l10n.notApplicable)),
                      DataColumn(label: Text(l10n.reportYesPercent)),
                    ],
                    rows: comparison.results.map((r) {
                      return DataRow(cells: [
                        DataCell(Text(r.countryCode)),
                        DataCell(Text('${r.localQuestionOrder}')),
                        DataCell(Text('${r.yesCount}')),
                        DataCell(Text('${r.noCount}')),
                        DataCell(Text('${r.naCount}')),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${r.yesPercent.toStringAsFixed(1)} %'),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 60,
                                child: LinearProgressIndicator(
                                  value: r.yesPercent / 100,
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                  backgroundColor: cs.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    r.yesPercent >= 80
                                        ? Colors.green
                                        : r.yesPercent >= 60
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Widgets ────────────────────────────────────────────────────────

class _CountryFilter extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _CountryFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = <String?>[null, ...AppConstants.countries];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String?>(
        initialValue: selected,
        decoration: InputDecoration(
          labelText: l10n.country,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: options.map((c) {
          return DropdownMenuItem(
            value: c,
            child: Text(c ?? l10n.reportAllCountries),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
