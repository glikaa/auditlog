# Audit Web App – Filialrevision

Enterprise Web Application zur Digitalisierung der Filialrevision.  
Seminar-Case: ISE-Web Engineering, Mobile Apps und Full-Stack-Entwicklung – Steinbeis University Berlin (SMT).

---

## Technologie-Stack

| Schicht | Technologie |
|---|---|
| Frontend | Flutter 3.38 (Web, Dart) |
| Backend | Python 3.6, FastAPI 0.83 |
| Datenbank | Firebase Firestore |
| Auth | JWT (python-jose) |
| PDF-Export | fpdf |
| IDE | Visual Studio Code |

---

## Projektstruktur

```
my_app/
├── lib/                        # Flutter Frontend
│   ├── main.dart               # Entry Point, API-URL, BLoC-Provider
│   ├── core/
│   │   ├── network/api_client.dart   # Dio HTTP-Client mit Auth-Token
│   │   ├── router.dart               # Named Routes
│   │   ├── theme.dart                # Material 3 Theme
│   │   └── utils/responsive.dart     # Responsive Breakpoints
│   ├── features/
│   │   ├── auth/               # Login Screen + State
│   │   └── audit/
│   │       ├── data/           # Models, DataSources, Repository-Impl
│   │       ├── domain/         # Entities, Repository-Interface
│   │       └── presentation/   # Screens, Cubits, Widgets
│   ├── generated/l10n/         # Auto-generierte Lokalisierung
│   └── l10n/                   # ARB-Dateien (DE, HR, EN)
├── backend/                    # FastAPI Backend
│   ├── run.py                  # Server-Start (Python 3.6 kompatibel)
│   ├── main.py                 # FastAPI App, CORS, Router
│   ├── app/
│   │   ├── routers/
│   │   │   ├── auth.py         # POST /auth/login, GET /auth/me
│   │   │   ├── audits.py       # CRUD Audits, Responses, PDF-Export
│   │   │   ├── catalogs.py     # Fragenkataloge + Fragen
│   │   │   └── reports.py      # Reporting-Endpoints
│   │   ├── models/             # Pydantic Models (v1)
│   │   └── services/
│   │       ├── auth_service.py       # JWT Token, HTTPBearer
│   │       └── firebase_service.py   # Firestore Client
│   ├── seed_users.py           # 6 Demo-Benutzer anlegen
│   ├── seed_catalog.py         # 25 Fragen + Demo-Audit anlegen
│   └── serviceAccountKey.json  # Firebase Credentials (nicht committen!)
├── test/                       # Flutter Widget Tests
├── pubspec.yaml                # Flutter Dependencies
└── README.md
```

---

## Voraussetzungen

- **Flutter SDK** >= 3.x ([flutter.dev](https://flutter.dev))
- **Python** >= 3.6
- **Firebase Projekt** mit aktiviertem Firestore
- **Google Chrome** (Flutter Web Target)

---

## Backend starten

```bash
cd my_app/backend

# Virtual Environment erstellen (einmalig)
python -m venv venv

# Aktivieren
# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

# Dependencies installieren (einmalig)
pip install fastapi==0.83.0 uvicorn==0.17.0 firebase-admin==5.4.0
pip install python-jose python-multipart pydantic==1.9.2 fpdf

# Firebase Credentials ablegen
# serviceAccountKey.json aus Firebase Console -> Projekteinstellungen -> Dienstkonten

# Demo-Daten seeden (einmalig)
python seed_users.py
python seed_catalog.py

# Server starten
python run.py
# -> http://127.0.0.1:8000
# -> Swagger Docs: http://127.0.0.1:8000/docs
```

---

## Frontend starten

```bash
cd my_app

# Dependencies holen
flutter pub get

# Im Browser starten
flutter run -d chrome
```

---

## Demo-Accounts

| E-Mail | Passwort | Rolle |
|---|---|---|
| admin@audit.de | admin123 | Administrator |
| auditor@audit.de | auditor123 | Pruefer / Revision |
| preparer@audit.de | preparer123 | Vorbereitende Person |
| department@audit.de | department123 | Abteilungsleitung |
| branch@audit.hr | branch123 | Filialleitung |
| district@audit.de | district123 | Bezirksleitung |

---

## API-Endpoints (Auswahl)

| Methode | Pfad | Beschreibung |
|---|---|---|
| POST | /auth/login | Login (JSON: email, password) |
| GET | /audits | Audit-Liste (gefiltert nach Rolle) |
| GET | /audits/{id} | Einzelnes Audit |
| POST | /audits/{id}/complete | Audit abschliessen |
| POST | /audits/{id}/release | Freigabe fuer Filiale |
| PUT | /audits/{id}/responses/{qId} | Antwort speichern (Auto-Save) |
| GET | /audits/{id}/export/pdf | PDF-Export |
| GET | /catalogs/{id}/questions | Fragenkatalog laden |
| GET | /reports/branches | Ergebnisse je Filiale |
| GET | /reports/questions/top5 | Top-5 Ja/Nein Fragen |

---

## Architektur

**Frontend:** Clean Architecture mit 3 Schichten:
- **Domain** – Entities, Repository-Interfaces
- **Data** – Models (fromJson/toJson), DataSources (Dio), Repository-Impl
- **Presentation** – Screens, BLoC/Cubit, Widgets

**State Management:** flutter_bloc (Cubit)

**Backend:** FastAPI mit Router-Pattern:
- Routers fuer Auth, Audits, Catalogs, Reports
- Pydantic v1 Models fuer Validation
- Firebase Firestore als Datenbank

---

## Features

- [x] Login mit JWT-Token und Rollen
- [x] Audit-Dashboard mit Status-Anzeige
- [x] Fragenkatalog mit 25 Fragen in 6 Kategorien
- [x] Ja/Nein/Entfaellt Rating mit Auto-Save (800ms Debounce)
- [x] Live-Statistik (Ja/Nein/Entfaellt + Fortschritt + Ergebnis %)
- [x] PDF-Export (Revisionsbericht)
- [x] Audit abschliessen + Freigabe
- [x] Responsive Layout (Mobile/Tablet/Desktop)
- [x] Mehrsprachigkeit (DE, HR, EN)
- [x] Einstellungsseite (Sprache, Profil)
- [ ] Anhaenge / Bilder Upload
- [ ] Nachrevision (Gegenueberstellung)
- [ ] Reporting-Screen
- [ ] Cloud Run Deployment
