import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_app/core/error/failures.dart';
import 'package:my_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:my_app/features/user_profile/domain/usecases/get_user_profile.dart';
import 'package:my_app/features/user_profile/domain/usecases/update_user_profile.dart';
import 'package:my_app/features/user_profile/domain/usecases/upload_avatar.dart';
import 'package:my_app/features/user_profile/presentation/state/user_profile_cubit.dart';
import 'package:my_app/features/user_profile/presentation/state/user_profile_state.dart';

class MockGetUserProfile extends Mock implements GetUserProfile {}
class MockUpdateUserProfile extends Mock implements UpdateUserProfile {}
class MockUploadAvatar extends Mock implements UploadAvatar {}
class MockImagePicker extends Mock implements ImagePicker {}
class FakeFile extends Fake implements File {}

void main() {
  late UserProfileCubit cubit;
  late MockGetUserProfile mockGet;
  late MockUpdateUserProfile mockUpdate;
  late MockUploadAvatar mockUpload;
  late MockImagePicker mockPicker;

  setUpAll(() => registerFallbackValue(FakeFile()));

  setUp(() {
    mockGet = MockGetUserProfile();
    mockUpdate = MockUpdateUserProfile();
    mockUpload = MockUploadAvatar();
    mockPicker = MockImagePicker();

    cubit = UserProfileCubit(
      getUserProfile: mockGet,
      updateUserProfile: mockUpdate,
      uploadAvatar: mockUpload,
      imagePicker: mockPicker,
    );
  });

  tearDown(() => cubit.close());

  const tUserId = 'user-123';
  const tProfile = UserProfile(
    id: tUserId,
    firstName: 'Jane',
    lastName: 'Doe',
    email: 'jane.doe@example.com',
  );

  group('loadProfile', () {
    blocTest<UserProfileCubit, UserProfileState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(() => mockGet(tUserId))
            .thenAnswer((_) async => const Right(tProfile));
        return cubit;
      },
      act: (c) => c.loadProfile(tUserId),
      expect: () => [
        const UserProfileLoading(),
        const UserProfileLoaded(profile: tProfile),
      ],
    );

    blocTest<UserProfileCubit, UserProfileState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => mockGet(tUserId)).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Oops', statusCode: 500)),
        );
        return cubit;
      },
      act: (c) => c.loadProfile(tUserId),
      expect: () => [
        const UserProfileLoading(),
        const UserProfileError(message: 'Oops'),
      ],
    );
  });

  group('startEditing / cancelEditing', () {
    blocTest<UserProfileCubit, UserProfileState>(
      'startEditing sets isEditing=true',
      build: () => cubit,
      seed: () => const UserProfileLoaded(profile: tProfile),
      act: (c) => c.startEditing(),
      expect: () => [
        const UserProfileLoaded(profile: tProfile, isEditing: true),
      ],
    );

    blocTest<UserProfileCubit, UserProfileState>(
      'cancelEditing sets isEditing=false',
      build: () => cubit,
      seed: () => const UserProfileLoaded(profile: tProfile, isEditing: true),
      act: (c) => c.cancelEditing(),
      expect: () => [
        const UserProfileLoaded(profile: tProfile, isEditing: false),
      ],
    );
  });

  group('saveProfile', () {
    blocTest<UserProfileCubit, UserProfileState>(
      'emits Loaded(saved) on success',
      build: () {
        when(() => mockUpdate(tProfile))
            .thenAnswer((_) async => const Right(tProfile));
        return cubit;
      },
      seed: () => const UserProfileLoaded(profile: tProfile, isEditing: true),
      act: (c) => c.saveProfile(tProfile),
      expect: () => [
        const UserProfileLoaded(profile: tProfile, isEditing: true, isSaving: true),
        const UserProfileLoaded(profile: tProfile, isEditing: false),
      ],
    );
  });
}
