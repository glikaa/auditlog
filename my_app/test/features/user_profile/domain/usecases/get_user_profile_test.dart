import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_app/core/error/failures.dart';
import 'package:my_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:my_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:my_app/features/user_profile/domain/usecases/get_user_profile.dart';

class MockUserProfileRepository extends Mock
    implements UserProfileRepository {}

void main() {
  late GetUserProfile useCase;
  late MockUserProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockUserProfileRepository();
    useCase = GetUserProfile(mockRepository);
  });

  const tUserId = 'user-123';
  const tProfile = UserProfile(
    id: tUserId,
    firstName: 'Jane',
    lastName: 'Doe',
    email: 'jane.doe@example.com',
  );

  test('returns UserProfile from repository on success', () async {
    when(() => mockRepository.getUserProfile(tUserId))
        .thenAnswer((_) async => const Right(tProfile));

    final result = await useCase(tUserId);

    expect(result, const Right(tProfile));
    verify(() => mockRepository.getUserProfile(tUserId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns Failure from repository on error', () async {
    const tFailure = ServerFailure(message: 'Server error', statusCode: 500);
    when(() => mockRepository.getUserProfile(tUserId))
        .thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(tUserId);

    expect(result, const Left(tFailure));
    verify(() => mockRepository.getUserProfile(tUserId)).called(1);
  });
}
