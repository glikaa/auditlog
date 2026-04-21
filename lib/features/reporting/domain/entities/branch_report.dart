import 'package:equatable/equatable.dart';

/// A single audit result entry for a branch.
class BranchAuditEntry extends Equatable {
  final String auditId;
  final double? resultPercent;
  final DateTime? completedAt;
  final String type; // 'filialrevision' | 'nachrevision'

  const BranchAuditEntry({
    required this.auditId,
    this.resultPercent,
    this.completedAt,
    required this.type,
  });

  @override
  List<Object?> get props => [auditId, resultPercent, completedAt, type];
}

/// Audit results for one branch over time.
class BranchReport extends Equatable {
  final String branchName;
  final List<BranchAuditEntry> entries;

  const BranchReport({required this.branchName, required this.entries});

  /// Most recent result percent, or null.
  double? get latestResult =>
      entries.isEmpty ? null : entries.last.resultPercent;

  @override
  List<Object?> get props => [branchName, entries];
}
