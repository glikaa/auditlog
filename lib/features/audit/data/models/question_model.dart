import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.catalogId,
    super.masterQuestionId,
    required super.order,
    required super.category,
    super.categoryEn,
    super.categoryHr,
    super.textDe,
    super.textEn,
    super.textHr,
    super.explanationTextDe,
    super.explanationTextEn,
    super.explanationTextHr,
    super.internalNoteDe,
    super.internalNoteEn,
    super.internalNoteHr,
    super.defaultFindingDe,
    super.defaultFindingEn,
    super.defaultFindingHr,
    super.defaultMeasureDe,
    super.defaultMeasureEn,
    super.defaultMeasureHr,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      catalogId: (json['catalog_id'] as String?) ?? '',
      masterQuestionId: json['master_question_id'] as String?,
      order: (json['order'] as int?) ?? 0,
      category: (json['category'] as String?) ?? '',
      categoryEn: json['category_en'] as String?,
      categoryHr: json['category_hr'] as String?,
      textDe: json['text_de'] as String?,
      textEn: json['text_en'] as String?,
      textHr: json['text_hr'] as String?,
      explanationTextDe: json['explanation_text_de'] as String?,
      explanationTextEn: json['explanation_text_en'] as String?,
      explanationTextHr: json['explanation_text_hr'] as String?,
      internalNoteDe: json['internal_note_de'] as String?,
      internalNoteEn: json['internal_note_en'] as String?,
      internalNoteHr: json['internal_note_hr'] as String?,
      defaultFindingDe: json['default_finding_de'] as String?,
      defaultFindingEn: json['default_finding_en'] as String?,
      defaultFindingHr: json['default_finding_hr'] as String?,
      defaultMeasureDe: json['default_measure_de'] as String?,
      defaultMeasureEn: json['default_measure_en'] as String?,
      defaultMeasureHr: json['default_measure_hr'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'catalog_id': catalogId,
      'master_question_id': masterQuestionId,
      'order': order,
      'category': category,
      'category_en': categoryEn,
      'category_hr': categoryHr,
      'text_de': textDe,
      'text_en': textEn,
      'text_hr': textHr,
      'explanation_text_de': explanationTextDe,
      'explanation_text_en': explanationTextEn,
      'explanation_text_hr': explanationTextHr,
      'internal_note_de': internalNoteDe,
      'internal_note_en': internalNoteEn,
      'internal_note_hr': internalNoteHr,
      'default_finding_de': defaultFindingDe,
      'default_finding_en': defaultFindingEn,
      'default_finding_hr': defaultFindingHr,
      'default_measure_de': defaultMeasureDe,
      'default_measure_en': defaultMeasureEn,
      'default_measure_hr': defaultMeasureHr,
    };
  }
}
