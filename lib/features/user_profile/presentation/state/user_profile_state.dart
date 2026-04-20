import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

sealed class UserProfileState extends Equatable {
  const UserProfileState();
}

final class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();

  @override
  List<Object?> get props => [];
}

final class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();

  @override
  List<Object?> get props => [];
}

final class UserProfileLoaded extends UserProfileState {
  const UserProfileLoaded({
    required this.profile,
    this.isEditing = false,
    this.isSaving = false,
    this.isUploadingAvatar = false,
  });

  final UserProfile profile;
  final bool isEditing;
  final bool isSaving;
  final bool isUploadingAvatar;

  UserProfileLoaded copyWith({
    UserProfile? profile,
    bool? isEditing,
    bool? isSaving,
    bool? isUploadingAvatar,
  }) {
    return UserProfileLoaded(
      profile: profile ?? this.profile,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
    );
  }

  @override
  List<Object?> get props => [profile, isEditing, isSaving, isUploadingAvatar];
}

final class UserProfileError extends UserProfileState {
  const UserProfileError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// Avatar picker state — emitted as a one-shot event
final class AvatarPickerReady extends UserProfileState {
  const AvatarPickerReady({required this.file, required this.previousState});

  final File file;
  final UserProfileLoaded previousState;

  @override
  List<Object?> get props => [file, previousState];
}
