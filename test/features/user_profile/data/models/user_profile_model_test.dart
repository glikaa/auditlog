import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/features/user_profile/data/models/user_profile_model.dart';
import 'package:my_app/features/user_profile/domain/entities/user_profile.dart';

void main() {
  const tJson = {
    'id': 'user-123',
    'first_name': 'Jane',
    'last_name': 'Doe',
    'email': 'jane.doe@example.com',
    'bio': 'Flutter developer',
    'avatar_url': 'https://example.com/avatar.png',
  };

  const tModel = UserProfileModel(
    id: 'user-123',
    firstName: 'Jane',
    lastName: 'Doe',
    email: 'jane.doe@example.com',
    bio: 'Flutter developer',
    avatarUrl: 'https://example.com/avatar.png',
  );

  group('UserProfileModel', () {
    test('fromJson creates correct model', () {
      final result = UserProfileModel.fromJson(tJson);
      expect(result, tModel);
    });

    test('toJson returns correct map', () {
      expect(tModel.toJson(), tJson);
    });

    test('is a subtype of UserProfile', () {
      expect(tModel, isA<UserProfile>());
    });

    test('fromJson handles null bio and avatarUrl', () {
      final json = Map<String, dynamic>.from(tJson)
        ..remove('bio')
        ..remove('avatar_url');
      final result = UserProfileModel.fromJson(json);
      expect(result.bio, isNull);
      expect(result.avatarUrl, isNull);
    });

    test('fromEntity creates model from domain entity', () {
      const entity = UserProfile(
        id: 'user-123',
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane.doe@example.com',
      );
      final model = UserProfileModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.email, entity.email);
    });
  });
}
