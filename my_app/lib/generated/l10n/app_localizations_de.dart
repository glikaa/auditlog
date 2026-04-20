// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Meine App';

  @override
  String get profilePageTitle => 'Profil';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get changeAvatar => 'Avatar ändern';

  @override
  String get uploadAvatar => 'Avatar hochladen';

  @override
  String get firstName => 'Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String get email => 'E-Mail';

  @override
  String get bio => 'Über mich';

  @override
  String fieldRequired(String fieldName) {
    return '$fieldName ist erforderlich.';
  }

  @override
  String get invalidEmail => 'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get profileUpdated => 'Profil erfolgreich aktualisiert.';

  @override
  String get refreshProfile => 'Profil neu laden';

  @override
  String get profileUpdateFailed =>
      'Profil konnte nicht gespeichert werden. Bitte erneut versuchen.';

  @override
  String get avatarUploadFailed =>
      'Avatar konnte nicht hochgeladen werden. Bitte erneut versuchen.';

  @override
  String get loading => 'Wird geladen...';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get errorUnknown => 'Ein unerwarteter Fehler ist aufgetreten.';

  @override
  String get galleryOption => 'Aus Galerie auswählen';

  @override
  String get cameraOption => 'Foto aufnehmen';
}
