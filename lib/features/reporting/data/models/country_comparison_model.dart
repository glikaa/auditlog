import '../../domain/entities/country_comparison.dart';

class CountryResultModel extends CountryResult {
  const CountryResultModel({
    required super.countryCode,
    required super.localQuestionId,
    required super.localQuestionOrder,
    required super.yesCount,
    required super.noCount,
    required super.naCount,
  });

  factory CountryResultModel.fromJson(Map<String, dynamic> json) {
    return CountryResultModel(
      countryCode: json['country_code'] as String,
      localQuestionId: json['local_question_id'] as String,
      localQuestionOrder: json['local_question_order'] as int? ?? 0,
      yesCount: json['yes'] as int? ?? 0,
      noCount: json['no'] as int? ?? 0,
      naCount: json['na'] as int? ?? 0,
    );
  }
}

class CountryComparisonModel extends CountryComparison {
  const CountryComparisonModel({
    required super.masterQuestionId,
    required super.masterQuestionText,
    required super.results,
  });

  factory CountryComparisonModel.fromJson(Map<String, dynamic> json) {
    return CountryComparisonModel(
      masterQuestionId: json['master_question_id'] as String,
      masterQuestionText: json['master_question_text'] as String? ?? '',
      results: (json['results'] as List<dynamic>)
          .map((e) => CountryResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
