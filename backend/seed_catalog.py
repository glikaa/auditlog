"""Seed script - creates a German audit catalog with questions + a demo audit."""
import sys
import os
import uuid
from datetime import datetime, timezone

sys.path.insert(0, os.path.dirname(__file__))

from app.services.firebase_service import get_db

CATALOG_ID = "catalog-de-2025"

CATALOG = {
    "id": CATALOG_ID,
    "country_code": "DE",
    "version": "v1.0",
    "year": 2025,
    "language": "de",
    "question_count": 0,
    "created_at": datetime.now(timezone.utc).isoformat(),
}

# Real audit questions grouped by category (based on Filialrevision structure)
QUESTIONS = [
    # --- Inventursicherheit ---
    {
        "order": 1,
        "category": "Inventursicherheit",
        "category_en": "Inventory Security",
        "category_hr": "Sigurnost inventure",
        "text_de": "Werden Bestandsdifferenzen zeitnah analysiert und dokumentiert?",
        "text_en": "Are inventory discrepancies analysed and documented in a timely manner?",
        "text_hr": "Analiziraju li se i dokumentiraju inventurne razlike pravovremeno?",
        "explanation_text_de": "Pruefung ob Differenzen innerhalb von 48h bearbeitet werden.",
        "explanation_text_en": "Check whether discrepancies are processed within 48 hours.",
        "explanation_text_hr": "Provjera obradjuju li se razlike unutar 48 sati.",
        "default_finding_de": "Differenzen werden nicht zeitnah bearbeitet.",
        "default_finding_en": "Discrepancies are not processed in a timely manner.",
        "default_finding_hr": "Razlike se ne obradjuju pravovremeno.",
        "default_measure_de": "Differenzbearbeitung innerhalb von 48h sicherstellen.",
        "default_measure_en": "Ensure discrepancy processing within 48 hours.",
        "default_measure_hr": "Osigurati obradu razlika unutar 48 sati.",
        "internal_note_de": "Differenzbericht der letzten 3 Monate pruefen.",
        "internal_note_en": "Review the discrepancy report of the last 3 months.",
        "internal_note_hr": "Pregledati izvjestaj o razlikama za posljednja 3 mjeseca.",
    },
    {
        "order": 2,
        "category": "Inventursicherheit",
        "category_en": "Inventory Security",
        "category_hr": "Sigurnost inventure",
        "text_de": "Wird die Inventur ordnungsgemaess vorbereitet und durchgefuehrt?",
        "text_en": "Is the stocktaking properly prepared and carried out?",
        "text_hr": "Provodi li se inventura pravilno i u skladu s propisima?",
        "explanation_text_de": "Inventurrichtlinie muss eingehalten werden.",
        "explanation_text_en": "The stocktaking guideline must be followed.",
        "explanation_text_hr": "Smjernice za inventuru moraju se postivati.",
        "default_finding_de": "Inventurvorbereitung weist Maengel auf.",
        "default_finding_en": "Stocktaking preparation shows deficiencies.",
        "default_finding_hr": "Priprema inventure pokazuje nedostatke.",
        "default_measure_de": "Inventurrichtlinie erneut schulen und Checkliste einfuehren.",
        "default_measure_en": "Retrain stocktaking guidelines and introduce a checklist.",
        "default_measure_hr": "Ponovno educirati o smjernicama za inventuru i uvesti kontrolnu listu.",
        "internal_note_de": "Letzte Inventurergebnisse und Protokolle pruefen.",
        "internal_note_en": "Review last stocktaking results and protocols.",
        "internal_note_hr": "Pregledati posljednje rezultate inventure i zapisnike.",
    },
    {
        "order": 3,
        "category": "Inventursicherheit",
        "category_en": "Inventory Security",
        "category_hr": "Sigurnost inventure",
        "text_de": "Sind die Warensicherungsanlagen funktionsfaehig und aktiviert?",
        "text_en": "Are the merchandise security systems functional and activated?",
        "text_hr": "Jesu li sustavi za osiguranje robe funkcionalni i aktivirani?",
        "explanation_text_de": "Alle Sicherungsetiketten und Antennen muessen funktionieren.",
        "explanation_text_en": "All security tags and antennas must be functional.",
        "explanation_text_hr": "Sve sigurnosne oznake i antene moraju biti funkcionalne.",
        "default_finding_de": "Warensicherungsanlage nicht vollstaendig funktionsfaehig.",
        "default_finding_en": "Merchandise security system not fully functional.",
        "default_finding_hr": "Sustav za osiguranje robe nije potpuno funkcionalan.",
        "default_measure_de": "Techniker beauftragen, Anlage pruefen und instand setzen.",
        "default_measure_en": "Commission a technician to inspect and repair the system.",
        "default_measure_hr": "Angazirati tehnicara za pregled i popravak sustava.",
    },
    {
        "order": 4,
        "category": "Inventursicherheit",
        "category_en": "Inventory Security",
        "category_hr": "Sigurnost inventure",
        "text_de": "Werden Retouren und Warenein-/ausgaenge korrekt erfasst?",
        "text_en": "Are returns and goods receipts/dispatches recorded correctly?",
        "text_hr": "Evidentiraju li se povrati i ulaz/izlaz robe ispravno?",
        "explanation_text_de": "Stichprobenhafte Pruefung der Warenbewegungen.",
        "explanation_text_en": "Random sampling of goods movements.",
        "explanation_text_hr": "Nasumicna provjera kretanja robe.",
        "default_finding_de": "Warenbewegungen werden nicht vollstaendig erfasst.",
        "default_finding_en": "Goods movements are not fully recorded.",
        "default_finding_hr": "Kretanja robe nisu u potpunosti evidentirana.",
        "default_measure_de": "Prozess der Warenerfassung schulen und kontrollieren.",
        "default_measure_en": "Train and monitor the goods recording process.",
        "default_measure_hr": "Educirati i kontrolirati proces evidentiranja robe.",
    },

    # --- Bestandsfuehrung ---
    {
        "order": 5,
        "category": "Bestandsfuehrung",
        "category_en": "Inventory Management",
        "category_hr": "Upravljanje zalihama",
        "text_de": "Stimmt der Systembestand mit dem physischen Bestand ueberein?",
        "text_en": "Does the system inventory match the physical inventory?",
        "text_hr": "Odgovara li stanje u sustavu fizickom stanju zaliha?",
        "explanation_text_de": "Stichprobe von mind. 20 Artikeln pruefen.",
        "explanation_text_en": "Check a sample of at least 20 items.",
        "explanation_text_hr": "Provjeriti uzorak od najmanje 20 artikala.",
        "default_finding_de": "Abweichungen zwischen System- und physischem Bestand festgestellt.",
        "default_finding_en": "Discrepancies found between system and physical inventory.",
        "default_finding_hr": "Utvrdjene razlike izmedju stanja u sustavu i fizickog stanja.",
        "default_measure_de": "Bestandskorrektur durchfuehren und Ursachenanalyse erstellen.",
        "default_measure_en": "Perform inventory correction and root cause analysis.",
        "default_measure_hr": "Provesti korekciju zaliha i analizu uzroka.",
        "internal_note_de": "Mind. 20 Artikel aus verschiedenen Kategorien pruefen.",
        "internal_note_en": "Check at least 20 items from different categories.",
        "internal_note_hr": "Provjeriti najmanje 20 artikala iz razlicitih kategorija.",
    },
    {
        "order": 6,
        "category": "Bestandsfuehrung",
        "category_en": "Inventory Management",
        "category_hr": "Upravljanje zalihama",
        "text_de": "Werden Nullbestaende und negative Bestaende regelmaessig bereinigt?",
        "text_en": "Are zero and negative stock levels regularly cleared?",
        "text_hr": "Razrjesavaju li se nulte i negativne zalihe redovito?",
        "explanation_text_de": "Nullbestaende sollen woechentlich geprueft werden.",
        "explanation_text_en": "Zero stock should be checked weekly.",
        "explanation_text_hr": "Nulte zalihe trebaju se provjeravati tjedno.",
        "default_finding_de": "Nullbestaende werden nicht regelmaessig bereinigt.",
        "default_finding_en": "Zero stock levels are not regularly cleared.",
        "default_finding_hr": "Nulte zalihe se ne razrjesavaju redovito.",
        "default_measure_de": "Woechentliche Bereinigung der Bestandslisten einfuehren.",
        "default_measure_en": "Introduce weekly clearing of inventory lists.",
        "default_measure_hr": "Uvesti tjedno ciscenje popisa zaliha.",
    },
    {
        "order": 7,
        "category": "Bestandsfuehrung",
        "category_en": "Inventory Management",
        "category_hr": "Upravljanje zalihama",
        "text_de": "Ist die Warenwirtschaft (IT-System) korrekt konfiguriert?",
        "text_en": "Is the merchandise management (IT system) correctly configured?",
        "text_hr": "Je li sustav upravljanja robom ispravno konfiguriran?",
        "explanation_text_de": "Bestellparameter, Meldebestaende und Lieferanteneinstellungen pruefen.",
        "explanation_text_en": "Check order parameters, reorder levels and supplier settings.",
        "explanation_text_hr": "Provjeriti parametre narudzbi, razine ponovnog narudzivanja i postavke dobavljaca.",
        "default_finding_de": "Systemparameter nicht korrekt eingestellt.",
        "default_finding_en": "System parameters not correctly configured.",
        "default_finding_hr": "Parametri sustava nisu ispravno postavljeni.",
        "default_measure_de": "IT-Abteilung informieren und Parameter korrigieren.",
        "default_measure_en": "Inform IT department and correct the parameters.",
        "default_measure_hr": "Obavijestiti IT odjel i ispraviti parametre.",
    },

    # --- Geldsicherheit ---
    {
        "order": 8,
        "category": "Geldsicherheit",
        "category_en": "Cash Security",
        "category_hr": "Sigurnost gotovine",
        "text_de": "Wird der Kassenabschluss taeglich und korrekt durchgefuehrt?",
        "text_en": "Is the daily cash register closing performed correctly?",
        "text_hr": "Provodi li se zakljucak blagajne dnevno i ispravno?",
        "explanation_text_de": "Tagesabschluss muss dokumentiert und unterschrieben sein.",
        "explanation_text_en": "The daily closing must be documented and signed.",
        "explanation_text_hr": "Dnevni zakljucak mora biti dokumentiran i potpisan.",
        "default_finding_de": "Kassenabschluss nicht ordnungsgemaess durchgefuehrt.",
        "default_finding_en": "Cash register closing not properly performed.",
        "default_finding_hr": "Zakljucak blagajne nije pravilno proveden.",
        "default_measure_de": "Kassenrichtlinie schulen, taegliche Kontrolle durch Filialleiter.",
        "default_measure_en": "Train cash register guidelines, daily checks by branch manager.",
        "default_measure_hr": "Educirati o smjernicama za blagajnu, dnevna kontrola voditelja poslovnice.",
        "internal_note_de": "Kassenberichte der letzten Woche stichprobenartig pruefen.",
        "internal_note_en": "Randomly check cash reports from the last week.",
        "internal_note_hr": "Nasumicno provjeriti blagajnicke izvjestaje iz prethodnog tjedna.",
    },
    {
        "order": 9,
        "category": "Geldsicherheit",
        "category_en": "Cash Security",
        "category_hr": "Sigurnost gotovine",
        "text_de": "Werden Kassendifferenzen zeitnah aufgeklaert und dokumentiert?",
        "text_en": "Are cash register discrepancies clarified and documented promptly?",
        "text_hr": "Razjasnjavaju li se blagajnicke razlike pravovremeno?",
        "explanation_text_de": "Differenzen ueber 5 EUR muessen sofort gemeldet werden.",
        "explanation_text_en": "Discrepancies over EUR 5 must be reported immediately.",
        "explanation_text_hr": "Razlike vece od 5 EUR moraju se odmah prijaviti.",
        "default_finding_de": "Kassendifferenzen werden nicht zeitnah bearbeitet.",
        "default_finding_en": "Cash discrepancies are not processed in a timely manner.",
        "default_finding_hr": "Blagajnicke razlike se ne obradjuju pravovremeno.",
        "default_measure_de": "Sofortige Meldepflicht bei Kassendifferenzen einfuehren.",
        "default_measure_en": "Introduce immediate reporting obligation for cash discrepancies.",
        "default_measure_hr": "Uvesti obvezu trenutnog prijavljivanja blagajnickih razlika.",
    },
    {
        "order": 10,
        "category": "Geldsicherheit",
        "category_en": "Cash Security",
        "category_hr": "Sigurnost gotovine",
        "text_de": "Ist der Tresor ordnungsgemaess gesichert und wird er regelmaessig geprueft?",
        "text_en": "Is the safe properly secured and regularly inspected?",
        "text_hr": "Je li sef pravilno osiguran i redovito provjeren?",
        "explanation_text_de": "Tresor muss verschlossen und Zugangsprotokoll gefuehrt sein.",
        "explanation_text_en": "The safe must be locked and an access log must be maintained.",
        "explanation_text_hr": "Sef mora biti zakljucan i mora se voditi evidencija pristupa.",
        "default_finding_de": "Tresorsicherung weist Maengel auf.",
        "default_finding_en": "Safe security shows deficiencies.",
        "default_finding_hr": "Osiguranje sefa pokazuje nedostatke.",
        "default_measure_de": "Tresorrichtlinie einhalten, Zugangsliste aktualisieren.",
        "default_measure_en": "Comply with safe guidelines, update access list.",
        "default_measure_hr": "Pridrzavati se smjernica za sef, azurirati popis pristupa.",
    },
    {
        "order": 11,
        "category": "Geldsicherheit",
        "category_en": "Cash Security",
        "category_hr": "Sigurnost gotovine",
        "text_de": "Werden Gutscheine und Wertmarken ordnungsgemaess verwaltet?",
        "text_en": "Are vouchers and tokens managed properly?",
        "text_hr": "Upravljaju li se bonovi i vrijednosni kuponi pravilno?",
        "explanation_text_de": "Bestandsliste und Ausgabeprotokoll pruefen.",
        "explanation_text_en": "Check inventory list and distribution log.",
        "explanation_text_hr": "Provjeriti popis zaliha i evidenciju izdavanja.",
        "default_finding_de": "Gutscheinverwaltung nicht nachvollziehbar.",
        "default_finding_en": "Voucher management not traceable.",
        "default_finding_hr": "Upravljanje bonovima nije moguci pratiti.",
        "default_measure_de": "Luekenlose Dokumentation der Gutscheinausgabe sicherstellen.",
        "default_measure_en": "Ensure complete documentation of voucher distribution.",
        "default_measure_hr": "Osigurati potpunu dokumentaciju izdavanja bonova.",
    },

    # --- Haussicherheit ---
    {
        "order": 12,
        "category": "Haussicherheit",
        "category_en": "Building Security",
        "category_hr": "Sigurnost objekta",
        "text_de": "Sind Notausgaenge frei zugaenglich und gekennzeichnet?",
        "text_en": "Are emergency exits freely accessible and marked?",
        "text_hr": "Jesu li izlazi u nuzdi slobodno pristupacni i oznaceni?",
        "explanation_text_de": "Flucht- und Rettungswege muessen frei und beschildert sein.",
        "explanation_text_en": "Escape and rescue routes must be clear and signposted.",
        "explanation_text_hr": "Putovi za evakuaciju moraju biti slobodni i oznaceni.",
        "default_finding_de": "Notausgaenge teilweise versperrt oder nicht gekennzeichnet.",
        "default_finding_en": "Emergency exits partially blocked or not marked.",
        "default_finding_hr": "Izlazi u nuzdi djelomicno blokirani ili neoznaceni.",
        "default_measure_de": "Sofortige Freigabe der Notausgaenge und Beschilderung pruefen.",
        "default_measure_en": "Immediately clear emergency exits and check signage.",
        "default_measure_hr": "Odmah osloboditi izlaze u nuzdi i provjeriti oznake.",
        "internal_note_de": "Sicherheitsrelevant - sofortige Massnahme erforderlich!",
        "internal_note_en": "Safety-relevant - immediate action required!",
        "internal_note_hr": "Sigurnosno relevantno - potrebna hitna mjera!",
    },
    {
        "order": 13,
        "category": "Haussicherheit",
        "category_en": "Building Security",
        "category_hr": "Sigurnost objekta",
        "text_de": "Sind Feuerloescher vorhanden, geprueft und zugaenglich?",
        "text_en": "Are fire extinguishers present, inspected and accessible?",
        "text_hr": "Jesu li aparati za gasenje prisutni, pregledani i dostupni?",
        "explanation_text_de": "Pruefplaketten und Zugaenglichkeit kontrollieren.",
        "explanation_text_en": "Check inspection labels and accessibility.",
        "explanation_text_hr": "Provjeriti naljepnice pregleda i pristupacnost.",
        "default_finding_de": "Feuerloescher nicht zugaenglich oder Pruefung abgelaufen.",
        "default_finding_en": "Fire extinguishers not accessible or inspection expired.",
        "default_finding_hr": "Aparati za gasenje nedostupni ili pregled istekao.",
        "default_measure_de": "Feuerloescher pruefen lassen und Zugaenglichkeit sicherstellen.",
        "default_measure_en": "Have fire extinguishers inspected and ensure accessibility.",
        "default_measure_hr": "Dati pregledati aparate za gasenje i osigurati pristupacnost.",
    },
    {
        "order": 14,
        "category": "Haussicherheit",
        "category_en": "Building Security",
        "category_hr": "Sigurnost objekta",
        "text_de": "Funktioniert die Alarmanlage und wird sie regelmaessig getestet?",
        "text_en": "Is the alarm system working and regularly tested?",
        "text_hr": "Funkcionira li alarmni sustav i testira li se redovito?",
        "explanation_text_de": "Testprotokoll der letzten 6 Monate einsehen.",
        "explanation_text_en": "Review the test log of the last 6 months.",
        "explanation_text_hr": "Pregledati zapisnik testiranja za posljednjih 6 mjeseci.",
        "default_finding_de": "Alarmanlage nicht regelmaessig getestet.",
        "default_finding_en": "Alarm system not regularly tested.",
        "default_finding_hr": "Alarmni sustav se ne testira redovito.",
        "default_measure_de": "Quartalsmaessige Tests der Alarmanlage einfuehren.",
        "default_measure_en": "Introduce quarterly alarm system tests.",
        "default_measure_hr": "Uvesti kvartalno testiranje alarmnog sustava.",
    },
    {
        "order": 15,
        "category": "Haussicherheit",
        "category_en": "Building Security",
        "category_hr": "Sigurnost objekta",
        "text_de": "Ist die Schliessanlage intakt und werden Schluessel korrekt verwaltet?",
        "text_en": "Is the locking system intact and are keys managed correctly?",
        "text_hr": "Je li sustav zakljucavanja ispravan i upravljaju li se kljucevi pravilno?",
        "explanation_text_de": "Schluesselbuch und Zugangsberechtigungen pruefen.",
        "explanation_text_en": "Check key log and access authorisations.",
        "explanation_text_hr": "Provjeriti knjigu kljuceva i ovlastenja pristupa.",
        "default_finding_de": "Schluesselverwaltung nicht nachvollziehbar.",
        "default_finding_en": "Key management not traceable.",
        "default_finding_hr": "Upravljanje kljucevima nije moguci pratiti.",
        "default_measure_de": "Schluesselbuch aktualisieren und Zugangsliste pruefen.",
        "default_measure_en": "Update key log and review access list.",
        "default_measure_hr": "Azurirati knjigu kljuceva i pregledati popis pristupa.",
    },

    # --- Lagerorganisation ---
    {
        "order": 16,
        "category": "Lagerorganisation",
        "category_en": "Warehouse Organisation",
        "category_hr": "Organizacija skladista",
        "text_de": "Ist das Lager sauber, ordentlich und uebersichtlich organisiert?",
        "text_en": "Is the warehouse clean, tidy and clearly organised?",
        "text_hr": "Je li skladiste cisto, uredno i pregledno organizirano?",
        "explanation_text_de": "Lager muss nach Warengruppen sortiert und begehbar sein.",
        "explanation_text_en": "The warehouse must be sorted by product groups and accessible.",
        "explanation_text_hr": "Skladiste mora biti sortirano po grupama proizvoda i prohodno.",
        "default_finding_de": "Lagerorganisation entspricht nicht den Vorgaben.",
        "default_finding_en": "Warehouse organisation does not meet requirements.",
        "default_finding_hr": "Organizacija skladista ne zadovoljava zahtjeve.",
        "default_measure_de": "Lager raeumen, sortieren und Beschriftung anbringen.",
        "default_measure_en": "Clear warehouse, sort and apply labelling.",
        "default_measure_hr": "Ocistiti skladiste, sortirati i postaviti oznake.",
        "internal_note_de": "Fotos machen fuer Dokumentation.",
        "internal_note_en": "Take photos for documentation.",
        "internal_note_hr": "Napraviti fotografije za dokumentaciju.",
    },
    {
        "order": 17,
        "category": "Lagerorganisation",
        "category_en": "Warehouse Organisation",
        "category_hr": "Organizacija skladista",
        "text_de": "Wird die FIFO-Methode (First In, First Out) korrekt angewendet?",
        "text_en": "Is the FIFO method (First In, First Out) applied correctly?",
        "text_hr": "Primjenjuje li se FIFO metoda ispravno?",
        "explanation_text_de": "Aeltere Ware muss vor neuerer Ware platziert sein.",
        "explanation_text_en": "Older goods must be placed before newer goods.",
        "explanation_text_hr": "Starija roba mora biti postavljena ispred novije.",
        "default_finding_de": "FIFO wird nicht konsequent eingehalten.",
        "default_finding_en": "FIFO is not consistently applied.",
        "default_finding_hr": "FIFO se ne primjenjuje dosljedno.",
        "default_measure_de": "FIFO-Prinzip schulen und regelmaessig kontrollieren.",
        "default_measure_en": "Train FIFO principle and check regularly.",
        "default_measure_hr": "Educirati o FIFO principu i redovito kontrolirati.",
    },
    {
        "order": 18,
        "category": "Lagerorganisation",
        "category_en": "Warehouse Organisation",
        "category_hr": "Organizacija skladista",
        "text_de": "Sind Gefahrstoffe korrekt gelagert und gekennzeichnet?",
        "text_en": "Are hazardous materials stored and labelled correctly?",
        "text_hr": "Jesu li opasne tvari pravilno uskladistene i oznacene?",
        "explanation_text_de": "Gefahrstoffverordnung und Sicherheitsdatenblaetter pruefen.",
        "explanation_text_en": "Check hazardous substances regulation and safety data sheets.",
        "explanation_text_hr": "Provjeriti propise o opasnim tvarima i sigurnosne listove.",
        "default_finding_de": "Gefahrstofflagerung entspricht nicht den Vorschriften.",
        "default_finding_en": "Hazardous material storage does not comply with regulations.",
        "default_finding_hr": "Skladistenje opasnih tvari ne odgovara propisima.",
        "default_measure_de": "Gefahrstofflagerung gemaess Vorschriften korrigieren.",
        "default_measure_en": "Correct hazardous material storage according to regulations.",
        "default_measure_hr": "Ispraviti skladistenje opasnih tvari prema propisima.",
    },
    {
        "order": 19,
        "category": "Lagerorganisation",
        "category_en": "Warehouse Organisation",
        "category_hr": "Organizacija skladista",
        "text_de": "Ist der Wareneingangsbereich organisiert und wird Ware zeitnah verraeumt?",
        "text_en": "Is the goods receiving area organised and is merchandise shelved promptly?",
        "text_hr": "Je li zona prijema robe organizirana i rasporeduje li se roba pravovremeno?",
        "explanation_text_de": "Wareneingang sollte innerhalb von 24h bearbeitet werden.",
        "explanation_text_en": "Goods receiving should be processed within 24 hours.",
        "explanation_text_hr": "Prijem robe treba biti obradjen unutar 24 sata.",
        "default_finding_de": "Wareneingang wird nicht zeitnah bearbeitet.",
        "default_finding_en": "Goods receiving is not processed in a timely manner.",
        "default_finding_hr": "Prijem robe se ne obradjuje pravovremeno.",
        "default_measure_de": "Maximale Verraeumdauer von 24h einfuehren und kontrollieren.",
        "default_measure_en": "Introduce and monitor a maximum shelving time of 24 hours.",
        "default_measure_hr": "Uvesti i kontrolirati maksimalno vrijeme rasporedivanja od 24 sata.",
    },

    # --- Filialorganisation und Verkaufsbereitschaft ---
    {
        "order": 20,
        "category": "Filialorganisation und Verkaufsbereitschaft",
        "category_en": "Branch Organisation and Sales Readiness",
        "category_hr": "Organizacija poslovnice i prodajna spremnost",
        "text_de": "Ist die Verkaufsflaeche sauber, ordentlich und einladend?",
        "text_en": "Is the sales floor clean, tidy and inviting?",
        "text_hr": "Je li prodajna povrsina cista, uredna i privlacna?",
        "explanation_text_de": "Gesamteindruck der Verkaufsflaeche bewerten.",
        "explanation_text_en": "Evaluate the overall impression of the sales floor.",
        "explanation_text_hr": "Ocijeniti ukupni dojam prodajne povrsine.",
        "default_finding_de": "Verkaufsflaeche nicht im optimalen Zustand.",
        "default_finding_en": "Sales floor not in optimal condition.",
        "default_finding_hr": "Prodajna povrsina nije u optimalnom stanju.",
        "default_measure_de": "Reinigungsplan erstellen und Zustaendigkeiten festlegen.",
        "default_measure_en": "Create cleaning schedule and assign responsibilities.",
        "default_measure_hr": "Izraditi plan ciscenja i odrediti odgovornosti.",
        "internal_note_de": "Fotos von Problemstellen machen.",
        "internal_note_en": "Take photos of problem areas.",
        "internal_note_hr": "Napraviti fotografije problematicnih mjesta.",
    },
    {
        "order": 21,
        "category": "Filialorganisation und Verkaufsbereitschaft",
        "category_en": "Branch Organisation and Sales Readiness",
        "category_hr": "Organizacija poslovnice i prodajna spremnost",
        "text_de": "Sind Preisauszeichnungen korrekt und aktuell?",
        "text_en": "Are price labels correct and up to date?",
        "text_hr": "Jesu li oznake cijena tocne i azurne?",
        "explanation_text_de": "Stichprobenartig mind. 30 Artikel pruefen.",
        "explanation_text_en": "Random check at least 30 items.",
        "explanation_text_hr": "Nasumicno provjeriti najmanje 30 artikala.",
        "default_finding_de": "Preisauszeichnungen teilweise fehlerhaft oder fehlend.",
        "default_finding_en": "Price labels partially incorrect or missing.",
        "default_finding_hr": "Oznake cijena djelomicno netocne ili nedostaju.",
        "default_measure_de": "Preisauszeichnung korrigieren und woechentliche Kontrolle einfuehren.",
        "default_measure_en": "Correct price labels and introduce weekly checks.",
        "default_measure_hr": "Ispraviti oznake cijena i uvesti tjednu kontrolu.",
    },
    {
        "order": 22,
        "category": "Filialorganisation und Verkaufsbereitschaft",
        "category_en": "Branch Organisation and Sales Readiness",
        "category_hr": "Organizacija poslovnice i prodajna spremnost",
        "text_de": "Ist das Personal angemessen geschult und kundenorientiert?",
        "text_en": "Is the staff adequately trained and customer-oriented?",
        "text_hr": "Je li osoblje primjereno obuceno i usmjereno na kupce?",
        "explanation_text_de": "Schulungsnachweise und Kundeninteraktion beobachten.",
        "explanation_text_en": "Observe training records and customer interactions.",
        "explanation_text_hr": "Pregledati evidenciju edukacija i promatrati interakcije s kupcima.",
        "default_finding_de": "Schulungsnachweise nicht vollstaendig oder veraltet.",
        "default_finding_en": "Training records incomplete or outdated.",
        "default_finding_hr": "Evidencija edukacija nepotpuna ili zastarjela.",
        "default_measure_de": "Fehlende Schulungen nachplanen und dokumentieren.",
        "default_measure_en": "Schedule missing trainings and document them.",
        "default_measure_hr": "Zakazati nedostajuce edukacije i dokumentirati ih.",
    },
    {
        "order": 23,
        "category": "Filialorganisation und Verkaufsbereitschaft",
        "category_en": "Branch Organisation and Sales Readiness",
        "category_hr": "Organizacija poslovnice i prodajna spremnost",
        "text_de": "Werden Oeffnungszeiten eingehalten und Personalplanung optimiert?",
        "text_en": "Are opening hours observed and staff planning optimised?",
        "text_hr": "Postuju li se radno vrijeme i optimizira li se raspored osoblja?",
        "explanation_text_de": "Dienstplaene und tatsaechliche Oeffnungszeiten vergleichen.",
        "explanation_text_en": "Compare duty rosters with actual opening hours.",
        "explanation_text_hr": "Usporediti rasporede smjena sa stvarnim radnim vremenom.",
        "default_finding_de": "Oeffnungszeiten oder Personalplanung nicht optimal.",
        "default_finding_en": "Opening hours or staff planning not optimal.",
        "default_finding_hr": "Radno vrijeme ili raspored osoblja nije optimalan.",
        "default_measure_de": "Personalplanung an Kundenfrequenz anpassen.",
        "default_measure_en": "Adjust staff planning to customer frequency.",
        "default_measure_hr": "Prilagoditi raspored osoblja frekvenciji kupaca.",
    },
    {
        "order": 24,
        "category": "Filialorganisation und Verkaufsbereitschaft",
        "category_en": "Branch Organisation and Sales Readiness",
        "category_hr": "Organizacija poslovnice i prodajna spremnost",
        "text_de": "Sind Werbemittel und Aktionsware korrekt platziert?",
        "text_en": "Are promotional materials and sale items correctly placed?",
        "text_hr": "Jesu li promotivni materijali i akcijska roba pravilno postavljeni?",
        "explanation_text_de": "Aktuelle Kampagnen und POS-Material pruefen.",
        "explanation_text_en": "Check current campaigns and POS material.",
        "explanation_text_hr": "Provjeriti aktualne kampanje i POS materijale.",
        "default_finding_de": "Werbemittel nicht vollstaendig oder korrekt platziert.",
        "default_finding_en": "Promotional materials not fully or correctly placed.",
        "default_finding_hr": "Promotivni materijali nisu potpuno ili ispravno postavljeni.",
        "default_measure_de": "Werbemittelvorgaben pruefen und korrekt umsetzen.",
        "default_measure_en": "Review promotional guidelines and implement correctly.",
        "default_measure_hr": "Pregledati smjernice za promociju i ispravno provesti.",
    },
    {
        "order": 25,
        "category": "Filialorganisation und Verkaufsbereitschaft",
        "category_en": "Branch Organisation and Sales Readiness",
        "category_hr": "Organizacija poslovnice i prodajna spremnost",
        "text_de": "Wird die Schaufenstergestaltung regelmaessig aktualisiert?",
        "text_en": "Is the window display regularly updated?",
        "text_hr": "Azurira li se izlog redovito?",
        "explanation_text_de": "Schaufenster soll mind. monatlich aktualisiert werden.",
        "explanation_text_en": "Window display should be updated at least monthly.",
        "explanation_text_hr": "Izlog treba azurirati najmanje jednom mjesecno.",
        "default_finding_de": "Schaufenstergestaltung veraltet.",
        "default_finding_en": "Window display outdated.",
        "default_finding_hr": "Izlog je zastario.",
        "default_measure_de": "Monatlichen Wechselrhythmus fuer Schaufenster einfuehren.",
        "default_measure_en": "Introduce monthly rotation cycle for window display.",
        "default_measure_hr": "Uvesti mjesecni ritam izmjene izloga.",
    },
]

