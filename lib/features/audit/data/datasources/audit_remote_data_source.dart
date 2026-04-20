import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/audit_model.dart';
import '../models/audit_response_model.dart';
import '../models/question_model.dart';

class AuditRemoteDataSource {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<AuditModel>> getAudits() async {
    try {
      final response = await _dio.get('/audits');
      final list = response.data as List<dynamic>;
      return list
          .map((json) => AuditModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  Future<AuditModel> getAudit(String auditId) async {
    try {
      final response = await _dio.get('/audits/$auditId');
      return AuditModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  Future<AuditModel> createAudit(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/audits', data: data);
      return AuditModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  Future<AuditModel> updateAudit(String auditId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/audits/$auditId', data: data);
      return AuditModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  Future<AuditModel> completeAudit(String auditId) async {
    try {
      final response = await _dio.post('/audits/$auditId/complete');
      return AuditModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  Future<AuditModel> releaseAudit(String auditId) async {
    try {
      final response = await _dio.post('/audits/$auditId/release');
      return AuditModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  Future<List<QuestionModel>> getQuestions(String catalogId) async {
    try {
      final response = await _dio.get('/catalogs/$catalogId/questions');
      final list = response.data as List<dynamic>;
      return list
          .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  Future<List<AuditResponseModel>> getResponses(String auditId) async {
    try {
      final response = await _dio.get('/audits/$auditId/responses');
      final list = response.data as List<dynamic>;
      return list
          .map((json) =>
              AuditResponseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  Future<AuditResponseModel> saveResponse(
    String auditId,
    Map<String, dynamic> data,
  ) async {
    final questionId = data['question_id'] as String;
    try {
      final response = await _dio.put(
        '/audits/$auditId/responses/$questionId',
        data: data,
      );
      return AuditResponseModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }
}
