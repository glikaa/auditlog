import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_local_data_source.dart';
import '../datasources/user_profile_remote_data_source.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  const UserProfileRepositoryImpl({
    required UserProfileRemoteDataSource remote,
    required UserProfileLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final UserProfileRemoteDataSource _remote;
  final UserProfileLocalDataSource _local;

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    try {
      final model = await _remote.getUserProfile(userId);
      await _local.cacheUserProfile(model);
      return Right(model);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException {
      // Fall back to cache when offline
      return _getCachedProfile(userId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(
    UserProfile profile,
  ) async {
    try {
      final model = await _remote.updateUserProfile(
        UserProfileModel.fromEntity(profile),
      );
      await _local.cacheUserProfile(model);
      return Right(model);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final url = await _remote.uploadAvatar(
        userId: userId,
        imageFile: imageFile,
      );
      return Right(url);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }

  Future<Either<Failure, UserProfile>> _getCachedProfile(String userId) async {
    try {
      final model = await _local.getCachedUserProfile(userId);
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
