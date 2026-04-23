import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../audit/data/models/audit_catalog_model.dart';
import '../../audit/data/models/question_model.dart';

class AdminRemoteDataSource {
  Dio get _dio => ApiClient.instance.dio;

  /// Splits a virtual catalog path ID into ``(parentId, version)``.
  ///
  /// ``"catalog-de/versions/2025-v2"`` → ``("catalog-de", "2025-v2")``
  /// ``"catalog-de"``                  → ``("catalog-de", null)``
  static (String, String?) _splitCatalogId(String catalogId) {
    if (catalogId.contains('/versions/')) {
      final parts = catalogId.split('/versions/');
      return (parts[0], parts[1]);
    }
    return (catalogId, null);
  }

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
    final (parentId, version) = _splitCatalogId(catalogId);
    try {
      final response = await _dio.get(
        '/catalogs/$parentId/questions',
        queryParameters: version != null ? {'version': version} : null,
      );
      final list = response.data as List<dynamic>;
      return list
          .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  /// Bulk-update question order values for a catalog (admin only).
  Future<void> reorderQuestions(
    String catalogId,
    List<({String id, int order})> items,
  ) async {
    final (parentId, version) = _splitCatalogId(catalogId);
    try {
      await _dio.patch(
        '/catalogs/$parentId/questions/reorder',
        data: items.map((e) => {'id': e.id, 'order': e.order}).toList(),
        queryParameters: version != null ? {'version': version} : null,
      );
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  /// Create a new audit catalog (admin only).
  Future<AuditCatalogModel> createCatalog({
    required String countryCode,
    required String version,
    required int year,
    required String language,
  }) async {
    try {
      final response = await _dio.post('/catalogs', data: {
        'country_code': countryCode,
        'version': version,
        'year': year,
        'language': language,
      });
      return AuditCatalogModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  /// Clone an existing catalog into a new version stored at
  /// ``auditCatalogs/{parentId}/versions/{year}-{version}``.
  ///
  /// [sourceCatalogId] can be either:
  /// - a top-level catalog id (``catalog-de``) — questions are read from its
  ///   flat ``questions`` subcollection, or
  /// - a version path id (``catalog-de/versions/2025-v1``) — questions are
  ///   read from that version's ``questions`` subcollection (passed as the
  ///   ``base_version`` query parameter to the API).
  Future<AuditCatalogModel> cloneCatalog({
    required String sourceCatalogId,
    required String version,
    required int year,
    required String language,
  }) async {
    // Decompose path IDs like "catalog-de/versions/2025-v1".
    String parentId = sourceCatalogId;
    String? baseVersion;
    if (sourceCatalogId.contains('/versions/')) {
      final parts = sourceCatalogId.split('/versions/');
      parentId = parts[0];
      baseVersion = parts[1];
    }

    try {
      final response = await _dio.post(
        '/catalogs/$parentId/clone',
        data: {'version': version, 'year': year, 'language': language},
        queryParameters: baseVersion != null ? {'base_version': baseVersion} : null,
      );
      return AuditCatalogModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  /// Add a question to a catalog (admin only).
  Future<QuestionModel> createQuestion({
    required String catalogId,
    required int order,
    required String category,
    required String textDe,
    String? textEn,
    String? textHr,
  }) async {
    final (parentId, version) = _splitCatalogId(catalogId);
    try {
      final response = await _dio.post(
        '/catalogs/$parentId/questions',
        data: {
          'catalog_id': catalogId,
          'order': order,
          'category': category,
          'text_de': textDe,
          if (textEn != null && textEn.isNotEmpty) 'text_en': textEn,
          if (textHr != null && textHr.isNotEmpty) 'text_hr': textHr,
        },
        queryParameters: version != null ? {'version': version} : null,
      );
      return QuestionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }
}
