// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My App';

  @override
  String get profilePageTitle => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get cancel => 'Cancel';

  @override
  String get changeAvatar => 'Change Avatar';

  @override
  String get uploadAvatar => 'Upload Avatar';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get email => 'Email';

  @override
  String get bio => 'Bio';

  @override
  String fieldRequired(String fieldName) {
    return '$fieldName is required.';
  }

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get profileUpdated => 'Profile updated successfully.';

  @override
  String get refreshProfile => 'Refresh Profile';

  @override
  String get profileUpdateFailed =>
      'Failed to update profile. Please try again.';

  @override
  String get avatarUploadFailed => 'Failed to upload avatar. Please try again.';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get errorUnknown => 'An unexpected error occurred.';

  @override
  String get galleryOption => 'Choose from Gallery';

  @override
  String get cameraOption => 'Take a Photo';
}
