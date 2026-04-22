import '../../domain/entities/audit.dart';

class AuditModel extends Audit {
  const AuditModel({
    required super.id,
    required super.type,
    required super.catalogId,
    required super.branchId,
    required super.branchName,
    required super.auditorId,
    required super.auditorName,
    super.preparerId,
    super.status,
    super.resultPercent,
    super.countYes,
    super.countNo,
    super.countNA,
    super.managementSummary,
    required super.createdAt,
    super.completedAt,
    super.isNachrevision,
    super.linkedAuditId,
    super.acknowledgedAt,
  });

  factory AuditModel.fromJson(Map<String, dynamic> json) {
    return AuditModel(
      id: json['id'] as String,
      type: AuditType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AuditType.filialrevision,
      ),
      catalogId: json['catalog_id'] as String,
      branchId: json['branch_id'] as String,
      branchName: json['branch_name'] as String? ?? '',
      auditorId: json['auditor_id'] as String,
      auditorName: json['auditor_name'] as String? ?? '',
      preparerId: json['preparer_id'] as String?,
      status: AuditStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AuditStatus.draft,
      ),
      resultPercent: (json['result_percent'] as num?)?.toDouble(),
      countYes: json['count_yes'] as int? ?? 0,
      countNo: json['count_no'] as int? ?? 0,
      countNA: json['count_na'] as int? ?? 0,
      managementSummary: json['management_summary'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      isNachrevision: json['is_nachrevision'] as bool? ?? false,
      linkedAuditId: json['linked_audit_id'] as String?,
      acknowledgedAt: json['acknowledged_at'] != null
          ? DateTime.parse(json['acknowledged_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'catalog_id': catalogId,
      'branch_id': branchId,
      'branch_name': branchName,
      'auditor_id': auditorId,
      'auditor_name': auditorName,
      'preparer_id': preparerId,
      'status': status.name,
      'result_percent': resultPercent,
      'count_yes': countYes,
      'count_no': countNo,
      'count_na': countNA,
      'management_summary': managementSummary,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'is_nachrevision': isNachrevision,
      'linked_audit_id': linkedAuditId,
      'acknowledged_at': acknowledgedAt?.toIso8601String(),
    };
  }
}
