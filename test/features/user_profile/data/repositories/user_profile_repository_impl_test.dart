import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_app/core/error/exceptions.dart';
import 'package:my_app/core/error/failures.dart';
import 'package:my_app/features/user_profile/data/datasources/user_profile_local_data_source.dart';
import 'package:my_app/features/user_profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:my_app/features/user_profile/data/models/user_profile_model.dart';
import 'package:my_app/features/user_profile/data/repositories/user_profile_repository_impl.dart';

class MockRemote extends Mock implements UserProfileRemoteDataSource {}
class MockLocal extends Mock implements UserProfileLocalDataSource {}
class FakeFile extends Fake implements File {}
class FakeUserProfileModel extends Fake implements UserProfileModel {}

void main() {
  late UserProfileRepositoryImpl repository;
  late MockRemote mockRemote;
  late MockLocal mockLocal;

  setUpAll(() {
    registerFallbackValue(FakeFile());
    registerFallbackValue(FakeUserProfileModel());
  });

  setUp(() {
    mockRemote = MockRemote();
    mockLocal = MockLocal();
    repository = UserProfileRepositoryImpl(
      remote: mockRemote,
      local: mockLocal,
    );
  });

  const tUserId = 'user-123';
  const tModel = UserProfileModel(
    id: tUserId,
    firstName: 'Jane',
    lastName: 'Doe',
    email: 'jane.doe@example.com',
  );

  group('getUserProfile', () {
    test('returns profile and caches on success', () async {
      when(() => mockRemote.getUserProfile(tUserId))
          .thenAnswer((_) async => tModel);
      when(() => mockLocal.cacheUserProfile(tModel))
          .thenAnswer((_) async {});

      final result = await repository.getUserProfile(tUserId);

      expect(result, const Right(tModel));
      verify(() => mockRemote.getUserProfile(tUserId)).called(1);
      verify(() => mockLocal.cacheUserProfile(tModel)).called(1);
    });

    test('falls back to cache on NetworkException', () async {
      when(() => mockRemote.getUserProfile(tUserId))
          .thenThrow(const NetworkException());
      when(() => mockLocal.getCachedUserProfile(tUserId))
          .thenAnswer((_) async => tModel);

      final result = await repository.getUserProfile(tUserId);

      expect(result, const Right(tModel));
      verify(() => mockLocal.getCachedUserProfile(tUserId)).called(1);
    });

    test('returns CacheFailure when offline and no cache', () async {
      when(() => mockRemote.getUserProfile(tUserId))
          .thenThrow(const NetworkException());
      when(() => mockLocal.getCachedUserProfile(tUserId))
          .thenThrow(const CacheException(message: 'No cache'));

      final result = await repository.getUserProfile(tUserId);

      expect(result, const Left(CacheFailure(message: 'No cache')));
    });

    test('returns UnauthorizedFailure on 401', () async {
      when(() => mockRemote.getUserProfile(tUserId))
          .thenThrow(const UnauthorizedException());

      final result = await repository.getUserProfile(tUserId);

      expect(result, const Left(UnauthorizedFailure()));
    });
  });

  group('updateUserProfile', () {
    test('returns updated profile on success', () async {
      when(() => mockRemote.updateUserProfile(any()))
          .thenAnswer((_) async => tModel);
      when(() => mockLocal.cacheUserProfile(tModel))
          .thenAnswer((_) async {});

      final result = await repository.updateUserProfile(tModel);

      expect(result, const Right(tModel));
    });

    test('returns NetworkFailure when offline', () async {
      when(() => mockRemote.updateUserProfile(any()))
          .thenThrow(const NetworkException());

      final result = await repository.updateUserProfile(tModel);

      expect(result, const Left(NetworkFailure()));
    });
  });
}
