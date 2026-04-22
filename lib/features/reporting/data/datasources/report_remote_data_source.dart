import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/branch_report_model.dart';
import '../models/country_comparison_model.dart';
import '../models/master_question_model.dart';
import '../models/question_stat_model.dart';

class ReportRemoteDataSource {
  Dio get _dio => ApiClient.instance.dio;

  Future<List<BranchReportModel>> getBranchResults({String? country}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (country != null) queryParams['country'] = country;

      final response = await _dio.get(
        '/reports/branches',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      return BranchReportModel.fromMapJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  Future<Top5ReportModel> getTop5Questions({
    String? country,
    int? year,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (country != null) queryParams['country'] = country;
      if (year != null) queryParams['year'] = year;

      final response = await _dio.get(
        '/reports/questions/top5',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      return Top5ReportModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  Future<CountryComparisonModel> getCountryComparison({
    required String masterQuestionId,
  }) async {
    try {
      final response = await _dio.get(
        '/reports/compare',
        queryParameters: {'master_question_id': masterQuestionId},
      );
      return CountryComparisonModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  Future<List<MasterQuestionModel>> getMasterQuestions() async {
    try {
      final response = await _dio.get('/reports/master-questions');
      return MasterQuestionModel.fromJsonList(response.data as List<dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }
}
