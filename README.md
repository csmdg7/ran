# 🛡️ NetFenceAI: Intelligent Wi-Fi Threat Detection for Mobile

NetFenceAI is a functional, full-stack Proof-of-Concept (PoC) designed to detect, log, and visualize malicious wireless networks. It pairs a Flutter-based Android frontend with a local Python Flask backend to ingest real-time radio-frequency metrics and evaluate spatial threat signatures.

---

## ⚙️ Architecture & Data Flow

```text
[ Flutter App ] ───(HTTP JSON: SSID, BSSID, RSSI, GPS)───> [ Python Flask Backend ]
       │                                                              │
[ UI Map Updates ] <───(Threat Score Vector [0-10])───────────────────[ Processing Engine ]
```

---

## 🛰️ Core Features

* **Real-time Metadata Extraction:** Scans and extracts raw hardware-level Wi-Fi parameters (SSID, BSSID/MAC, RSSI dBm values, encryption flags) and GPS coordinate streams.
* **Dual-Layer Threat Scoring:** * **Primary:** Deterministic rule-based engine (detects open networks, weak WEP encryption, MAC spoofing via `02:` prefixes, and Evil Twins via SSID/MAC correlation).
  * **Secondary:** Optional Isolation Forest ML anomaly detection for behavioral pattern scoring.
* **Spatial Threat Mapping:** Renders visual danger vectors and coordinate intersections directly onto an interactive OpenStreetMap UI.
* **Persistent Background Protection:** Leverages `WorkManager` for continuous background scanning and pushes OS-level notifications for high-risk networks.
* **Local Processing:** Designed as an edge-computing PoC to keep spatial and network data localized and private.

---

## 📁 Repository Structure

* `frontend/` - Flutter application source
  * `android/` - Android Gradle configuration and native integration
  * `lib/` - Dart app logic, UI screens, services, and models
* `backend/` - Python Flask API and machine learning inference
  * `app.py` - Backend entry point
  * `routes/` - API endpoints for scan ingestion and threat queries
  * `models/` - Database and ML model helpers
  * `test_data_generator.py` - Local test dataset generator

---

## 🚀 Android App Build

### Prerequisites
* Flutter SDK installed and configured
* Android SDK installed with API level 36
* Java JDK 11 or newer

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

## 📝 Engineering Notes & Limitations
Geofencing: Active perimeter-crossing background geofence alerts are currently disabled due to library deprecation. Threat zones are instead visually rendered via coordinate mapping on the dashboard.

Android SDK: Current Android compile SDK is set to API 36 to ensure native plugin compatibility (wifi_scan, geolocator).

Environment: This is an edge-computing prototype designed to run locally. For enterprise deployment, the backend would require containerization (Docker) and cloud-hosted ML training pipelines.

## Commit & Push

This repo is connected to:

`https://github.com/csmdg7/NetFenceAI`

## Contact

For development or deployment questions, review the `frontend` and `backend` folders for implementation details.