# Demo branches – IDs are 7-digit branch numbers
BRANCHES = [
    {
        "id": "1001001",
        "name": "Filiale Berlin Mitte",
        "country_code": "DE",
        "address": "Friedrichstr. 100, 10117 Berlin",
        "manager_email": "branch_berlin@audit.de",
    },
    {
        "id": "1001002",
        "name": "Filiale Muenchen Zentrum",
        "country_code": "DE",
        "address": "Maximilianstr. 20, 80539 Muenchen",
    },
    {
        "id": "1002001",
        "name": "Poslovnica Zagreb Centar",
        "country_code": "HR",
        "address": "Ilica 10, 10000 Zagreb",
    },
]


def seed():
    db = get_db()

    # --- 1. Create catalog ---
    cat_ref = db.collection("auditCatalogs").document(CATALOG_ID)
    if cat_ref.get().exists:
        print("  SKIP  Catalog '{}' already exists.".format(CATALOG_ID))
    else:
        cat_ref.set(CATALOG)
        print("  OK    Catalog '{}' created.".format(CATALOG_ID))

    # --- Version (REQUIRED for incremental model) ---
    version_id = "2025-v1"
    version_number = 1

    version_ref = cat_ref.collection("versions").document(version_id)

    if not version_ref.get().exists:
        version_ref.set({
            "version": version_id,
            "versionNumber": version_number,
            "year": CATALOG_ID.get("year", 2025),
            "created_at": datetime.now(timezone.utc).isoformat(),
        })
        print("  OK    Version '{}' created.".format(version_id))
    else:
        print("  SKIP  Version '{}' exists.".format(version_id))

    # --- 2. Create questions ---
    q_count = 0

    version_id = "2025-v1"
    version_number = 1

    for q in QUESTIONS:
        q_id = "q-de-{}".format(q["order"])
        q_ref = cat_ref.collection("questions").document(q_id)

        data = dict(q)
        data["id"] = q_id

        # versioning (correct)
        data["introducedInVersionId"] = version_id
        data["introducedInVersionNumber"] = version_number

        # stable linking
        data["master_question_id"] = "master-{}".format(q["order"])

        q_ref.set(data)

        q_count += 1
        print("  OK    Q{}: {}".format(q["order"], q["text_de"][:50]))
        
    # Update question count
    cat_ref.update({"question_count": len(QUESTIONS)})
    print("\n  {} new questions added (total {}).".format(q_count, len(QUESTIONS)))

    # --- 3. Create branches and assign manager ---
    for b in BRANCHES:
        b_ref = db.collection("branches").document(b["id"])
        manager_email = b.pop("manager_email", None)
        # Look up manager user and link both ways
        manager_id = None
        if manager_email:
            mgr_docs = db.collection("users").where("email", "==", manager_email).limit(1).stream()
            mgr_doc = next(mgr_docs, None)
            if mgr_doc:
                manager_id = mgr_doc.id
                b["manager_id"] = manager_id
                # Assign branch_id to the manager user
                mgr_doc.reference.update({"branch_id": b["id"]})
                print("  LINK  {} -> {}".format(manager_email, b["id"]))
        if b_ref.get().exists:
            # Update existing branch with manager_id if needed
            if manager_id:
                b_ref.update({"manager_id": manager_id})
            print("  SKIP  Branch '{}' (exists)".format(b["name"]))
        else:
            b_ref.set(b)
            print("  OK    Branch '{}'".format(b["name"]))

    # --- 4. Create a demo audit ---
    # Find auditor user id
    auditor_docs = db.collection("users").where("role", "==", "auditor").limit(1).stream()
    auditor_doc = next(auditor_docs, None)
    if auditor_doc is None:
        print("\n  WARN  No auditor user found. Run seed_users.py first!")
        return

    auditor_data = auditor_doc.to_dict()

    audit_id = "demo-audit-berlin"
    audit_ref = db.collection("audits").document(audit_id)
    if audit_ref.get().exists:
        print("  SKIP  Demo audit '{}' (exists)".format(audit_id))
    else:
        now = datetime.now(timezone.utc)
        audit_data = {
            "id": audit_id,
            "type": "filialrevision",
            "catalog_id": CATALOG_ID,
            "branch_id": "1001001",
            "branch_name": "Filiale Berlin Mitte",
            "auditor_id": auditor_doc.id,
            "auditor_name": auditor_data.get("name", ""),
            "preparer_id": None,
            "status": "in_progress",
            "result_percent": None,
            "count_yes": 0,
            "count_no": 0,
            "count_na": 0,
            "management_summary": None,
            "created_at": now.isoformat(),
            "completed_at": None,
            "is_nachrevision": False,
            "linked_audit_id": None,
        }
        audit_ref.set(audit_data)
        print("  OK    Demo audit '{}' (status=in_progress)".format(audit_id))

    print("\nDone! Catalog with {} questions, {} branches, and demo audit ready.".format(
        len(QUESTIONS), len(BRANCHES)
    ))


