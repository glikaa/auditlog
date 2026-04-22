import 'package:equatable/equatable.dart';

enum Rating { yes, no, na }

/// Nachrevision comparison result.
enum ComparisonResult { improved, worsened, unchanged }

class Attachment extends Equatable {
  final String id;
  final String url;
  final String type; // 'image', 'pdf', or 'document'
  final bool isReportRelevant;
  final String? filename;

  const Attachment({
    required this.id,
    required this.url,
    required this.type,
    this.isReportRelevant = true,
    this.filename,
  });

  @override
  List<Object?> get props => [id, url, type, isReportRelevant, filename];
}

class AuditResponse extends Equatable {
  final String questionId;
  final Rating? rating;
  final String finding; // Feststellung (free text)
  final String measure; // Maßnahme (free text)
  final List<Attachment> attachments;
  final DateTime? updatedAt;

  // Nachrevision fields
  final ComparisonResult? comparisonResult;
  final Rating? previousRating;
  final String? previousFinding;

  const AuditResponse({
    required this.questionId,
    this.rating,
    this.finding = '',
    this.measure = '',
    this.attachments = const [],
    this.updatedAt,
    this.comparisonResult,
    this.previousRating,
    this.previousFinding,
  });

  AuditResponse copyWith({
    String? questionId,
    Rating? rating,
    String? finding,
    String? measure,
    List<Attachment>? attachments,
    DateTime? updatedAt,
    ComparisonResult? comparisonResult,
    Rating? previousRating,
    String? previousFinding,
  }) {
    return AuditResponse(
      questionId: questionId ?? this.questionId,
      rating: rating ?? this.rating,
      finding: finding ?? this.finding,
      measure: measure ?? this.measure,
      attachments: attachments ?? this.attachments,
      updatedAt: updatedAt ?? this.updatedAt,
      comparisonResult: comparisonResult ?? this.comparisonResult,
      previousRating: previousRating ?? this.previousRating,
      previousFinding: previousFinding ?? this.previousFinding,
    );
  }

  @override
  List<Object?> get props => [
        questionId, rating, finding, measure, attachments,
        updatedAt, comparisonResult, previousRating, previousFinding,
      ];
}
