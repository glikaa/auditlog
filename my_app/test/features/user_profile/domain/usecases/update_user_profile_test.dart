import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_app/core/error/failures.dart';
import 'package:my_app/features/user_profile/domain/entities/user_profile.dart';
import 'package:my_app/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:my_app/features/user_profile/domain/usecases/update_user_profile.dart';

class MockUserProfileRepository extends Mock
    implements UserProfileRepository {}

void main() {
  late UpdateUserProfile useCase;
  late MockUserProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockUserProfileRepository();
    useCase = UpdateUserProfile(mockRepository);
  });

  const tProfile = UserProfile(
    id: 'user-123',
    firstName: 'Jane',
    lastName: 'Doe',
    email: 'jane.doe@example.com',
    bio: 'Flutter developer',
  );

  test('returns updated UserProfile on success', () async {
    when(() => mockRepository.updateUserProfile(tProfile))
        .thenAnswer((_) async => const Right(tProfile));

    final result = await useCase(tProfile);

    expect(result, const Right(tProfile));
    verify(() => mockRepository.updateUserProfile(tProfile)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns UnauthorizedFailure when not authenticated', () async {
    when(() => mockRepository.updateUserProfile(tProfile))
        .thenAnswer((_) async => const Left(UnauthorizedFailure()));

    final result = await useCase(tProfile);

    expect(result, const Left(UnauthorizedFailure()));
  });
}
