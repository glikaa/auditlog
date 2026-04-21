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

## Setup-Anleitung (Schritt fuer Schritt)

### 1. Python Virtual Environment einrichten

Das Projekt nutzt Python 3.6. Das venv liegt im Wurzelverzeichnis `c:\flutter_dev\.venv`.

```powershell
# Ins Projektverzeichnis wechseln
cd c:\flutter_dev

# Virtual Environment erstellen (einmalig)
python -m venv .venv

# Aktivieren (Windows PowerShell)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
& .\.venv\Scripts\Activate.ps1
```

### 2. Backend-Dependencies installieren

> **Hinweis:** Python 3.6 ist nicht kompatibel mit `protobuf >= 4.x`.
> Deshalb muss `protobuf<4` explizit gepinnt werden.

```powershell
# Alle Dependencies inkl. protobuf-Pin installieren (einmalig)
pip install fastapi==0.83.0 uvicorn==0.17.0 firebase-admin==5.4.0 ^
    python-jose python-multipart pydantic==1.9.2 fpdf python-dotenv ^
    "protobuf<4"
```

Falls ein **interner pip-Index** (z.B. Artifactory) genutzt wird, werden
ggf. Credentials abgefragt – Username und Token eingeben.

### 3. Firebase Credentials ablegen

Die Datei `serviceAccountKey.json` aus der Firebase Console herunterladen
(Projekteinstellungen → Dienstkonten) und in `my_app/backend/` ablegen.

### 4. Demo-Daten seeden (einmalig)

```powershell
cd my_app\backend
python seed_users.py
python seed_catalog.py
```

### 5. Backend starten

```powershell
cd c:\flutter_dev\my_app\backend
python run.py
```

Der Server laeuft dann unter:
- **API:** http://127.0.0.1:8000
- **Swagger Docs:** http://127.0.0.1:8000/docs

> **Wichtig:** Das Backend muss laufen, bevor die Flutter-App gestartet wird!
> Ohne laufendes Backend schlaegt jeder HTTP-Request fehl
> (`XMLHttpRequest error` / `DioException`).

### 6. Frontend starten (neues Terminal)

```powershell
cd c:\flutter_dev\my_app

# Flutter Dependencies holen (einmalig)
flutter pub get

# Im Browser starten
flutter run -d chrome
```

### Troubleshooting

| Problem | Ursache | Loesung |
|---|---|---|
| `XMLHttpRequest error` in der App | Backend nicht gestartet | Backend mit `python run.py` starten |
| `ModuleNotFoundError: No module named 'uvicorn'` | Dependencies fehlen | `pip install` wie in Schritt 2 ausfuehren |
| `ModuleNotFoundError: No module named 'dotenv'` | `python-dotenv` fehlt | `pip install python-dotenv` |
| `protobuf >= 4.21 requires Python >= 3.7` | protobuf-Version zu hoch fuer Python 3.6 | `pip install "protobuf<4"` |
| Backend startet, aber App zeigt Fehler | CORS oder Port-Konflikt | Pruefen ob Port 8000 frei ist (`netstat -ano \| findstr :8000`) |

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
- [x] Anhaenge / Bilder Upload
- [x] Nachrevision (Gegenueberstellung)
- [ ] Reporting-Screen
- [ ] Cloud Run Deployment
