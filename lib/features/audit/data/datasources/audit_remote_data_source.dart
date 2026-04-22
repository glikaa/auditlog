import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/audit_response.dart';
import '../models/audit_model.dart';
import '../models/audit_response_model.dart';
import '../models/question_model.dart';

class AuditRemoteDataSource {
  Dio get _dio => ApiClient.instance.dio;

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

  /// Upload an attachment (image/pdf) for a question response.
  Future<Attachment> uploadAttachment({
    required String auditId,
    required String questionId,
    required List<int> fileBytes,
    required String fileName,
    bool isReportRelevant = true,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
        'is_report_relevant': isReportRelevant,
      });
      final response = await _dio.post(
        '/audits/$auditId/responses/$questionId/attachments',
        data: formData,
      );
      final data = response.data as Map<String, dynamic>;
      return Attachment(
        id: data['id'] as String,
        url: data['url'] as String,
        type: data['type'] as String,
        isReportRelevant: data['is_report_relevant'] as bool? ?? true,
        filename: data['filename'] as String?,
      );
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  /// Delete an attachment.
  Future<void> deleteAttachment({
    required String auditId,
    required String questionId,
    required String attachmentId,
  }) async {
    try {
      await _dio.delete(
        '/audits/$auditId/responses/$questionId/attachments/$attachmentId',
      );
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  /// Create a Nachrevision (follow-up audit) based on an existing audit.
  Future<AuditModel> createNachrevision(String auditId) async {
    try {
      final response = await _dio.post('/audits/$auditId/nachrevision');
      return AuditModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }
}