if __name__ == "__main__":
    seed()


# ---------------------------------------------------------------------------
# Multi-country seed: branches + catalogs for AT, CH, HR, SI, HU, ES, SK
# ---------------------------------------------------------------------------

# 10 questions per country (2 × 5 categories).
# text_de holds the primary local-language text; text_en is always English.

def _q(order, cat_de, cat_en, text_de, text_en, finding_de, finding_en, measure_de, measure_en, note_de=None, note_en=None):
    return {
        "order": order,
        "category": cat_de,
        "category_en": cat_en,
        "text_de": text_de,
        "text_en": text_en,
        "default_finding_de": finding_de,
        "default_finding_en": finding_en,
        "default_measure_de": measure_de,
        "default_measure_en": measure_en,
        "internal_note_de": note_de,
        "internal_note_en": note_en,
    }


# Reusable category labels per language
_CAT = {
    "inv": {
        "de": "Inventursicherheit",        "at": "Inventursicherheit",        "ch": "Inventursicherheit",
        "hr": "Sigurnost inventure",       "si": "Varnost inventure",         "hu": "Készletbiztonság",
        "es": "Seguridad de inventario",   "sk": "Bezpečnosť inventára",
        "en": "Inventory Security",
    },
    "cash": {
        "de": "Geldsicherheit",            "at": "Geldsicherheit",            "ch": "Geldsicherheit",
        "hr": "Sigurnost gotovine",        "si": "Varnost gotovine",          "hu": "Pénzbiztonság",
        "es": "Seguridad de caja",         "sk": "Bezpečnosť hotovosti",
        "en": "Cash Security",
    },
    "build": {
        "de": "Haussicherheit",            "at": "Haussicherheit",            "ch": "Haussicherheit",
        "hr": "Sigurnost objekta",         "si": "Varnost objekta",           "hu": "Épületbiztonság",
        "es": "Seguridad del edificio",    "sk": "Bezpečnosť budovy",
        "en": "Building Security",
    },
    "wh": {
        "de": "Lagerorganisation",         "at": "Lagerorganisation",         "ch": "Lagerorganisation",
        "hr": "Organizacija skladišta",    "si": "Organizacija skladišča",    "hu": "Raktárszervezés",
        "es": "Organización del almacén",  "sk": "Organizácia skladu",
        "en": "Warehouse Organisation",
    },
    "branch": {
        "de": "Filialorganisation",        "at": "Filialorganisation",        "ch": "Filialorganisation",
        "hr": "Organizacija poslovnice",   "si": "Organizacija poslovalnice",  "hu": "Fiókiroda-szervezés",
        "es": "Organización de la sucursal", "sk": "Organizácia pobočky",
        "en": "Branch Organisation",
    },
}


