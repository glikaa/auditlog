// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Audit App';

  @override
  String get login => 'Anmelden';

  @override
  String get loginSubtitle => 'Filialrevision & Audit Management';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String passwordMinLength(int count) {
    return 'Passwort muss mindestens $count Zeichen lang sein';
  }

  @override
  String get fieldRequired => 'Dieses Feld ist erforderlich.';

  @override
  String get invalidEmail => 'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get dashboard => 'Übersicht';

  @override
  String get newAudit => 'Neues Audit';

  @override
  String get noAuditsFound => 'Keine Audits gefunden.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get auditDetail => 'Audit-Details';

  @override
  String get auditInfo => 'Audit-Informationen';

  @override
  String get branch => 'Filiale';

  @override
  String get auditor => 'Prüfer';

  @override
  String get date => 'Datum';

  @override
  String get status => 'Status';

  @override
  String get result => 'Ergebnis';

  @override
  String get statistics => 'Statistiken';

  @override
  String get tableOfContents => 'Inhaltsverzeichnis';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get notApplicable => 'Entfällt';

  @override
  String get finding => 'Feststellung';

  @override
  String get measure => 'Maßnahme';

  @override
  String get rating => 'Wertung';

  @override
  String get attachments => 'Anhänge';

  @override
  String get auditClosingNote => 'Zusätzliche Bemerkungen';

  @override
  String get auditClosingNoteHint =>
      'Zusammenfassung oder Abschlussbemerkung zum Audit eingeben';

  @override
  String get completeAudit => 'Abschließen';

  @override
  String get completeAuditConfirm =>
      'Möchtest du dieses Audit wirklich abschließen?';

  @override
  String get releaseAudit => 'Freigeben';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get previousAudit => 'Erstprüfung';

  @override
  String get reporting => 'Reporting';

  @override
  String get reportBranchResults => 'Filialergebnisse';

  @override
  String get reportTop5 => 'Top-5 Fragen';

  @override
  String get reportCountryComparison => 'Ländervergleich';

  @override
  String get reportAllCountries => 'Alle Länder';

  @override
  String get reportAllYears => 'Alle Jahre';

  @override
  String get reportNoData => 'Keine Daten vorhanden.';

  @override
  String get reportMasterQuestionId => 'Master-Fragen-ID';

  @override
  String get reportTop5YesTitle => 'Top-5: häufigste Ja-Antworten';

  @override
  String get reportTop5NoTitle => 'Top-5: häufigste Nein-Antworten';

  @override
  String get reportLocalQuestionNo => 'Lokale Frage-Nr.';

  @override
  String get reportYesPercent => 'Ja-Anteil (%)';

  @override
  String get reportLatestResult => 'Letztes Ergebnis';

  @override
  String get reportAuditCount => 'Anzahl Audits';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get logout => 'Abmelden';

  @override
  String get profile => 'Profil';

  @override
  String get name => 'Name';

  @override
  String get role => 'Rolle';

  @override
  String get country => 'Land';

  @override
  String get german => 'Deutsch';

  @override
  String get croatian => 'Kroatisch';

  @override
  String get english => 'Englisch';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get languageChanged => 'Sprache geaendert';

  @override
  String get logoutConfirm => 'Moechtest du dich wirklich abmelden?';

  @override
  String get version => 'Version';

  @override
  String get loading => 'Wird geladen...';

  @override
  String get errorUnknown => 'Ein unerwarteter Fehler ist aufgetreten.';

  @override
  String get nachrevision => 'Nachrevision';

  @override
  String get startNachrevision => 'Nachrevision starten';

  @override
  String get startNachrevisionConfirm =>
      'Moechtest du eine Nachrevision fuer dieses Audit erstellen? Die bisherigen Antworten werden als Vergleichswerte uebernommen.';

  @override
  String get improved => 'Verbessert';

  @override
  String get worsened => 'Verschlechtert';

  @override
  String get unchanged => 'Unveraendert';

  @override
  String get answered => 'Beantwortet';

  @override
  String get statusDraft => 'Entwurf';

  @override
  String get statusInProgress => 'In Bearbeitung';

  @override
  String get statusCompleted => 'Abgeschlossen';

  @override
  String get statusReleased => 'Freigegeben';

  @override
  String get pdfCreating => 'PDF wird erstellt...';

  @override
  String get pdfDownloaded => 'PDF heruntergeladen!';

  @override
  String get pdfExportFailed => 'PDF-Export fehlgeschlagen';

  @override
  String get addAttachment => 'Anhang hinzufügen';

  @override
  String get attachmentFile => 'Datei';

  @override
  String get attachmentGallery => 'Galerie';

  @override
  String get attachmentCamera => 'Kamera';

  @override
  String get attachmentReadError => 'Datei konnte nicht gelesen werden';

  @override
  String attachmentUploadSuccess(String fileName) {
    return 'Anhang \"$fileName\" hochgeladen';
  }

  @override
  String attachmentUploadError(String fileName) {
    return 'Fehler beim Hochladen von \"$fileName\"';
  }

  @override
  String get attachmentReportRelevant => 'Im Bericht anzeigen';

  @override
  String get attachmentReportRelevantUpdateError =>
      'Die Berichtsrelevanz des Anhangs konnte nicht aktualisiert werden.';

  @override
  String get attachmentUnnamed => 'Unbekannte Datei';

  @override
  String get internalAuditHint => 'Interner Prüfhinweis';

  @override
  String get createAudit => 'Audit erstellen';

  @override
  String get auditCatalog => 'Prüfkatalog';

  @override
  String get selectCatalog => 'Katalog auswählen';

  @override
  String get selectBranch => 'Filiale auswählen';

  @override
  String get selectAuditor => 'Prüfer auswählen';

  @override
  String get deleteAudit => 'Audit löschen';

  @override
  String get deleteAuditConfirm =>
      'Soll dieses Audit wirklich gelöscht werden? Alle Antworten und Anhänge werden unwiderruflich entfernt.';

  @override
  String get auditDeleted => 'Audit wurde gelöscht.';

  @override
  String get adminMenu => 'Admin';

  @override
  String get addUser => 'Benutzer anlegen';

  @override
  String get addQuestion => 'Frage anlegen';

  @override
  String get userCreated => 'Benutzer wurde angelegt.';

  @override
  String get questionAdded => 'Frage wurde hinzugefügt.';

  @override
  String get save => 'Speichern';

  @override
  String get orderLabel => 'Reihenfolge';

  @override
  String get categoryLabel => 'Kategorie';

  @override
  String get questionTextDe => 'Fragetext (Deutsch)';

  @override
  String get questionTextEn => 'Fragetext (Englisch)';

  @override
  String get questionTextHr => 'Fragetext (Kroatisch)';

  @override
  String get selectRole => 'Rolle auswählen';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleAuditor => 'Prüfer';

  @override
  String get rolePreparer => 'Vorbereiter';

  @override
  String get roleDepartmentHead => 'Abteilungsleiter';

  @override
  String get roleBranchManager => 'Filialleiter';

  @override
  String get roleDistrictManager => 'Bezirksleiter';

  @override
  String get newCategory => 'Neue Kategorie...';

  @override
  String get newCategoryLabel => 'Neue Kategorie';

  @override
  String get loginTabStaff => 'Mitarbeiter';

  @override
  String get loginTabBranch => 'Filiale';

  @override
  String get branchNumber => 'Filialnummer';

  @override
  String get branchNumberHint => '7-stellige Nummer, z.B. 1001001';

  @override
  String get branchLogin => 'Filiale öffnen';

  @override
  String get branchNotFound => 'Filiale nicht gefunden.';

  @override
  String get branchNumberInvalid =>
      'Bitte eine 7-stellige Filialnummer eingeben.';

  @override
  String get acknowledgeAuditTitle => 'Ungelesene Audits';

  @override
  String get acknowledgeAuditMessage =>
      'Sie haben freigegebene Audits, die noch nicht als gelesen bestätigt wurden. Bitte öffnen Sie die Audits und bestätigen Sie mit dem Button \"Gelesen\".';

  @override
  String get acknowledgeAuditButton => 'Gelesen / Wahrgenommen';

  @override
  String get auditAcknowledged => 'Audit wurde zur Kenntnis genommen.';
}
