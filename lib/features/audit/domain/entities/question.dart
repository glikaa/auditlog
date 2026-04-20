import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String id;
  final String catalogId;
  final String? masterQuestionId; // For cross-country comparison
  final int order;
  final String category;
  final String textDe;
  final String? textHr;
  final String? explanationTextDe;
  final String? explanationTextHr;
  final String? internalNoteDe;
  final String? internalNoteHr;
  final String? defaultFindingDe;
  final String? defaultFindingHr;
  final String? defaultMeasureDe;
  final String? defaultMeasureHr;

  const Question({
    required this.id,
    required this.catalogId,
    this.masterQuestionId,
    required this.order,
    required this.category,
    required this.textDe,
    this.textHr,
    this.explanationTextDe,
    this.explanationTextHr,
    this.internalNoteDe,
    this.internalNoteHr,
    this.defaultFindingDe,
    this.defaultFindingHr,
    this.defaultMeasureDe,
    this.defaultMeasureHr,
  });

  /// Returns the question text in the given language.
  String text(String lang) => lang == 'hr' ? (textHr ?? textDe) : textDe;

  /// Returns the explanation text in the given language.
  String? explanationText(String lang) =>
      lang == 'hr' ? (explanationTextHr ?? explanationTextDe) : explanationTextDe;

  /// Returns the internal note in the given language.
  String? internalNote(String lang) =>
      lang == 'hr' ? (internalNoteHr ?? internalNoteDe) : internalNoteDe;

  /// Returns the default finding in the given language.
  String? defaultFinding(String lang) =>
      lang == 'hr' ? (defaultFindingHr ?? defaultFindingDe) : defaultFindingDe;

  /// Returns the default measure in the given language.
  String? defaultMeasure(String lang) =>
      lang == 'hr' ? (defaultMeasureHr ?? defaultMeasureDe) : defaultMeasureDe;

  @override
  List<Object?> get props => [
        id, catalogId, masterQuestionId, order, category,
        textDe, textHr, explanationTextDe, explanationTextHr,
        internalNoteDe, internalNoteHr, defaultFindingDe, defaultFindingHr,
        defaultMeasureDe, defaultMeasureHr,
      ];
}
