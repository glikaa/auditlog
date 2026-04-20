import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_profile_model.dart';

abstract class UserProfileLocalDataSource {
  /// Returns the last cached [UserProfileModel].
  /// Throws [CacheException] if no cached data exists.
  Future<UserProfileModel> getCachedUserProfile(String userId);

  Future<void> cacheUserProfile(UserProfileModel model);
}

class UserProfileLocalDataSourceImpl implements UserProfileLocalDataSource {
  UserProfileLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  final SharedPreferences _prefs;

  static String _key(String userId) => 'user_profile_$userId';

  @override
  Future<UserProfileModel> getCachedUserProfile(String userId) async {
    final json = _prefs.getString(_key(userId));
    if (json == null) {
      throw const CacheException(message: 'No cached profile found.');
    }
    return UserProfileModel.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> cacheUserProfile(UserProfileModel model) async {
    await _prefs.setString(_key(model.id), jsonEncode(model.toJson()));
  }
}
