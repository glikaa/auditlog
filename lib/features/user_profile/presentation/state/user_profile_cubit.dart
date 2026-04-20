import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/upload_avatar.dart';
import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit({
    required GetUserProfile getUserProfile,
    required UpdateUserProfile updateUserProfile,
    required UploadAvatar uploadAvatar,
    ImagePicker? imagePicker,
  })  : _getProfile = getUserProfile,
        _updateProfile = updateUserProfile,
        _uploadAvatar = uploadAvatar,
        _imagePicker = imagePicker ?? ImagePicker(),
        super(const UserProfileInitial());

  final GetUserProfile _getProfile;
  final UpdateUserProfile _updateProfile;
  final UploadAvatar _uploadAvatar;
  final ImagePicker _imagePicker;
  final _log = Logger();

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  Future<void> loadProfile(String userId) async {
    emit(const UserProfileLoading());

    final result = await _getProfile(userId);
    result.fold(
      (failure) => emit(UserProfileError(message: failure.message)),
      (profile) =>
          emit(UserProfileLoaded(profile: profile, isEditing: false)),
    );
  }

  // ---------------------------------------------------------------------------
  // Edit mode toggle
  // ---------------------------------------------------------------------------

  void startEditing() {
    final current = state;
    if (current is UserProfileLoaded) {
      emit(current.copyWith(isEditing: true));
    }
  }

  void cancelEditing() {
    final current = state;
    if (current is UserProfileLoaded) {
      emit(current.copyWith(isEditing: false));
    }
  }

  // ---------------------------------------------------------------------------
  // Save profile
  // ---------------------------------------------------------------------------

  Future<void> saveProfile(UserProfile updatedProfile) async {
    final current = state;
    if (current is! UserProfileLoaded) return;

    emit(current.copyWith(isSaving: true));

    final result = await _updateProfile(updatedProfile);
    result.fold(
      (failure) {
        _log.e('updateUserProfile failed: ${failure.message}');
        // Restore previous state with error below; screen handles snackbar
        emit(current.copyWith(isSaving: false));
        emit(UserProfileError(message: failure.message));
      },
      (saved) => emit(UserProfileLoaded(profile: saved, isEditing: false)),
    );
  }

  // ---------------------------------------------------------------------------
  // Avatar picker & upload
  // ---------------------------------------------------------------------------

  Future<void> pickAvatar(ImageSource source) async {
    final current = state;
    if (current is! UserProfileLoaded) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    emit(AvatarPickerReady(
      file: File(picked.path),
      previousState: current,
    ));
  }

  Future<void> uploadAvatar({
    required String userId,
    required File imageFile,
    required UserProfileLoaded currentState,
  }) async {
    emit(currentState.copyWith(isUploadingAvatar: true));

    final result = await _uploadAvatar(userId: userId, imageFile: imageFile);
    result.fold(
      (failure) {
        _log.e('uploadAvatar failed: ${failure.message}');
        emit(currentState.copyWith(isUploadingAvatar: false));
        emit(UserProfileError(message: failure.message));
      },
      (avatarUrl) {
        final updated = currentState.profile.copyWith(avatarUrl: avatarUrl);
        emit(UserProfileLoaded(profile: updated, isEditing: false));
      },
    );
  }
}
