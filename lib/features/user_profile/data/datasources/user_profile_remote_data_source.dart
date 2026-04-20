import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/user_profile_model.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
  Future<UserProfileModel> updateUserProfile(UserProfileModel model);
  Future<String> uploadAvatar({required String userId, required File imageFile});
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  UserProfileRemoteDataSourceImpl({Dio? dio})
      : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  static const _basePath = '/users';

  bool get _usesDemoApi => _dio.options.baseUrl.contains('api.example.com');

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    if (_usesDemoApi) {
      return _demoProfile(userId);
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_basePath/$userId',
      );
      return UserProfileModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel model) async {
    if (_usesDemoApi) {
      return model;
    }

    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '$_basePath/${model.id}',
        data: model.toJson(),
      );
      return UserProfileModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    if (_usesDemoApi) {
      return 'https://ui-avatars.com/api/?name=Demo+User&background=1976d2&color=fff';
    }

    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '$_basePath/$userId/avatar',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data!['avatar_url'] as String;
    } on DioException catch (e) {
      throw ApiClient.mapDioError(e);
    }
  }

  Future<UserProfileModel> _demoProfile(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return UserProfileModel(
      id: userId,
      firstName: 'Max',
      lastName: 'Mustermann',
      email: 'max.mustermann@example.com',
      bio: 'Demo profile until a real backend is connected.',
      avatarUrl:
          'https://ui-avatars.com/api/?name=Max+Mustermann&background=1976d2&color=fff',
    );
  }
}
