import '../../domain/entities/audit_catalog.dart';

class AuditCatalogModel extends AuditCatalog {
  const AuditCatalogModel({
    required super.id,
    required super.countryCode,
    required super.version,
    required super.year,
    required super.questionCount,
  });

  factory AuditCatalogModel.fromJson(Map<String, dynamic> json) {
    return AuditCatalogModel(
      id: json['id'] as String,
      countryCode: json['country_code'] as String? ?? '',
      version: json['version'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      questionCount: json['question_count'] as int? ?? 0,
    );
  }
}
