import 'package:equatable/equatable.dart';

/// Core domain entity representing a user's profile.
/// Pure Dart — no framework or package dependencies.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.bio,
    this.avatarUrl,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? bio;
  final String? avatarUrl;

  String get fullName => '$firstName $lastName';

  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? bio,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, firstName, lastName, email, bio, avatarUrl];
}
