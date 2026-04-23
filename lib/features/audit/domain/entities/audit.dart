import 'package:equatable/equatable.dart';

enum AuditType { filialrevision, nachrevision }

enum AuditStatus { draft, inProgress, completed, released }

class Audit extends Equatable {
  final String id;
  final AuditType type;
  final String catalogId;
  final String branchId;
  final String branchName;
  final String auditorId;
  final String auditorName;
  final String? preparerId;
  final AuditStatus status;
  final double? resultPercent;
  final int countYes;
  final int countNo;
  final int countNA;
  final String? managementSummary;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isNachrevision;
  final String? linkedAuditId; // Reference to original audit for Nachrevision
  final DateTime? acknowledgedAt;

  const Audit({
    required this.id,
    required this.type,
    required this.catalogId,
    required this.branchId,
    required this.branchName,
    required this.auditorId,
    required this.auditorName,
    this.preparerId,
    this.status = AuditStatus.draft,
    this.resultPercent,
    this.countYes = 0,
    this.countNo = 0,
    this.countNA = 0,
    this.managementSummary,
    required this.createdAt,
    this.completedAt,
    this.isNachrevision = false,
    this.linkedAuditId,
    this.acknowledgedAt,
  });

  /// Calculates result: yes / (total - na) * 100
  double get calculatedPercent {
    final total = countYes + countNo;
    if (total == 0) return 0;
    return (countYes / total) * 100;
  }

  Audit copyWith({
    String? id,
    AuditType? type,
    String? catalogId,
    String? branchId,
    String? branchName,
    String? auditorId,
    String? auditorName,
    String? preparerId,
    AuditStatus? status,
    double? resultPercent,
    int? countYes,
    int? countNo,
    int? countNA,
    String? managementSummary,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isNachrevision,
    String? linkedAuditId,
    DateTime? acknowledgedAt,
  }) {
    return Audit(
      id: id ?? this.id,
      type: type ?? this.type,
      catalogId: catalogId ?? this.catalogId,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      auditorId: auditorId ?? this.auditorId,
      auditorName: auditorName ?? this.auditorName,
      preparerId: preparerId ?? this.preparerId,
      status: status ?? this.status,
      resultPercent: resultPercent ?? this.resultPercent,
      countYes: countYes ?? this.countYes,
      countNo: countNo ?? this.countNo,
      countNA: countNA ?? this.countNA,
      managementSummary: managementSummary ?? this.managementSummary,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isNachrevision: isNachrevision ?? this.isNachrevision,
      linkedAuditId: linkedAuditId ?? this.linkedAuditId,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, type, catalogId, branchId, branchName, auditorId, auditorName,
        preparerId, status, resultPercent, countYes, countNo, countNA,
        managementSummary, createdAt, completedAt, isNachrevision, linkedAuditId,
        acknowledgedAt,
      ];
}
