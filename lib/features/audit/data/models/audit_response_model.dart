import '../../domain/entities/audit_response.dart';

class AuditResponseModel extends AuditResponse {
  const AuditResponseModel({
    required super.questionId,
    super.rating,
    super.finding,
    super.measure,
    super.attachments,
    super.updatedAt,
    super.comparisonResult,
    super.previousRating,
    super.previousFinding,
  });

  factory AuditResponseModel.fromJson(Map<String, dynamic> json) {
    return AuditResponseModel(
      questionId: json['question_id'] as String,
      rating: json['rating'] != null
          ? Rating.values.firstWhere(
              (e) => e.name == json['rating'],
              orElse: () => Rating.na,
            )
          : null,
      finding: json['finding'] as String? ?? '',
      measure: json['measure'] as String? ?? '',
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((a) => Attachment(
                    id: a['id'] as String,
                    url: a['url'] as String,
                    type: a['type'] as String,
                    isReportRelevant: a['is_report_relevant'] as bool? ?? true,
                    filename: a['filename'] as String?,
                    storedName: a['stored_name'] as String?,
                  ))
              .toList() ??
          [],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      comparisonResult: json['comparison_result'] != null
          ? ComparisonResult.values.firstWhere(
              (e) => e.name == json['comparison_result'],
            )
          : null,
      previousRating: json['previous_rating'] != null
          ? Rating.values.firstWhere(
              (e) => e.name == json['previous_rating'],
            )
          : null,
      previousFinding: json['previous_finding'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'rating': rating?.name,
      'finding': finding,
      'measure': measure,
      'attachments': attachments
          .map((a) => {
                'id': a.id,
                'url': a.url,
                'type': a.type,
                'is_report_relevant': a.isReportRelevant,
                'filename': a.filename,
                'stored_name': a.storedName,
              })
          .toList(),
      'updated_at': updatedAt?.toIso8601String(),
      'comparison_result': comparisonResult?.name,
      'previous_rating': previousRating?.name,
      'previous_finding': previousFinding,
    };
  }
}
