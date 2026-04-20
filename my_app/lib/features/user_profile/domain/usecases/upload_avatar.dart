import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/user_profile_repository.dart';

class UploadAvatar {
  const UploadAvatar(this._repository);

  final UserProfileRepository _repository;

  Future<Either<Failure, String>> call({
    required String userId,
    required File imageFile,
  }) =>
      _repository.uploadAvatar(userId: userId, imageFile: imageFile);
}
