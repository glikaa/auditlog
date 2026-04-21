import '../../domain/entities/branch_report.dart';

class BranchAuditEntryModel extends BranchAuditEntry {
  const BranchAuditEntryModel({
    required super.auditId,
    super.resultPercent,
    super.completedAt,
    required super.type,
  });

  factory BranchAuditEntryModel.fromJson(Map<String, dynamic> json) {
    return BranchAuditEntryModel(
      auditId: json['audit_id'] as String,
      resultPercent: (json['result_percent'] as num?)?.toDouble(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      type: json['type'] as String? ?? 'filialrevision',
    );
  }
}

class BranchReportModel extends BranchReport {
  const BranchReportModel({
    required super.branchName,
    required super.entries,
  });

  factory BranchReportModel.fromJson(String branchName, List<dynamic> entries) {
    return BranchReportModel(
      branchName: branchName,
      entries: entries
          .map((e) => BranchAuditEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Parse the map response: { branchName: [entries] }
  static List<BranchReportModel> fromMapJson(Map<String, dynamic> json) {
    return json.entries.map((e) {
      return BranchReportModel.fromJson(e.key, e.value as List<dynamic>);
    }).toList();
  }
}
