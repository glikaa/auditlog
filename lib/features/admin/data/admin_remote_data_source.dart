import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../audit/data/models/audit_catalog_model.dart';
import '../../audit/data/models/question_model.dart';

class AdminRemoteDataSource {
  Dio get _dio => ApiClient.instance.dio;

  /// Create a new user (admin only). Returns the created user id.
  Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String language,
    required String countryCode,
  }) async {
    try {
      final response = await _dio.post('/auth/users', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'language': language,
        'country_code': countryCode,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  /// Fetch all catalogs (for the question catalog picker).
  Future<List<AuditCatalogModel>> getCatalogs() async {
    try {
      final response = await _dio.get('/catalogs');
      final list = response.data as List<dynamic>;
      return list
          .map((json) => AuditCatalogModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  /// Fetch questions for a catalog (to derive next order and existing categories).
  Future<List<QuestionModel>> getQuestionsForCatalog(String catalogId) async {
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

  /// Add a question to a catalog (admin only).
  Future<void> createQuestion({
    required String catalogId,
    required int order,
    required String category,
    required String textDe,
    String? textEn,
    String? textHr,
  }) async {
    try {
      await _dio.post('/catalogs/$catalogId/questions', data: {
        'catalog_id': catalogId,
        'order': order,
        'category': category,
        'text_de': textDe,
        if (textEn != null && textEn.isNotEmpty) 'text_en': textEn,
        if (textHr != null && textHr.isNotEmpty) 'text_hr': textHr,
      });
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }
}
