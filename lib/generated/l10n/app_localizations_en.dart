// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Audit App';

  @override
  String get login => 'Sign In';

  @override
  String get loginSubtitle => 'Branch Audit & Management';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String passwordMinLength(int count) {
    return 'Password must be at least $count characters.';
  }

  @override
  String get fieldRequired => 'This field is required.';

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get newAudit => 'New Audit';

  @override
  String get noAuditsFound => 'No audits found.';

  @override
  String get retry => 'Retry';

  @override
  String get auditDetail => 'Audit Details';

  @override
  String get auditInfo => 'Audit Information';

  @override
  String get branch => 'Branch';

  @override
  String get auditor => 'Auditor';

  @override
  String get date => 'Date';

  @override
  String get status => 'Status';

  @override
  String get result => 'Result';

  @override
  String get statistics => 'Statistics';

  @override
  String get tableOfContents => 'Table of Contents';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get notApplicable => 'N/A';

  @override
  String get finding => 'Finding';

  @override
  String get measure => 'Measure';

  @override
  String get rating => 'Rating';

  @override
  String get attachments => 'Attachments';

  @override
  String get completeAudit => 'Complete';

  @override
  String get completeAuditConfirm =>
      'Do you really want to complete this audit?';

  @override
  String get releaseAudit => 'Release';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get previousAudit => 'Previous Audit';

  @override
  String get reporting => 'Reporting';

  @override
  String get reportBranchResults => 'Branch Results';

  @override
  String get reportTop5 => 'Top-5 Questions';

  @override
  String get reportCountryComparison => 'Country Comparison';

  @override
  String get reportAllCountries => 'All countries';

  @override
  String get reportAllYears => 'All years';

  @override
  String get reportNoData => 'No data available.';

  @override
  String get reportMasterQuestionId => 'Master question ID';

  @override
  String get reportTop5YesTitle => 'Top-5: Most frequent Yes answers';

  @override
  String get reportTop5NoTitle => 'Top-5: Most frequent No answers';

  @override
  String get reportLocalQuestionNo => 'Local question no.';

  @override
  String get reportYesPercent => 'Yes share (%)';

  @override
  String get reportLatestResult => 'Latest result';

  @override
  String get reportAuditCount => 'Audit count';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Sign Out';

  @override
  String get profile => 'Profile';

  @override
  String get name => 'Name';

  @override
  String get role => 'Role';

  @override
  String get country => 'Country';

  @override
  String get german => 'German';

  @override
  String get croatian => 'Croatian';

  @override
  String get english => 'English';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get logoutConfirm => 'Do you really want to sign out?';

  @override
  String get version => 'Version';

  @override
  String get loading => 'Loading...';

  @override
  String get errorUnknown => 'An unexpected error occurred.';

  @override
  String get nachrevision => 'Follow-up Audit';

  @override
  String get startNachrevision => 'Start Follow-up Audit';

  @override
  String get startNachrevisionConfirm =>
      'Do you want to create a follow-up audit? The current answers will be copied as comparison values.';

  @override
  String get improved => 'Improved';

  @override
  String get worsened => 'Worsened';

  @override
  String get unchanged => 'Unchanged';

  @override
  String get answered => 'Answered';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusReleased => 'Released';

  @override
  String get pdfCreating => 'Creating PDF...';

  @override
  String get pdfDownloaded => 'PDF downloaded!';

  @override
  String get pdfExportFailed => 'PDF export failed';

  @override
  String get addAttachment => 'Add attachment';

  @override
  String get attachmentFile => 'File';

  @override
  String get attachmentGallery => 'Gallery';

  @override
  String get attachmentCamera => 'Camera';

  @override
  String get attachmentReadError => 'File could not be read';

  @override
  String attachmentUploadSuccess(String fileName) {
    return 'Attachment \"$fileName\" uploaded';
  }

  @override
  String attachmentUploadError(String fileName) {
    return 'Error uploading \"$fileName\"';
  }

  @override
  String get attachmentUnnamed => 'Unknown file';

  @override
  String get internalAuditHint => 'Internal Audit Hint';

  @override
  String get createAudit => 'Create Audit';

  @override
  String get auditCatalog => 'Audit Catalog';

  @override
  String get selectCatalog => 'Select catalog';

  @override
  String get selectBranch => 'Select branch';

  @override
  String get selectAuditor => 'Select auditor';

  @override
  String get deleteAudit => 'Delete Audit';

  @override
  String get deleteAuditConfirm =>
      'Are you sure you want to delete this audit? All responses and attachments will be permanently removed.';

  @override
  String get auditDeleted => 'Audit deleted.';

  @override
  String get adminMenu => 'Admin';

  @override
  String get addUser => 'Add User';

  @override
  String get addQuestion => 'Add Question';

  @override
  String get userCreated => 'User created.';

  @override
  String get questionAdded => 'Question added.';

  @override
  String get save => 'Save';

  @override
  String get orderLabel => 'Order';

  @override
  String get categoryLabel => 'Category';

  @override
  String get questionTextDe => 'Question Text (German)';

  @override
  String get questionTextEn => 'Question Text (English)';

  @override
  String get questionTextHr => 'Question Text (Croatian)';

  @override
  String get selectRole => 'Select Role';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleAuditor => 'Auditor';

  @override
  String get rolePreparer => 'Preparer';

  @override
  String get roleDepartmentHead => 'Department Head';

  @override
  String get roleBranchManager => 'Branch Manager';

  @override
  String get roleDistrictManager => 'District Manager';

  @override
  String get newCategory => 'New category...';

  @override
  String get newCategoryLabel => 'New Category';
}
