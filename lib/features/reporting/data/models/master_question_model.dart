import '../../domain/entities/master_question.dart';

class MasterQuestionModel extends MasterQuestion {
  const MasterQuestionModel({
    required super.masterQuestionId,
    required super.textDe,
    required super.countryCount,
  });

  factory MasterQuestionModel.fromJson(Map<String, dynamic> json) {
    return MasterQuestionModel(
      masterQuestionId: json['master_question_id'] as String,
      textDe: json['text_de'] as String? ?? '',
      countryCount: json['country_count'] as int? ?? 0,
    );
  }

  static List<MasterQuestionModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => MasterQuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
