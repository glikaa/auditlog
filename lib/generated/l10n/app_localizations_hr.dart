// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appTitle => 'Audit Aplikacija';

  @override
  String get login => 'Prijava';

  @override
  String get loginSubtitle => 'Revizija poslovnica i upravljanje';

  @override
  String get email => 'E-pošta';

  @override
  String get password => 'Lozinka';

  @override
  String get fieldRequired => 'Ovo polje je obavezno.';

  @override
  String get invalidEmail => 'Unesite valjanu adresu e-pošte.';

  @override
  String get dashboard => 'Pregled';

  @override
  String get newAudit => 'Novi audit';

  @override
  String get noAuditsFound => 'Nema pronađenih audita.';

  @override
  String get retry => 'Pokušaj ponovo';

  @override
  String get auditDetail => 'Detalji audita';

  @override
  String get auditInfo => 'Informacije o auditu';

  @override
  String get branch => 'Poslovnica';

  @override
  String get auditor => 'Revizor';

  @override
  String get date => 'Datum';

  @override
  String get status => 'Status';

  @override
  String get result => 'Rezultat';

  @override
  String get statistics => 'Statistika';

  @override
  String get tableOfContents => 'Sadržaj';

  @override
  String get yes => 'Da';

  @override
  String get no => 'Ne';

  @override
  String get notApplicable => 'Nije primjenjivo';

  @override
  String get finding => 'Nalaz';

  @override
  String get measure => 'Mjera';

  @override
  String get rating => 'Ocjena';

  @override
  String get attachments => 'Prilozi';

  @override
  String get completeAudit => 'Završi';

  @override
  String get completeAuditConfirm => 'Želite li zaista završiti ovaj audit?';

  @override
  String get releaseAudit => 'Odobri';

  @override
  String get confirm => 'Potvrdi';

  @override
  String get cancel => 'Odustani';

  @override
  String get previousAudit => 'Prethodni audit';

  @override
  String get reporting => 'Izvješćivanje';

  @override
  String get reportBranchResults => 'Rezultati poslovnica';

  @override
  String get reportTop5 => 'Top-5 pitanja';

  @override
  String get reportCountryComparison => 'Usporedba zemalja';

  @override
  String get reportAllCountries => 'Sve zemlje';

  @override
  String get reportAllYears => 'Sve godine';

  @override
  String get reportNoData => 'Nema dostupnih podataka.';

  @override
  String get reportMasterQuestionId => 'ID glavnog pitanja';

  @override
  String get reportTop5YesTitle => 'Top-5: Najčešći odgovori Da';

  @override
  String get reportTop5NoTitle => 'Top-5: Najčešći odgovori Ne';

  @override
  String get reportLocalQuestionNo => 'Lokalni br. pitanja';

  @override
  String get reportYesPercent => 'Udio Da (%)';

  @override
  String get reportLatestResult => 'Zadnji rezultat';

  @override
  String get reportAuditCount => 'Broj audita';

  @override
  String get settings => 'Postavke';

  @override
  String get language => 'Jezik';

  @override
  String get logout => 'Odjava';

  @override
  String get profile => 'Profil';

  @override
  String get name => 'Ime';

  @override
  String get role => 'Uloga';

  @override
  String get country => 'Zemlja';

  @override
  String get german => 'Njemački';

  @override
  String get croatian => 'Hrvatski';

  @override
  String get english => 'Engleski';

  @override
  String get appearance => 'Izgled';

  @override
  String get darkMode => 'Tamni način';

  @override
  String get languageChanged => 'Jezik promijenjen';

  @override
  String get logoutConfirm => 'Želite li se zaista odjaviti?';

  @override
  String get version => 'Verzija';

  @override
  String get loading => 'Učitavanje...';

  @override
  String get errorUnknown => 'Došlo je do neočekivane pogreške.';

  @override
  String get nachrevision => 'Naknadna revizija';

  @override
  String get startNachrevision => 'Pokreni naknadnu reviziju';

  @override
  String get startNachrevisionConfirm =>
      'Želite li pokrenuti naknadnu reviziju za ovaj audit? Postojeći odgovori bit će preuzeti kao usporedne vrijednosti.';

  @override
  String get improved => 'Poboljšano';

  @override
  String get worsened => 'Pogoršano';

  @override
  String get unchanged => 'Nepromijenjeno';

  @override
  String get answered => 'Odgovoreno';

  @override
  String get statusDraft => 'Nacrt';

  @override
  String get statusInProgress => 'U tijeku';

  @override
  String get statusCompleted => 'Zavrseno';

  @override
  String get statusReleased => 'Odobreno';

  @override
  String get pdfCreating => 'Izrada PDF-a...';

  @override
  String get pdfDownloaded => 'PDF preuzet!';

  @override
  String get pdfExportFailed => 'Izvoz PDF-a nije uspio';

  @override
  String get addAttachment => 'Dodaj privitak';

  @override
  String get attachmentFile => 'Datoteka';

  @override
  String get attachmentGallery => 'Galerija';

  @override
  String get attachmentCamera => 'Kamera';

  @override
  String get attachmentReadError => 'Datoteka se ne može pročitati';

  @override
  String attachmentUploadSuccess(String fileName) {
    return 'Privitak \"$fileName\" učitan';
  }

  @override
  String attachmentUploadError(String fileName) {
    return 'Pogreška pri učitavanju \"$fileName\"';
  }

  @override
  String get attachmentUnnamed => 'Nepoznata datoteka';

  @override
  String get internalAuditHint => 'Interni revizijski savjet';

  @override
  String passwordMinLength(int count) {
    return 'Lozinka mora imati najmanje $count znakova';
  }

  @override
  String get createAudit => 'Kreiraj audit';

  @override
  String get auditCatalog => 'Katalog revizije';

  @override
  String get selectCatalog => 'Odaberi katalog';

  @override
  String get selectBranch => 'Odaberi poslovnicu';

  @override
  String get selectAuditor => 'Odaberi revizora';

  @override
  String get deleteAudit => 'Obriši audit';

  @override
  String get deleteAuditConfirm =>
      'Jeste li sigurni da želite obrisati ovaj audit? Svi odgovori i prilozi bit će trajno uklonjeni.';

  @override
  String get auditDeleted => 'Audit je obrisan.';

  @override
  String get adminMenu => 'Admin';

  @override
  String get addUser => 'Dodaj korisnika';

  @override
  String get addQuestion => 'Dodaj pitanje';

  @override
  String get userCreated => 'Korisnik je kreiran.';

  @override
  String get questionAdded => 'Pitanje je dodano.';

  @override
  String get save => 'Spremi';

  @override
  String get orderLabel => 'Redoslijed';

  @override
  String get categoryLabel => 'Kategorija';

  @override
  String get questionTextDe => 'Tekst pitanja (Njemački)';

  @override
  String get questionTextEn => 'Tekst pitanja (Engleski)';

  @override
  String get questionTextHr => 'Tekst pitanja (Hrvatski)';

  @override
  String get selectRole => 'Odaberi ulogu';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleAuditor => 'Revizor';

  @override
  String get rolePreparer => 'Pripremač';

  @override
  String get roleDepartmentHead => 'Voditelj odjela';

  @override
  String get roleBranchManager => 'Voditelj poslovnice';

  @override
  String get roleDistrictManager => 'Voditelj distrikta';

  @override
  String get newCategory => 'Nova kategorija...';

  @override
  String get newCategoryLabel => 'Nova kategorija';
}