def _questions_for(lang):
    """Return 10 standard questions in the given language (2 per category)."""
    c = {k: v[lang] for k, v in _CAT.items()}
    en = {k: v["en"] for k, v in _CAT.items()}

    # Internal notes (same for all languages – always DE/EN)
    _notes = {
        "inv": [
            ("Differenzbericht der letzten 3 Monate pruefen.",
             "Review the discrepancy report of the last 3 months."),
            ("Letzte Inventurergebnisse und Protokolle pruefen.",
             "Review last stocktaking results and protocols."),
        ],
        "cash": [
            ("Kassenberichte der letzten Woche stichprobenartig pruefen.",
             "Randomly check cash reports from the last week."),
            (None, None),
        ],
        "build": [
            ("Sicherheitsrelevant - sofortige Massnahme erforderlich!",
             "Safety-relevant - immediate action required!"),
            (None, None),
        ],
        "wh": [
            ("Fotos machen fuer Dokumentation.",
             "Take photos for documentation."),
            (None, None),
        ],
        "branch": [
            ("Fotos von Problemstellen machen.",
             "Take photos of problem areas."),
            (None, None),
        ],
    }

    texts = {
        "de": {
            "inv": [
                ("Werden Bestandsdifferenzen zeitnah analysiert und dokumentiert?",
                 "Differenzen werden nicht zeitnah bearbeitet.", "Differenzbearbeitung innerhalb von 48h sicherstellen."),
                ("Sind die Warensicherungsanlagen funktionsfähig und aktiviert?",
                 "Warensicherungsanlage nicht vollständig funktionsfähig.", "Techniker beauftragen, Anlage prüfen und instand setzen."),
            ],
            "cash": [
                ("Wird der Kassenabschluss täglich und korrekt durchgeführt?",
                 "Kassenabschluss nicht ordnungsgemäß durchgeführt.", "Kassenrichtlinie schulen, tägliche Kontrolle durch Filialleiter."),
                ("Werden Kassendifferenzen zeitnah aufgeklärt und dokumentiert?",
                 "Kassendifferenzen werden nicht zeitnah bearbeitet.", "Sofortige Meldepflicht bei Kassendifferenzen einführen."),
            ],
            "build": [
                ("Sind Notausgänge frei zugänglich und gekennzeichnet?",
                 "Notausgänge teilweise versperrt oder nicht gekennzeichnet.", "Sofortige Freigabe der Notausgänge und Beschilderung prüfen."),
                ("Sind Feuerlöscher vorhanden, geprüft und zugänglich?",
                 "Feuerlöscher nicht zugänglich oder Prüfung abgelaufen.", "Feuerlöscher prüfen lassen und Zugänglichkeit sicherstellen."),
            ],
            "wh": [
                ("Ist das Lager sauber, ordentlich und übersichtlich organisiert?",
                 "Lagerorganisation entspricht nicht den Vorgaben.", "Lager räumen, sortieren und Beschriftung anbringen."),
                ("Wird die FIFO-Methode korrekt angewendet?",
                 "FIFO wird nicht konsequent eingehalten.", "FIFO-Prinzip schulen und regelmäßig kontrollieren."),
            ],
            "branch": [
                ("Ist die Verkaufsfläche sauber, ordentlich und einladend?",
                 "Verkaufsfläche nicht im optimalen Zustand.", "Reinigungsplan erstellen und Zuständigkeiten festlegen."),
                ("Sind Preisauszeichnungen korrekt und aktuell?",
                 "Preisauszeichnungen teilweise fehlerhaft oder fehlend.", "Preisauszeichnung korrigieren und wöchentliche Kontrolle einführen."),
            ],
        },
        "hr": {
            "inv": [
                ("Analiziraju li se i dokumentiraju inventurne razlike pravovremeno?",
                 "Razlike se ne obrađuju pravovremeno.", "Osigurati obradu razlika unutar 48 sati."),
                ("Jesu li sustavi za osiguranje robe funkcionalni i aktivirani?",
                 "Sustav za osiguranje robe nije potpuno funkcionalan.", "Angažirati tehničara za pregled i popravak sustava."),
            ],
            "cash": [
                ("Provodi li se zaključak blagajne dnevno i ispravno?",
                 "Zaključak blagajne nije pravilno proveden.", "Educirati o smjernicama za blagajnu, dnevna kontrola voditelja."),
                ("Razjašnjavaju li se blagajničke razlike pravovremeno?",
                 "Blagajničke razlike se ne obrađuju pravovremeno.", "Uvesti obvezu trenutnog prijavljivanja blagajničkih razlika."),
            ],
            "build": [
                ("Jesu li izlazi u nuždi slobodno pristupačni i označeni?",
                 "Izlazi u nuždi djelomično blokirani ili neoznačeni.", "Odmah osloboditi izlaze u nuždi i provjeriti oznake."),
                ("Jesu li aparati za gašenje prisutni, pregledani i dostupni?",
                 "Aparati za gašenje nedostupni ili pregled istekao.", "Dati pregledati aparate za gašenje i osigurati pristupačnost."),
            ],
            "wh": [
                ("Je li skladište čisto, uredno i pregledno organizirano?",
                 "Organizacija skladišta ne zadovoljava zahtjeve.", "Očistiti skladište, sortirati i postaviti oznake."),
                ("Primjenjuje li se FIFO metoda ispravno?",
                 "FIFO se ne primjenjuje dosljedno.", "Educirati o FIFO principu i redovito kontrolirati."),
            ],
            "branch": [
                ("Je li prodajna površina čista, uredna i privlačna?",
                 "Prodajna površina nije u optimalnom stanju.", "Izraditi plan čišćenja i odrediti odgovornosti."),
                ("Jesu li oznake cijena točne i ažurne?",
                 "Oznake cijena djelomično netočne ili nedostaju.", "Ispraviti oznake cijena i uvesti tjednu kontrolu."),
            ],
        },
        "si": {
            "inv": [
                ("Ali se inventurne razlike pravočasno analizirajo in dokumentirajo?",
                 "Razlike se ne obravnavajo pravočasno.", "Zagotoviti obravnavo razlik v roku 48 ur."),
                ("Ali so sistemi za varovanje blaga funkcionalni in aktivirani?",
                 "Sistem za varovanje blaga ni popolnoma funkcionalen.", "Naročiti tehnika za pregled in popravilo sistema."),
            ],
            "cash": [
                ("Ali se blagajniški zaključek izvaja dnevno in pravilno?",
                 "Blagajniški zaključek ni bil pravilno izveden.", "Usposobiti zaposlene in zagotoviti dnevni nadzor."),
                ("Ali se blagajniške razlike pravočasno razjasnijo in dokumentirajo?",
                 "Blagajniške razlike se ne obravnavajo pravočasno.", "Uvesti takojšnjo obveznost prijave blagajniških razlik."),
            ],
            "build": [
                ("Ali so požarni izhodi prosto dostopni in označeni?",
                 "Požarni izhodi so delno blokirani ali neoznačeni.", "Takoj sprostiti požarne izhode in preveriti oznake."),
                ("Ali so gasilniki prisotni, pregledani in dostopni?",
                 "Gasilniki niso dostopni ali pregled je potekel.", "Dati pregledati gasilnike in zagotoviti dostopnost."),
            ],
            "wh": [
                ("Ali je skladišče čisto, urejeno in pregledno organizirano?",
                 "Organizacija skladišča ne izpolnjuje zahtev.", "Urediti skladišče, sortirati in namestiti oznake."),
                ("Ali se metoda FIFO pravilno uporablja?",
                 "Metoda FIFO se ne uporablja dosledno.", "Usposobiti zaposlene o principu FIFO in redno nadzirati."),
            ],
            "branch": [
                ("Ali je prodajni prostor čist, urejen in privlačen?",
                 "Prodajni prostor ni v optimalnem stanju.", "Izdelati načrt čiščenja in dodeliti odgovornosti."),
                ("Ali so cenovne oznake pravilne in ažurne?",
                 "Cenovne oznake so delno napačne ali manjkajo.", "Popraviti cenovne oznake in uvesti tedenski nadzor."),
            ],
        },
        "hu": {
            "inv": [
                ("A készletkülönbözeteket időben elemzik és dokumentálják?",
                 "A különbözeteket nem kezelik időben.", "Biztosítani kell a különbözetek 48 órán belüli kezelését."),
                ("Az áruvédelmi rendszerek működőképesek és aktiváltak?",
                 "Az áruvédelmi rendszer nem teljesen működőképes.", "Szerelőt megbízni a rendszer ellenőrzésére és javítására."),
            ],
            "cash": [
                ("A napi pénztárzárást megfelelően hajtják végre?",
                 "A pénztárzárás nem megfelelően történt.", "Pénztárszabályzat oktatása, napi ellenőrzés fiókvezető által."),
                ("A pénztárkülönbözeteket időben tisztázzák és dokumentálják?",
                 "A pénztárkülönbözeteket nem kezelik időben.", "Azonnali bejelentési kötelezettség bevezetése pénztárkülönbözetnél."),
            ],
            "build": [
                ("A vészkijáratok szabadon hozzáférhetők és jelöltek?",
                 "A vészkijáratok részben blokkoltak vagy jelöletlenek.", "Azonnal szabaddá tenni a vészkijáratokat és ellenőrizni a jelzéseket."),
                ("Tűzoltó készülékek jelen vannak, ellenőrzöttek és hozzáférhetők?",
                 "Tűzoltó készülékek nem hozzáférhetők vagy a vizsgálat lejárt.", "Tűzoltó készülékeket ellenőriztetni és hozzáférhetőséget biztosítani."),
            ],
            "wh": [
                ("A raktár tiszta, rendezett és áttekinthető?",
                 "A raktár szervezete nem felel meg az előírásoknak.", "Raktárt rendbe tenni, rendezni és jelöléseket elhelyezni."),
                ("A FIFO módszert megfelelően alkalmazzák?",
                 "A FIFO módszert nem alkalmazzák következetesen.", "FIFO elvét oktatni és rendszeresen ellenőrizni."),
            ],
            "branch": [
                ("Az értékesítési tér tiszta, rendezett és hívogató?",
                 "Az értékesítési tér nem optimális állapotban van.", "Takarítási terv készítése és felelősségek meghatározása."),
                ("Az árcédulák helyesek és naprakészek?",
                 "Az árcédulák részben hibásak vagy hiányoznak.", "Árcédulákat javítani és heti ellenőrzést bevezetni."),
            ],
        },
        "es": {
            "inv": [
                ("¿Se analizan y documentan oportunamente las diferencias de inventario?",
                 "Las diferencias no se procesan a tiempo.", "Asegurar el procesamiento de diferencias en 48 horas."),
                ("¿Los sistemas de seguridad de mercancías están operativos y activados?",
                 "El sistema de seguridad de mercancías no está completamente operativo.", "Contratar técnico para inspección y reparación del sistema."),
            ],
            "cash": [
                ("¿El cierre de caja diario se realiza correctamente?",
                 "El cierre de caja no se realizó correctamente.", "Capacitar en políticas de caja, control diario por el responsable."),
                ("¿Las diferencias de caja se aclaran y documentan a tiempo?",
                 "Las diferencias de caja no se procesan a tiempo.", "Introducir obligación de reporte inmediato para diferencias de caja."),
            ],
            "build": [
                ("¿Las salidas de emergencia están libres y señalizadas?",
                 "Salidas de emergencia parcialmente bloqueadas o sin señalización.", "Despejar inmediatamente las salidas de emergencia y verificar señalización."),
                ("¿Los extintores están presentes, revisados y accesibles?",
                 "Extintores no accesibles o revisión vencida.", "Revisar los extintores y garantizar su accesibilidad."),
            ],
            "wh": [
                ("¿El almacén está limpio, ordenado y organizado claramente?",
                 "La organización del almacén no cumple los requisitos.", "Ordenar el almacén, clasificar y colocar etiquetas."),
                ("¿Se aplica correctamente el método FIFO?",
                 "El método FIFO no se aplica de forma consistente.", "Capacitar en el principio FIFO y controlar regularmente."),
            ],
            "branch": [
                ("¿El área de ventas está limpia, ordenada y acogedora?",
                 "El área de ventas no está en condiciones óptimas.", "Crear plan de limpieza y asignar responsabilidades."),
                ("¿Las etiquetas de precios son correctas y actualizadas?",
                 "Las etiquetas de precios son parcialmente incorrectas o faltan.", "Corregir etiquetas de precios e introducir control semanal."),
            ],
        },
        "sk": {
            "inv": [
                ("Analyzujú a dokumentujú sa inventárne rozdiely včas?",
                 "Rozdiely sa nespracovávajú včas.", "Zabezpečiť spracovanie rozdielov do 48 hodín."),
                ("Sú systémy zabezpečenia tovaru funkčné a aktivované?",
                 "Systém zabezpečenia tovaru nie je plne funkčný.", "Privolať technika na kontrolu a opravu systému."),
            ],
            "cash": [
                ("Vykonáva sa denné uzatvorenie pokladne správne?",
                 "Uzatvorenie pokladne nebolo vykonané správne.", "Vyškoliť zamestnancov a zabezpečiť dennú kontrolu."),
                ("Objasňujú a dokumentujú sa pokladničné rozdiely včas?",
                 "Pokladničné rozdiely sa nespracovávajú včas.", "Zaviesť okamžitú povinnosť hlásiť pokladničné rozdiely."),
            ],
            "build": [
                ("Sú núdzové východy voľne prístupné a označené?",
                 "Núdzové východy sú čiastočne zablokované alebo neoznačené.", "Okamžite uvoľniť núdzové východy a skontrolovať označenie."),
                ("Sú hasiace prístroje prítomné, skontrolované a dostupné?",
                 "Hasiace prístroje nie sú dostupné alebo kontrola vypršala.", "Dať skontrolovať hasiace prístroje a zabezpečiť dostupnosť."),
            ],
            "wh": [
                ("Je sklad čistý, uprataný a prehľadne organizovaný?",
                 "Organizácia skladu nespĺňa požiadavky.", "Upratať sklad, roztriediť a umiestniť označenia."),
                ("Uplatňuje sa metóda FIFO správne?",
                 "Metóda FIFO sa neuplatňuje dôsledne.", "Vyškoliť princíp FIFO a pravidelne kontrolovať."),
            ],
            "branch": [
                ("Je predajná plocha čistá, uprataná a pohostinná?",
                 "Predajná plocha nie je v optimálnom stave.", "Vytvoriť plán upratovania a prideliť zodpovednosti."),
                ("Sú cenové štítky správne a aktuálne?",
                 "Cenové štítky sú čiastočne nesprávne alebo chýbajú.", "Opraviť cenové štítky a zaviesť týždenné kontroly."),
            ],
        },
    }

    # AT and CH use German texts
    if lang in ("at", "ch"):
        lang_texts = texts["de"]
    else:
        lang_texts = texts[lang]

    questions = []
    order = 1
    for cat_key, pairs in lang_texts.items():
        cat_notes = _notes.get(cat_key, [])
        for idx, (text, finding, measure) in enumerate(pairs):
            note_de, note_en = cat_notes[idx] if idx < len(cat_notes) else (None, None)
            questions.append(_q(
                order=order,
                cat_de=c[cat_key],
                cat_en=en[cat_key],
                text_de=text,
                text_en=pairs[0][0] if lang not in ("de", "at", "ch") else text,  # English fallback for non-DACH
                finding_de=finding,
                finding_en=finding,
                measure_de=measure,
                measure_en=measure,
                note_de=note_de,
                note_en=note_en,
            ))
            order += 1

    # Fix text_en for non-DACH countries with proper English
    _en_texts = {
        "inv": [
            ("Are inventory discrepancies analysed and documented in a timely manner?",
             "Discrepancies are not processed in a timely manner.", "Ensure discrepancy processing within 48 hours."),
            ("Are the merchandise security systems functional and activated?",
             "Merchandise security system not fully functional.", "Commission a technician to inspect and repair the system."),
        ],
        "cash": [
            ("Is the daily cash register closing performed correctly?",
             "Cash register closing not properly performed.", "Train cash register guidelines, daily checks by branch manager."),
            ("Are cash register discrepancies clarified and documented promptly?",
             "Cash discrepancies are not processed in a timely manner.", "Introduce immediate reporting obligation for cash discrepancies."),
        ],
        "build": [
            ("Are emergency exits freely accessible and marked?",
             "Emergency exits partially blocked or not marked.", "Immediately clear emergency exits and check signage."),
            ("Are fire extinguishers present, inspected and accessible?",
             "Fire extinguishers not accessible or inspection expired.", "Have fire extinguishers inspected and ensure accessibility."),
        ],
        "wh": [
            ("Is the warehouse clean, tidy and clearly organised?",
             "Warehouse organisation does not meet requirements.", "Clear warehouse, sort and apply labelling."),
            ("Is the FIFO method applied correctly?",
             "FIFO is not consistently applied.", "Train FIFO principle and check regularly."),
        ],
        "branch": [
            ("Is the sales floor clean, tidy and inviting?",
             "Sales floor not in optimal condition.", "Create cleaning schedule and assign responsibilities."),
            ("Are price labels correct and up to date?",
             "Price labels partially incorrect or missing.", "Correct price labels and introduce weekly checks."),
        ],
    }

    if lang not in ("de", "at", "ch"):
        i = 0
        for cat_key, pairs in _en_texts.items():
            for j, (en_text, en_finding, en_measure) in enumerate(pairs):
                questions[i]["text_en"] = en_text
                questions[i]["default_finding_en"] = en_finding
                questions[i]["default_measure_en"] = en_measure
                i += 1

    return questions


