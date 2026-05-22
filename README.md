# NetFenceAI

## Intelligent Network Intrusion Detection System — Advanced Wi‑Fi Threat Detection (IsolationForest ML fallback; PoC)

NetFenceAI is a cross-platform mobile security application designed to detect malicious Wi-Fi networks and alert users before they connect. The project includes a Flutter-based Android frontend and a Python Flask backend for analysis, real-time scanning, and map-based threat visualization.

## Repository Structure

- `frontend/` - Flutter application source
  - `android/` - Android Gradle configuration and native integration
  - `ios/`, `macos/`, `windows/`, `linux/` - platform folders
  - `lib/` - Dart app logic, UI screens, services, and models
- `backend/` - Python Flask API and machine learning inference
  - `app.py` - backend entry point
  - `routes/` - API endpoints for scan ingestion and threat queries
  - `models/` - database and ML model helpers
- `web_dashboard.html` - web-based dashboard demo for analytics and testing
- `test_data_generator.py` - local test dataset generator

## Key Features

- Real-time Wi-Fi threat scanning and analysis
- Evil twin detection using SSID and MAC correlation
- MAC spoofing detection with local admin / randomized address checks
- Location-aware threat scoring and alert logging
- Background scanning support for persistent protection
- AI/ML anomaly detection for unknown Wi-Fi threats
- Map-based threat visualization with OpenStreetMap

## Android App Build

### Prerequisites
- Flutter SDK installed and configured
- Android SDK installed with API level 36
- Java JDK 11 or newer

### Build Debug APK

```powershell
cd frontend
flutter clean
flutter pub get
flutter build apk --debug
```

The generated APK is available at:

```text
frontend\build\app\outputs\flutter-apk\app-debug.apk
```

## Backend Setup

### Prerequisites
- Python 3.8+
- Virtual environment support

### Run Backend

```powershell
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
python app.py
```

The backend server exposes the API on `http://127.0.0.1:5000` by default.

## How It Works

1. The Flutter app scans nearby Wi-Fi networks using native platform plugins.
2. Each network is analyzed for encryption type, signal strength, and MAC properties.
3. The backend applies rule-based checks and ML anomaly detection.
4. Threats are recorded and displayed on the mobile dashboard and map.
5. Users receive immediate alerts for high-risk networks.

## Notes

- Current Android compile SDK is set to 36 for plugin compatibility.
- The project uses local processing to keep user data private.
- The app target is Android; the repository includes example desktop platform folders for Flutter compatibility.

## Commit & Push

This repo is connected to:

`https://github.com/csmdg7/NetFenceAI`

## Contact

For development or deployment questions, review the `frontend` and `backend` folders for implementation details.
