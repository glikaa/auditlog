import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/user_profile.dart';

/// Displays the user's avatar with an optional edit overlay.
class AvatarPickerWidget extends StatelessWidget {
  const AvatarPickerWidget({
    required this.profile,
    this.isEditing = false,
    this.isUploading = false,
    this.onPickImage,
    super.key,
  });

  final UserProfile profile;
  final bool isEditing;
  final bool isUploading;

  /// Called with the chosen [ImageSource] when the user confirms.
  final void Function(ImageSource source)? onPickImage;

  static const double _avatarRadius = 56;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        _AvatarCircle(
          avatarUrl: profile.avatarUrl,
          fullName: profile.fullName,
          isUploading: isUploading,
        ),
        if (isEditing && !isUploading)
          _EditOverlayButton(onTap: () => _showPicker(context)),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.galleryOption),
              onTap: () {
                Navigator.pop(context);
                onPickImage?.call(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.cameraOption),
              onTap: () {
                Navigator.pop(context);
                onPickImage?.call(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.avatarUrl,
    required this.fullName,
    required this.isUploading,
  });

  final String? avatarUrl;
  final String fullName;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: AvatarPickerWidget._avatarRadius,
      backgroundColor: colorScheme.primaryContainer,
      child: isUploading
          ? CircularProgressIndicator(color: colorScheme.onPrimaryContainer)
          : avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    avatarUrl!,
                    width: AvatarPickerWidget._avatarRadius * 2,
                    height: AvatarPickerWidget._avatarRadius * 2,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Initials(fullName: fullName),
                  ),
                )
              : _Initials(fullName: fullName),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.fullName});

  final String fullName;

  @override
  Widget build(BuildContext context) {
    final parts = fullName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : fullName.substring(0, fullName.length.clamp(0, 2)).toUpperCase();

    return Text(
      initials,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
    );
  }
}

class _EditOverlayButton extends StatelessWidget {
  const _EditOverlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.surface, width: 2),
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(Icons.camera_alt, size: 18, color: colorScheme.onPrimary),
      ),
    );
  }
}
