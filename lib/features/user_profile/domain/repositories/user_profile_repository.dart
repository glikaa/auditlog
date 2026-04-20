import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

/// Abstract contract for user profile data operations.
abstract class UserProfileRepository {
  /// Fetches the profile for the given [userId].
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);

  /// Persists changes to [profile] and returns the updated entity.
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);

  /// Uploads [imageFile] as the avatar for [userId].
  /// Returns the public URL of the new avatar.
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required File imageFile,
  });
}
