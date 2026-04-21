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

# Demo branches
BRANCHES = [
    {
        "id": "branch-berlin",
        "name": "Filiale Berlin Mitte",
        "country_code": "DE",
        "address": "Friedrichstr. 100, 10117 Berlin",
    },
    {
        "id": "branch-munich",
        "name": "Filiale Muenchen Zentrum",
        "country_code": "DE",
        "address": "Maximilianstr. 20, 80539 Muenchen",
    },
    {
        "id": "branch-zagreb",
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

    # --- 2. Create questions ---
    q_count = 0
    for q in QUESTIONS:
        q_id = "q-de-{}".format(q["order"])
        q_ref = db.collection("questions").document(q_id)
        data = dict(q)
        data["id"] = q_id
        data["catalog_id"] = CATALOG_ID
        data["master_question_id"] = "master-{}".format(q["order"])
        q_ref.set(data)
        q_count += 1
        print("  OK    Q{}: {}".format(q["order"], q["text_de"][:50]))

    # Update question count
    cat_ref.update({"question_count": len(QUESTIONS)})
    print("\n  {} new questions added (total {}).".format(q_count, len(QUESTIONS)))

    # --- 3. Create branches ---
    for b in BRANCHES:
        b_ref = db.collection("branches").document(b["id"])
        if b_ref.get().exists:
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
            "branch_id": "branch-berlin",
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
