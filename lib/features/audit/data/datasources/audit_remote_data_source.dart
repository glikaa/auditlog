import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../features/auth/domain/entities/app_user.dart';
import '../../domain/entities/audit_response.dart';
import '../models/audit_catalog_model.dart';
import '../models/audit_model.dart';
import '../models/audit_response_model.dart';
import '../models/branch_model.dart';
import '../models/question_model.dart';

class AuditRemoteDataSource {
  Dio get _dio => ApiClient.instance.dio;

  Future<List<AuditCatalogModel>> getCatalogs({String? country}) async {
    try {
      final response = await _dio.get(
        '/catalogs',
        queryParameters: country != null ? {'country': country} : null,
      );
      final list = response.data as List<dynamic>;
      return list
          .map((json) => AuditCatalogModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  Future<List<BranchModel>> getBranches() async {
    try {
      final response = await _dio.get('/branches');
      final list = response.data as List<dynamic>;
      return list
          .map((json) => BranchModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

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

  /// Delete an audit (admin only).
  Future<void> deleteAudit(String auditId) async {
    try {
      await _dio.delete('/audits/$auditId');
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

  /// Fetch users with role auditor or preparer.
  Future<List<AppUser>> getAuditors() async {
    try {
      final response = await _dio.get(
        '/auth/users',
        queryParameters: {'roles': 'auditor,preparer'},
      );
      final list = response.data as List<dynamic>;
      return list
          .map((json) => _mapUserJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  AppUser _mapUserJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'auditor';
    final role = _parseUserRole(roleStr);
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: role,
      language: json['language'] as String? ?? 'de',
      countryCode: json['country_code'] as String? ?? 'DE',
    );
  }

  UserRole _parseUserRole(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'preparer':
        return UserRole.preparer;
      case 'department_head':
        return UserRole.departmentHead;
      case 'branch_manager':
        return UserRole.branchManager;
      case 'district_manager':
        return UserRole.districtManager;
      default:
        return UserRole.auditor;
    }
  }
}
