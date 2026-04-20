import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../error/exceptions.dart';

/// Singleton Dio client with auth, logging, and error interceptors.
/// Base URL is read from the app's environment configuration.
class ApiClient {
  ApiClient._({required String baseUrl, required String? authToken})
      : _dio = _buildDio(baseUrl, authToken);

  final Dio _dio;
  static final _log = Logger();

  static ApiClient? _instance;

  /// Call once at app start (e.g. in [main.dart]).
  static void init({required String baseUrl, String? authToken}) {
    _instance = ApiClient._(baseUrl: baseUrl, authToken: authToken);
  }

  static ApiClient get instance {
    assert(_instance != null, 'ApiClient.init() must be called before use.');
    return _instance!;
  }

  Dio get dio => _dio;

  static Dio _buildDio(String baseUrl, String? authToken) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _log.d('[API] ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _log.d('[API] ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (DioException error, handler) {
          _log.e(
            '[API] Error ${error.response?.statusCode}: ${error.message}',
          );
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Maps [DioException] to typed [ServerException] subtypes.
  static Exception mapDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return const UnauthorizedException();
      case 404:
        return NotFoundException(
          message: e.response?.data?['message'] as String? ?? 'Not found',
        );
      default:
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout) {
          return const NetworkException();
        }
        return ServerException(
          message: e.response?.data?['message'] as String? ?? e.message ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
    }
  }
}
