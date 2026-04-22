import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('hr')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Audit App'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Branch Audit & Management'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @newAudit.
  ///
  /// In en, this message translates to:
  /// **'New Audit'**
  String get newAudit;

  /// No description provided for @noAuditsFound.
  ///
  /// In en, this message translates to:
  /// **'No audits found.'**
  String get noAuditsFound;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @auditDetail.
  ///
  /// In en, this message translates to:
  /// **'Audit Details'**
  String get auditDetail;

  /// No description provided for @auditInfo.
  ///
  /// In en, this message translates to:
  /// **'Audit Information'**
  String get auditInfo;

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @auditor.
  ///
  /// In en, this message translates to:
  /// **'Auditor'**
  String get auditor;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @tableOfContents.
  ///
  /// In en, this message translates to:
  /// **'Table of Contents'**
  String get tableOfContents;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @notApplicable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notApplicable;

  /// No description provided for @finding.
  ///
  /// In en, this message translates to:
  /// **'Finding'**
  String get finding;

  /// No description provided for @measure.
  ///
  /// In en, this message translates to:
  /// **'Measure'**
  String get measure;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @completeAudit.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeAudit;

  /// No description provided for @completeAuditConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to complete this audit?'**
  String get completeAuditConfirm;

  /// No description provided for @releaseAudit.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get releaseAudit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @previousAudit.
  ///
  /// In en, this message translates to:
  /// **'Previous Audit'**
  String get previousAudit;

  /// No description provided for @reporting.
  ///
  /// In en, this message translates to:
  /// **'Reporting'**
  String get reporting;

  /// No description provided for @reportBranchResults.
  ///
  /// In en, this message translates to:
  /// **'Branch Results'**
  String get reportBranchResults;

  /// No description provided for @reportTop5.
  ///
  /// In en, this message translates to:
  /// **'Top-5 Questions'**
  String get reportTop5;

  /// No description provided for @reportCountryComparison.
  ///
  /// In en, this message translates to:
  /// **'Country Comparison'**
  String get reportCountryComparison;

  /// No description provided for @reportAllCountries.
  ///
  /// In en, this message translates to:
  /// **'All countries'**
  String get reportAllCountries;

  /// No description provided for @reportAllYears.
  ///
  /// In en, this message translates to:
  /// **'All years'**
  String get reportAllYears;

  /// No description provided for @reportNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get reportNoData;

  /// No description provided for @reportMasterQuestionId.
  ///
  /// In en, this message translates to:
  /// **'Master question ID'**
  String get reportMasterQuestionId;

  /// No description provided for @reportTop5YesTitle.
  ///
  /// In en, this message translates to:
  /// **'Top-5: Most frequent Yes answers'**
  String get reportTop5YesTitle;

  /// No description provided for @reportTop5NoTitle.
  ///
  /// In en, this message translates to:
  /// **'Top-5: Most frequent No answers'**
  String get reportTop5NoTitle;

  /// No description provided for @reportLocalQuestionNo.
  ///
  /// In en, this message translates to:
  /// **'Local question no.'**
  String get reportLocalQuestionNo;

  /// No description provided for @reportYesPercent.
  ///
  /// In en, this message translates to:
  /// **'Yes share (%)'**
  String get reportYesPercent;

  /// No description provided for @reportLatestResult.
  ///
  /// In en, this message translates to:
  /// **'Latest result'**
  String get reportLatestResult;

  /// No description provided for @reportAuditCount.
  ///
  /// In en, this message translates to:
  /// **'Audit count'**
  String get reportAuditCount;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @croatian.
  ///
  /// In en, this message translates to:
  /// **'Croatian'**
  String get croatian;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to sign out?'**
  String get logoutConfirm;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errorUnknown;

  /// No description provided for @nachrevision.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Audit'**
  String get nachrevision;

  /// No description provided for @startNachrevision.
  ///
  /// In en, this message translates to:
  /// **'Start Follow-up Audit'**
  String get startNachrevision;

  /// No description provided for @startNachrevisionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to create a follow-up audit? The current answers will be copied as comparison values.'**
  String get startNachrevisionConfirm;

  /// No description provided for @improved.
  ///
  /// In en, this message translates to:
  /// **'Improved'**
  String get improved;

  /// No description provided for @worsened.
  ///
  /// In en, this message translates to:
  /// **'Worsened'**
  String get worsened;

  /// No description provided for @unchanged.
  ///
  /// In en, this message translates to:
  /// **'Unchanged'**
  String get unchanged;

  /// No description provided for @answered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get answered;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusReleased.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get statusReleased;

  /// No description provided for @pdfCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating PDF...'**
  String get pdfCreating;

  /// No description provided for @pdfDownloaded.
  ///
  /// In en, this message translates to:
  /// **'PDF downloaded!'**
  String get pdfDownloaded;

  /// No description provided for @pdfExportFailed.
  ///
  /// In en, this message translates to:
  /// **'PDF export failed'**
  String get pdfExportFailed;

  /// Label for internal audit hint visible to auditors/admins only
  ///
  /// In en, this message translates to:
  /// **'Internal Audit Hint'**
  String get internalAuditHint;
  /// No description provided for @createAudit.
  ///
  /// In en, this message translates to:
  /// **'Create Audit'**
  String get createAudit;

  /// No description provided for @auditCatalog.
  ///
  /// In en, this message translates to:
  /// **'Audit Catalog'**
  String get auditCatalog;

  /// No description provided for @selectCatalog.
  ///
  /// In en, this message translates to:
  /// **'Select catalog'**
  String get selectCatalog;

  /// No description provided for @selectBranch.
  ///
  /// In en, this message translates to:
  /// **'Select branch'**
  String get selectBranch;

  /// No description provided for @selectAuditor.
  ///
  /// In en, this message translates to:
  /// **'Select auditor'**
  String get selectAuditor;

  /// No description provided for @deleteAudit.
  ///
  /// In en, this message translates to:
  /// **'Delete Audit'**
  String get deleteAudit;

  /// No description provided for @deleteAuditConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this audit? All responses and attachments will be permanently removed.'**
  String get deleteAuditConfirm;

  /// No description provided for @auditDeleted.
  ///
  /// In en, this message translates to:
  /// **'Audit deleted.'**
  String get auditDeleted;

  /// No description provided for @adminMenu.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminMenu;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @addQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add Question'**
  String get addQuestion;

  /// No description provided for @userCreated.
  ///
  /// In en, this message translates to:
  /// **'User created.'**
  String get userCreated;

  /// No description provided for @questionAdded.
  ///
  /// In en, this message translates to:
  /// **'Question added.'**
  String get questionAdded;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @orderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @questionTextDe.
  ///
  /// In en, this message translates to:
  /// **'Question Text (German)'**
  String get questionTextDe;

  /// No description provided for @questionTextEn.
  ///
  /// In en, this message translates to:
  /// **'Question Text (English)'**
  String get questionTextEn;

  /// No description provided for @questionTextHr.
  ///
  /// In en, this message translates to:
  /// **'Question Text (Croatian)'**
  String get questionTextHr;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRole;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @roleAuditor.
  ///
  /// In en, this message translates to:
  /// **'Auditor'**
  String get roleAuditor;

  /// No description provided for @rolePreparer.
  ///
  /// In en, this message translates to:
  /// **'Preparer'**
  String get rolePreparer;

  /// No description provided for @roleDepartmentHead.
  ///
  /// In en, this message translates to:
  /// **'Department Head'**
  String get roleDepartmentHead;

  /// No description provided for @roleBranchManager.
  ///
  /// In en, this message translates to:
  /// **'Branch Manager'**
  String get roleBranchManager;

  /// No description provided for @roleDistrictManager.
  ///
  /// In en, this message translates to:
  /// **'District Manager'**
  String get roleDistrictManager;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category...'**
  String get newCategory;

  /// No description provided for @newCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategoryLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'hr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'hr':
      return AppLocalizationsHr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
