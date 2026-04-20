import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class UpdateUserProfile {
  const UpdateUserProfile(this._repository);

  final UserProfileRepository _repository;

  Future<Either<Failure, UserProfile>> call(UserProfile profile) =>
      _repository.updateUserProfile(profile);
}