MULTI_COUNTRY_DATA = {
    "AT": {
        "catalog_id": "catalog-at-2025",
        "catalog": {"country_code": "AT", "version": "v1.0", "year": 2025, "language": "de"},
        "branches": [
            {"id": "1007001", "name": "Filiale Wien Zentrum", "country_code": "AT", "address": "Stephansplatz 1, 1010 Wien"},
            {"id": "1007002",   "name": "Filiale Graz",         "country_code": "AT", "address": "Hauptplatz 5, 8010 Graz"},
        ],
    },
    "CH": {
        "catalog_id": "catalog-ch-2025",
        "catalog": {"country_code": "CH", "version": "v1.0", "year": 2025, "language": "de"},
        "branches": [
            {"id": "1008001", "name": "Filiale Zürich Zentrum", "country_code": "CH", "address": "Bahnhofstrasse 10, 8001 Zürich"},
            {"id": "1008002",  "name": "Filiale Basel",           "country_code": "CH", "address": "Marktplatz 3, 4001 Basel"},
        ],
    },
    "HR": {
        "catalog_id": "catalog-hr-2025",
        "catalog": {"country_code": "HR", "version": "v1.0", "year": 2025, "language": "hr"},
        "branches": [
            {"id": "1002001",  "name": "Poslovnica Zagreb Centar", "country_code": "HR", "address": "Ilica 10, 10000 Zagreb"},
            {"id": "1002002",  "name": "Poslovnica Split",          "country_code": "HR", "address": "Marmontova 5, 21000 Split"},
        ],
    },
    "SI": {
        "catalog_id": "catalog-si-2025",
        "catalog": {"country_code": "SI", "version": "v1.0", "year": 2025, "language": "sl"},
        "branches": [
            {"id": "1003001", "name": "Poslovalnica Ljubljana Center", "country_code": "SI", "address": "Prešernov trg 1, 1000 Ljubljana"},
            {"id": "1003002", "name": "Poslovalnica Maribor",           "country_code": "SI", "address": "Glavni trg 10, 2000 Maribor"},
        ],
    },
    "HU": {
        "catalog_id": "catalog-hu-2025",
        "catalog": {"country_code": "HU", "version": "v1.0", "year": 2025, "language": "hu"},
        "branches": [
            {"id": "1004001",  "name": "Budapest Belváros fiók", "country_code": "HU", "address": "Váci utca 1, 1052 Budapest"},
            {"id": "1004002",  "name": "Debrecen fiók",           "country_code": "HU", "address": "Piac utca 10, 4024 Debrecen"},
        ],
    },
    "ES": {
        "catalog_id": "catalog-es-2025",
        "catalog": {"country_code": "ES", "version": "v1.0", "year": 2025, "language": "es"},
        "branches": [
            {"id": "1005001",    "name": "Sucursal Madrid Centro", "country_code": "ES", "address": "Gran Vía 1, 28013 Madrid"},
            {"id": "1005002", "name": "Sucursal Barcelona",      "country_code": "ES", "address": "Las Ramblas 20, 08002 Barcelona"},
        ],
    },
    "SK": {
        "catalog_id": "catalog-sk-2025",
        "catalog": {"country_code": "SK", "version": "v1.0", "year": 2025, "language": "sk"},
        "branches": [
            {"id": "1006001", "name": "Pobočka Bratislava Centrum", "country_code": "SK", "address": "Obchodná 1, 811 06 Bratislava"},
            {"id": "1006002", "name": "Pobočka Košice",              "country_code": "SK", "address": "Hlavná 5, 040 01 Košice"},
        ],
    },
}

