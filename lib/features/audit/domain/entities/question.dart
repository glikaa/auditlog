import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String id;
  final String catalogId;
  final String? masterQuestionId; // For cross-country comparison
  final int order;
  final String category;
  final String? categoryEn;
  final String? categoryHr;
  final String textDe;
  final String? textEn;
  final String? textHr;
  final String? explanationTextDe;
  final String? explanationTextEn;
  final String? explanationTextHr;
  final String? internalNoteDe;
  final String? internalNoteEn;
  final String? internalNoteHr;
  final String? defaultFindingDe;
  final String? defaultFindingEn;
  final String? defaultFindingHr;
  final String? defaultMeasureDe;
  final String? defaultMeasureEn;
  final String? defaultMeasureHr;

  const Question({
    required this.id,
    required this.catalogId,
    this.masterQuestionId,
    required this.order,
    required this.category,
    this.categoryEn,
    this.categoryHr,
    required this.textDe,
    this.textEn,
    this.textHr,
    this.explanationTextDe,
    this.explanationTextEn,
    this.explanationTextHr,
    this.internalNoteDe,
    this.internalNoteEn,
    this.internalNoteHr,
    this.defaultFindingDe,
    this.defaultFindingEn,
    this.defaultFindingHr,
    this.defaultMeasureDe,
    this.defaultMeasureEn,
    this.defaultMeasureHr,
  });

  /// Returns the category name in the given language.
  String categoryText(String lang) {
    switch (lang) {
      case 'en': return categoryEn ?? category;
      case 'hr': return categoryHr ?? category;
      default: return category;
    }
  }

  /// Returns the question text in the given language.
  String text(String lang) {
    switch (lang) {
      case 'en': return textEn ?? textDe;
      case 'hr': return textHr ?? textDe;
      default: return textDe;
    }
  }

  /// Returns the explanation text in the given language.
  String? explanationText(String lang) {
    switch (lang) {
      case 'en': return explanationTextEn ?? explanationTextDe;
      case 'hr': return explanationTextHr ?? explanationTextDe;
      default: return explanationTextDe;
    }
  }

  /// Returns the internal note in the given language.
  String? internalNote(String lang) {
    switch (lang) {
      case 'en': return internalNoteEn ?? internalNoteDe;
      case 'hr': return internalNoteHr ?? internalNoteDe;
      default: return internalNoteDe;
    }
  }

  /// Returns the default finding in the given language.
  String? defaultFinding(String lang) {
    switch (lang) {
      case 'en': return defaultFindingEn ?? defaultFindingDe;
      case 'hr': return defaultFindingHr ?? defaultFindingDe;
      default: return defaultFindingDe;
    }
  }

  /// Returns the default measure in the given language.
  String? defaultMeasure(String lang) {
    switch (lang) {
      case 'en': return defaultMeasureEn ?? defaultMeasureDe;
      case 'hr': return defaultMeasureHr ?? defaultMeasureDe;
      default: return defaultMeasureDe;
    }
  }

  @override
  List<Object?> get props => [
        id, catalogId, masterQuestionId, order, category,
        categoryEn, categoryHr,
        textDe, textEn, textHr,
        explanationTextDe, explanationTextEn, explanationTextHr,
        internalNoteDe, internalNoteEn, internalNoteHr,
        defaultFindingDe, defaultFindingEn, defaultFindingHr,
        defaultMeasureDe, defaultMeasureEn, defaultMeasureHr,
      ];
}
