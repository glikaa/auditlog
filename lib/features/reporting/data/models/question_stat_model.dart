import '../../domain/entities/question_stat.dart';

class QuestionStatModel extends QuestionStat {
  const QuestionStatModel({
    required super.questionId,
    required super.questionText,
    required super.yesCount,
    required super.noCount,
    required super.naCount,
  });

  factory QuestionStatModel.fromJson(Map<String, dynamic> json) {
    return QuestionStatModel(
      questionId: json['question_id'] as String,
      questionText: json['question_text'] as String? ?? json['question_id'] as String,
      yesCount: json['yes'] as int? ?? 0,
      noCount: json['no'] as int? ?? 0,
      naCount: json['na'] as int? ?? 0,
    );
  }
}

class Top5ReportModel extends Top5Report {
  const Top5ReportModel({required super.topYes, required super.topNo});

  factory Top5ReportModel.fromJson(Map<String, dynamic> json) {
    return Top5ReportModel(
      topYes: (json['top5_yes'] as List<dynamic>)
          .map((e) => QuestionStatModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      topNo: (json['top5_no'] as List<dynamic>)
          .map((e) => QuestionStatModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