_LANG_MAP = {"AT": "at", "CH": "ch", "HR": "hr", "SI": "si", "HU": "hu", "ES": "es", "SK": "sk"}


def seed_multi_country():
    """Seed branches and catalogs (with questions) for AT, CH, HR, SI, HU, ES, SK."""
    db = get_db()

    # German and Croatian translations so every catalog has DE/EN/HR.
    german_questions = _questions_for("de")
    croatian_questions = _questions_for("hr")

    for country_code, data in MULTI_COUNTRY_DATA.items():
        cat_id = data["catalog_id"]
        lang = _LANG_MAP[country_code]
        questions = _questions_for(lang)

        # Always add Croatian translations for every catalog (app supports DE/EN/HR).
        for i, q in enumerate(questions):
            hr_q = croatian_questions[i]

            if lang not in ("de", "at", "ch"):
                de_q = german_questions[i]

                # For Croatian catalogs, save Croatian from local text_de
                if lang == "hr":
                    q["text_hr"] = q["text_de"]
                    q["category_hr"] = q["category"]
                    q["default_finding_hr"] = q.get("default_finding_de")
                    q["default_measure_hr"] = q.get("default_measure_de")
                    q["internal_note_hr"] = q.get("internal_note_de")
                else:
                    # For other non-DACH catalogs, copy Croatian from hr questions
                    q["text_hr"] = hr_q["text_de"]
                    q["category_hr"] = hr_q["category"]
                    q["default_finding_hr"] = hr_q.get("default_finding_de")
                    q["default_measure_hr"] = hr_q.get("default_measure_de")
                    q["internal_note_hr"] = hr_q.get("internal_note_de")

                # Replace with German text
                q["text_de"] = de_q["text_de"]
                q["category"] = de_q["category"]
                q["default_finding_de"] = de_q.get("default_finding_de")
                q["default_measure_de"] = de_q.get("default_measure_de")
                q["internal_note_de"] = de_q.get("internal_note_de")
            else:
                # DACH catalogs: just add Croatian translations
                q["text_hr"] = hr_q["text_de"]
                q["category_hr"] = hr_q["category"]
                q["default_finding_hr"] = hr_q.get("default_finding_de")
                q["default_measure_hr"] = hr_q.get("default_measure_de")
                q["internal_note_hr"] = hr_q.get("internal_note_de")

        # --- Catalog ---
        cat_ref = db.collection("auditCatalogs").document(cat_id)
        if cat_ref.get().exists:
            print("  SKIP  Catalog '{}' already exists.".format(cat_id))
        else:
            cat_data = dict(data["catalog"])
            cat_data["id"] = cat_id
            cat_data["question_count"] = len(questions)
            cat_data["created_at"] = datetime.now(timezone.utc).isoformat()
            cat_ref.set(cat_data)
            print("  OK    Catalog '{}' ({}) created.".format(cat_id, country_code))

        # --- Questions (overwrite to fix language mapping) ---
        # Map local order (1-10) to shared DE master-question IDs
        _MASTER_MAP = {1: 1, 2: 3, 3: 8, 4: 9, 5: 12, 6: 13, 7: 16, 8: 17, 9: 20, 10: 21}
        for q in questions:
            q_id = "q-{}-{}".format(country_code.lower(), q["order"])
            q_ref = db.collection("questions").document(q_id)
            q_data = dict(q)
            q_data["id"] = q_id
            q_data["catalog_id"] = cat_id
            q_data["master_question_id"] = "master-{}".format(_MASTER_MAP.get(q["order"], q["order"]))
            q_ref.set(q_data)
        print("  OK    {} questions seeded for {}.".format(len(questions), country_code))

        # --- Branches ---
        for b in data["branches"]:
            b_ref = db.collection("branches").document(b["id"])
            if b_ref.get().exists:
                print("  SKIP  Branch '{}' (exists)".format(b["name"]))
            else:
                b_ref.set(b)
                print("  OK    Branch '{}'".format(b["name"]))

    print("\nMulti-country seed complete.")


def seed_all():
    """Run both the original DE seed and the multi-country seed."""
    print("=== Seeding DE catalog ===")
    seed()
    print("\n=== Seeding multi-country catalogs ===")
    seed_multi_country()


if __name__ == "__main__":
    import sys as _sys
    if len(_sys.argv) > 1 and _sys.argv[1] == "all":
        seed_all()
    elif len(_sys.argv) > 1 and _sys.argv[1] == "multi":
        seed_multi_country()
    else:
        seed_all()

