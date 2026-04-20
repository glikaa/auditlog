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
        "text_de": "Werden Bestandsdifferenzen zeitnah analysiert und dokumentiert?",
        "text_hr": "Analiziraju li se i dokumentiraju inventurne razlike pravovremeno?",
        "explanation_text_de": "Pruefung ob Differenzen innerhalb von 48h bearbeitet werden.",
        "default_finding_de": "Differenzen werden nicht zeitnah bearbeitet.",
        "default_measure_de": "Differenzbearbeitung innerhalb von 48h sicherstellen.",
        "internal_note_de": "Differenzbericht der letzten 3 Monate pruefen.",
    },
    {
        "order": 2,
        "category": "Inventursicherheit",
        "text_de": "Wird die Inventur ordnungsgemaess vorbereitet und durchgefuehrt?",
        "text_hr": "Provodi li se inventura pravilno i u skladu s propisima?",
        "explanation_text_de": "Inventurrichtlinie muss eingehalten werden.",
        "default_finding_de": "Inventurvorbereitung weist Maengel auf.",
        "default_measure_de": "Inventurrichtlinie erneut schulen und Checkliste einfuehren.",
        "internal_note_de": "Letzte Inventurergebnisse und Protokolle pruefen.",
    },
    {
        "order": 3,
        "category": "Inventursicherheit",
        "text_de": "Sind die Warensicherungsanlagen funktionsfaehig und aktiviert?",
        "text_hr": "Jesu li sustavi za osiguranje robe funkcionalni i aktivirani?",
        "explanation_text_de": "Alle Sicherungsetiketten und Antennen muessen funktionieren.",
        "default_finding_de": "Warensicherungsanlage nicht vollstaendig funktionsfaehig.",
        "default_measure_de": "Techniker beauftragen, Anlage pruefen und instand setzen.",
    },
    {
        "order": 4,
        "category": "Inventursicherheit",
        "text_de": "Werden Retouren und Warenein-/ausgaenge korrekt erfasst?",
        "text_hr": "Evidentiraju li se povrati i ulaz/izlaz robe ispravno?",
        "explanation_text_de": "Stichprobenhafte Pruefung der Warenbewegungen.",
        "default_finding_de": "Warenbewegungen werden nicht vollstaendig erfasst.",
        "default_measure_de": "Prozess der Warenerfassung schulen und kontrollieren.",
    },

    # --- Bestandsfuehrung ---
    {
        "order": 5,
        "category": "Bestandsfuehrung",
        "text_de": "Stimmt der Systembestand mit dem physischen Bestand ueberein?",
        "text_hr": "Odgovara li stanje u sustavu fizickom stanju zaliha?",
        "explanation_text_de": "Stichprobe von mind. 20 Artikeln pruefen.",
        "default_finding_de": "Abweichungen zwischen System- und physischem Bestand festgestellt.",
        "default_measure_de": "Bestandskorrektur durchfuehren und Ursachenanalyse erstellen.",
        "internal_note_de": "Mind. 20 Artikel aus verschiedenen Kategorien pruefen.",
    },
    {
        "order": 6,
        "category": "Bestandsfuehrung",
        "text_de": "Werden Nullbestaende und negative Bestaende regelmaessig bereinigt?",
        "text_hr": "Razrjesavaju li se nulte i negativne zalihe redovito?",
        "explanation_text_de": "Nullbestaende sollen woechentlich geprueft werden.",
        "default_finding_de": "Nullbestaende werden nicht regelmaessig bereinigt.",
        "default_measure_de": "Woechentliche Bereinigung der Bestandslisten einfuehren.",
    },
    {
        "order": 7,
        "category": "Bestandsfuehrung",
        "text_de": "Ist die Warenwirtschaft (IT-System) korrekt konfiguriert?",
        "text_hr": "Je li sustav upravljanja robom ispravno konfiguriran?",
        "explanation_text_de": "Bestellparameter, Meldebestaende und Lieferanteneinstellungen pruefen.",
        "default_finding_de": "Systemparameter nicht korrekt eingestellt.",
        "default_measure_de": "IT-Abteilung informieren und Parameter korrigieren.",
    },

    # --- Geldsicherheit ---
    {
        "order": 8,
        "category": "Geldsicherheit",
        "text_de": "Wird der Kassenabschluss taeglich und korrekt durchgefuehrt?",
        "text_hr": "Provodi li se zakljucak blagajne dnevno i ispravno?",
        "explanation_text_de": "Tagesabschluss muss dokumentiert und unterschrieben sein.",
        "default_finding_de": "Kassenabschluss nicht ordnungsgemaess durchgefuehrt.",
        "default_measure_de": "Kassenrichtlinie schulen, taegliche Kontrolle durch Filialleiter.",
        "internal_note_de": "Kassenberichte der letzten Woche stichprobenartig pruefen.",
    },
    {
        "order": 9,
        "category": "Geldsicherheit",
        "text_de": "Werden Kassendifferenzen zeitnah aufgeklaert und dokumentiert?",
        "text_hr": "Razjasnjavaju li se blagajnicke razlike pravovremeno?",
        "explanation_text_de": "Differenzen ueber 5 EUR muessen sofort gemeldet werden.",
        "default_finding_de": "Kassendifferenzen werden nicht zeitnah bearbeitet.",
        "default_measure_de": "Sofortige Meldepflicht bei Kassendifferenzen einfuehren.",
    },
    {
        "order": 10,
        "category": "Geldsicherheit",
        "text_de": "Ist der Tresor ordnungsgemaess gesichert und wird er regelmaessig geprueft?",
        "text_hr": "Je li sef pravilno osiguran i redovito provjeren?",
        "explanation_text_de": "Tresor muss verschlossen und Zugangsprotokoll gefuehrt sein.",
        "default_finding_de": "Tresorsicherung weist Maengel auf.",
        "default_measure_de": "Tresorrichtlinie einhalten, Zugangsliste aktualisieren.",
    },
    {
        "order": 11,
        "category": "Geldsicherheit",
        "text_de": "Werden Gutscheine und Wertmarken ordnungsgemaess verwaltet?",
        "text_hr": "Upravljaju li se bonovi i vrijednosni kuponi pravilno?",
        "explanation_text_de": "Bestandsliste und Ausgabeprotokoll pruefen.",
        "default_finding_de": "Gutscheinverwaltung nicht nachvollziehbar.",
        "default_measure_de": "Luekenlose Dokumentation der Gutscheinausgabe sicherstellen.",
    },

    # --- Haussicherheit ---
    {
        "order": 12,
        "category": "Haussicherheit",
        "text_de": "Sind Notausgaenge frei zugaenglich und gekennzeichnet?",
        "text_hr": "Jesu li izlazi u nuzdi slobodno pristupacni i oznaceni?",
        "explanation_text_de": "Flucht- und Rettungswege muessen frei und beschildert sein.",
        "default_finding_de": "Notausgaenge teilweise versperrt oder nicht gekennzeichnet.",
        "default_measure_de": "Sofortige Freigabe der Notausgaenge und Beschilderung pruefen.",
        "internal_note_de": "Sicherheitsrelevant - sofortige Massnahme erforderlich!",
    },
    {
        "order": 13,
        "category": "Haussicherheit",
        "text_de": "Sind Feuerloescher vorhanden, geprueft und zugaenglich?",
        "text_hr": "Jesu li aparati za gasenje prisutni, pregledani i dostupni?",
        "explanation_text_de": "Pruefplaketten und Zugaenglichkeit kontrollieren.",
        "default_finding_de": "Feuerloescher nicht zugaenglich oder Pruefung abgelaufen.",
        "default_measure_de": "Feuerloescher pruefen lassen und Zugaenglichkeit sicherstellen.",
    },
    {
        "order": 14,
        "category": "Haussicherheit",
        "text_de": "Funktioniert die Alarmanlage und wird sie regelmaessig getestet?",
        "text_hr": "Funkcionira li alarmni sustav i testira li se redovito?",
        "explanation_text_de": "Testprotokoll der letzten 6 Monate einsehen.",
        "default_finding_de": "Alarmanlage nicht regelmaessig getestet.",
        "default_measure_de": "Quartalsmaessige Tests der Alarmanlage einfuehren.",
    },
    {
        "order": 15,
        "category": "Haussicherheit",
        "text_de": "Ist die Schliessanlage intakt und werden Schluessel korrekt verwaltet?",
        "text_hr": "Je li sustav zakljucavanja ispravan i upravljaju li se kljucevi pravilno?",
        "explanation_text_de": "Schluesselbuch und Zugangsberechtigungen pruefen.",
        "default_finding_de": "Schluesselverwaltung nicht nachvollziehbar.",
        "default_measure_de": "Schluesselbuch aktualisieren und Zugangsliste pruefen.",
    },

    # --- Lagerorganisation ---
    {
        "order": 16,
        "category": "Lagerorganisation",
        "text_de": "Ist das Lager sauber, ordentlich und uebersichtlich organisiert?",
        "text_hr": "Je li skladiste cisto, uredno i pregledno organizirano?",
        "explanation_text_de": "Lager muss nach Warengruppen sortiert und begehbar sein.",
        "default_finding_de": "Lagerorganisation entspricht nicht den Vorgaben.",
        "default_measure_de": "Lager raeumen, sortieren und Beschriftung anbringen.",
        "internal_note_de": "Fotos machen fuer Dokumentation.",
    },
    {
        "order": 17,
        "category": "Lagerorganisation",
        "text_de": "Wird die FIFO-Methode (First In, First Out) korrekt angewendet?",
        "text_hr": "Primjenjuje li se FIFO metoda ispravno?",
        "explanation_text_de": "Aeltere Ware muss vor neuerer Ware platziert sein.",
        "default_finding_de": "FIFO wird nicht konsequent eingehalten.",
        "default_measure_de": "FIFO-Prinzip schulen und regelmaessig kontrollieren.",
    },
    {
        "order": 18,
        "category": "Lagerorganisation",
        "text_de": "Sind Gefahrstoffe korrekt gelagert und gekennzeichnet?",
        "text_hr": "Jesu li opasne tvari pravilno uskladistene i oznacene?",
        "explanation_text_de": "Gefahrstoffverordnung und Sicherheitsdatenblaetter pruefen.",
        "default_finding_de": "Gefahrstofflagerung entspricht nicht den Vorschriften.",
        "default_measure_de": "Gefahrstofflagerung gemaess Vorschriften korrigieren.",
    },
    {
        "order": 19,
        "category": "Lagerorganisation",
        "text_de": "Ist der Wareneingangsbereich organisiert und wird Ware zeitnah verraeumt?",
        "text_hr": "Je li zona prijema robe organizirana i rasporeduje li se roba pravovremeno?",
        "explanation_text_de": "Wareneingang sollte innerhalb von 24h bearbeitet werden.",
        "default_finding_de": "Wareneingang wird nicht zeitnah bearbeitet.",
        "default_measure_de": "Maximale Verraeumdauer von 24h einfuehren und kontrollieren.",
    },

    # --- Filialorganisation und Verkaufsbereitschaft ---
    {
        "order": 20,
        "category": "Filialorganisation und Verkaufsbereitschaft",
        "text_de": "Ist die Verkaufsflaeche sauber, ordentlich und einladend?",
        "text_hr": "Je li prodajna povrsina cista, uredna i privlacna?",
        "explanation_text_de": "Gesamteindruck der Verkaufsflaeche bewerten.",
        "default_finding_de": "Verkaufsflaeche nicht im optimalen Zustand.",
        "default_measure_de": "Reinigungsplan erstellen und Zustaendigkeiten festlegen.",
        "internal_note_de": "Fotos von Problemstellen machen.",
    },
    {
        "order": 21,
        "category": "Filialorganisation und Verkaufsbereitschaft",
        "text_de": "Sind Preisauszeichnungen korrekt und aktuell?",
        "text_hr": "Jesu li oznake cijena tocne i azurne?",
        "explanation_text_de": "Stichprobenartig mind. 30 Artikel pruefen.",
        "default_finding_de": "Preisauszeichnungen teilweise fehlerhaft oder fehlend.",
        "default_measure_de": "Preisauszeichnung korrigieren und woechentliche Kontrolle einfuehren.",
    },
    {
        "order": 22,
        "category": "Filialorganisation und Verkaufsbereitschaft",
        "text_de": "Ist das Personal angemessen geschult und kundenorientiert?",
        "text_hr": "Je li osoblje primjereno obuceno i usmjereno na kupce?",
        "explanation_text_de": "Schulungsnachweise und Kundeninteraktion beobachten.",
        "default_finding_de": "Schulungsnachweise nicht vollstaendig oder veraltet.",
        "default_measure_de": "Fehlende Schulungen nachplanen und dokumentieren.",
    },
    {
        "order": 23,
        "category": "Filialorganisation und Verkaufsbereitschaft",
        "text_de": "Werden Oeffnungszeiten eingehalten und Personalplanung optimiert?",
        "text_hr": "Postuju li se radno vrijeme i optimizira li se raspored osoblja?",
        "explanation_text_de": "Dienstplaene und tatsaechliche Oeffnungszeiten vergleichen.",
        "default_finding_de": "Oeffnungszeiten oder Personalplanung nicht optimal.",
        "default_measure_de": "Personalplanung an Kundenfrequenz anpassen.",
    },
    {
        "order": 24,
        "category": "Filialorganisation und Verkaufsbereitschaft",
        "text_de": "Sind Werbemittel und Aktionsware korrekt platziert?",
        "text_hr": "Jesu li promotivni materijali i akcijska roba pravilno postavljeni?",
        "explanation_text_de": "Aktuelle Kampagnen und POS-Material pruefen.",
        "default_finding_de": "Werbemittel nicht vollstaendig oder korrekt platziert.",
        "default_measure_de": "Werbemittelvorgaben pruefen und korrekt umsetzen.",
    },
    {
        "order": 25,
        "category": "Filialorganisation und Verkaufsbereitschaft",
        "text_de": "Wird die Schaufenstergestaltung regelmaessig aktualisiert?",
        "text_hr": "Azurira li se izlog redovito?",
        "explanation_text_de": "Schaufenster soll mind. monatlich aktualisiert werden.",
        "default_finding_de": "Schaufenstergestaltung veraltet.",
        "default_measure_de": "Monatlichen Wechselrhythmus fuer Schaufenster einfuehren.",
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
        if q_ref.get().exists:
            print("  SKIP  Question {} (exists)".format(q_id))
        else:
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
