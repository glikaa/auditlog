import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.catalogId,
    super.masterQuestionId,
    required super.order,
    required super.category,
    required super.textDe,
    super.textHr,
    super.explanationTextDe,
    super.explanationTextHr,
    super.internalNoteDe,
    super.internalNoteHr,
    super.defaultFindingDe,
    super.defaultFindingHr,
    super.defaultMeasureDe,
    super.defaultMeasureHr,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      catalogId: json['catalog_id'] as String,
      masterQuestionId: json['master_question_id'] as String?,
      order: json['order'] as int,
      category: json['category'] as String,
      textDe: json['text_de'] as String,
      textHr: json['text_hr'] as String?,
      explanationTextDe: json['explanation_text_de'] as String?,
      explanationTextHr: json['explanation_text_hr'] as String?,
      internalNoteDe: json['internal_note_de'] as String?,
      internalNoteHr: json['internal_note_hr'] as String?,
      defaultFindingDe: json['default_finding_de'] as String?,
      defaultFindingHr: json['default_finding_hr'] as String?,
      defaultMeasureDe: json['default_measure_de'] as String?,
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
      'text_de': textDe,
      'text_hr': textHr,
      'explanation_text_de': explanationTextDe,
      'explanation_text_hr': explanationTextHr,
      'internal_note_de': internalNoteDe,
      'internal_note_hr': internalNoteHr,
      'default_finding_de': defaultFindingDe,
      'default_finding_hr': defaultFindingHr,
      'default_measure_de': defaultMeasureDe,
      'default_measure_hr': defaultMeasureHr,
    };
  }
}
