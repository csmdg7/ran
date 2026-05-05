# NET-FENCE AI - Complete Project Documentation

## 🎯 PROJECT OVERVIEW

**Net-Fence AI** is an **Intelligent Network Intrusion Detection System** that combines:
- **Real-time Wi-Fi threat detection** on Android phones
- **Machine Learning-based threat classification** (Isolation Forest algorithm)
- **Geofencing-based threat zone monitoring**
- **Background scanning and notifications**
- **Evil Twin detection** (same SSID, different MAC address)

**Purpose:** Protect mobile users from malicious Wi-Fi networks through AI-powered detection and real-time alerts.

---

## 📊 TECH STACK

### **Frontend (Flutter - Cross-Platform Mobile)**
- **Framework:** Flutter 3.19+
- **Language:** Dart
- **Target Platforms:** Android (primary), iOS support
- **UI Framework:** Material Design 3
- **Key Libraries:**
  - `flutter_map`: Real-time threat mapping with OpenStreetMap
  - `wifi_scan`: Wi-Fi network scanning
  - `geolocator` + `geofence_service`: Location & geofencing
  - `flutter_local_notifications`: Real-time threat alerts
  - `workmanager`: Background Wi-Fi scanning tasks
  - `http`: REST API communication
  - `google_fonts`: Typography

### **Backend (Python Flask - REST API)**
- **Framework:** Flask + Flask-CORS
- **Language:** Python 3.8+
- **ML Engine:** Scikit-learn (Isolation Forest)
- **Database:** SQLite (local)
- **Key Libraries:**
  - `scikit-learn`: Machine Learning threat detection
  - `numpy` + `pandas`: Data processing
  - `gunicorn`: Production server
  - `flask-limiter`: Rate limiting
  - `python-dotenv`: Environment configuration

### **AI/ML Training**
- **Language:** Python
- **Algorithm:** Isolation Forest (unsupervised anomaly detection)
- **Training Data:** Historical Wi-Fi scan patterns
- **Output:** Threat classification (High/Medium/Low risk)

---

## 🏗️ PROJECT STRUCTURE

```
Net_Fence_AI/
├── frontend/                          # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart                 # App entry point
│   │   ├── screens/
│   │   │   ├── splash_screen.dart    # Loading screen
│   │   │   ├── dashboard_screen.dart # Main dashboard (stats)
│   │   │   ├── map_screen.dart       # Threat zone map view
│   │   │   ├── scanner_screen.dart   # Wi-Fi scanner
│   │   │   └── threats_screen.dart   # Threat list view
│   │   ├── services/
│   │   │   ├── api_service.dart      # Backend REST API calls
│   │   │   ├── background_scan_service.dart # Background Wi-Fi scanning
│   │   │   ├── geofence_service.dart # Geofence event handling
│   │   │   └── notification_service.dart # Local notifications
│   │   ├── models/
│   │   │   └── threat_model.dart     # Data models
│   │   └── theme/
│   │       └── app_theme.dart        # UI styling
│   ├── pubspec.yaml                  # Flutter dependencies
│   ├── android/                       # Android-specific config
│   │   ├── app/build.gradle.kts      # Gradle build config
│   │   └── AndroidManifest.xml       # Permissions & manifest
│   ├── ios/                           # iOS-specific config
│   └── build/                         # Build output (generated)
│
├── backend/                           # Flask REST API
│   ├── app.py                         # Flask app initialization
│   ├── inference.py                   # AI inference engine
│   ├── real_scanner.py                # Network scanning utility
│   ├── test_api.py                    # API tests
│   ├── requirements.txt               # Python dependencies
│   ├── models/
│   │   ├── db.py                      # SQLite database setup
│   │   └── __init__.py
│   ├── routes/
│   │   ├── scan_routes.py             # POST /api/scan endpoint
│   │   ├── alert_routes.py            # Alert/threat endpoints
│   │   └── __init__.py
│   ├── ml/
│   │   ├── detector.py                # Threat detection logic
│   │   └── __init__.py
│   ├── security/
│   │   └── security_manager.py        # Security utilities
│   ├── services/
│   │   ├── osm_service.py             # OpenStreetMap integration
│   │   └── __init__.py
│   └── netfence.db                    # SQLite database (runtime)
│
├── Net_Fence_AI/                      # ML Training Code
│   ├── brain.py                       # Main AI model training
│   ├── train_model.py                 # Model training pipeline
│   └── test_integration.py            # Integration tests
│
└── PROJECT_DOCUMENTATION.md           # This file
```

---

## 🔄 ARCHITECTURE FLOW

### **User Journey: Network Scan**
```
1. User opens app → SplashScreen → DashboardScreen
2. User taps "Scan" → ScannerScreen
3. App gets location via Geolocator
4. App scans Wi-Fi networks via WiFiScan
5. For EACH network found:
   ├─ Send to Backend: POST /api/scan with network details
   ├─ Backend runs AI threat detection (Isolation Forest)
   ├─ Return: threat_detected: bool, threat_type: string
   └─ Append to UI results list
6. Show scan results with threat indicators
7. Store scan in local database
```

### **Real-Time Alert Flow**
```
1. Background task (WorkManager) runs every 5-15 minutes
2. Performs Wi-Fi scan
3. Sends to backend for threat analysis
4. If threat detected:
   ├─ Show local notification
   ├─ Check if in geofence zone
   └─ Log to database
5. Geofence service monitors threat zones
6. On geofence entry → Show alert notification
```

### **Backend Processing**
```
POST /api/scan receives: {ssid, mac_address, encryption_type, signal_strength, latitude, longitude}
    ↓
Run Isolation Forest ML model
    ↓
Check for Evil Twin (same SSID, different MAC in 10 min window)
    ↓
Apply rule-based fallback if insufficient historical data
    ↓
Return: {threat_detected: bool, threat_type: string, risk_level: High/Medium/Low}
    ↓
Save to SQLite database
```

---

## 📡 API ENDPOINTS

### **Backend URLs**
- **Development:** `http://10.235.58.202:5000` (must match phone's WiFi network)
- **Production:** Would use cloud-hosted backend

### **Endpoints**

#### **1. Health Check**
```
GET /health
Response: {"status": "ok"}
```

#### **2. Submit Wi-Fi Scan**
```
POST /api/scan
Request: {
  "ssid": "WiFi-Network",
  "mac_address": "AA:BB:CC:DD:EE:FF",
  "encryption_type": "WPA2",
  "signal_strength": -65,
  "latitude": 40.7128,
  "longitude": -74.0060,
  "vendor": "Apple Inc."
}
Response: {
  "threat_detected": false,
  "threat_type": null,
  "risk_level": "Low",
  "confidence": 0.95
}
```

#### **3. Get All Threats**
```
GET /api/threats
Response: [
  {
    "id": 1,
    "ssid": "MaliciousWiFi",
    "mac_address": "AA:BB:CC:DD:EE:FF",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "radius_meters": 100,
    "threat_type": "evil_twin",
    "created_at": "2024-04-30T10:30:00"
  }
]
```

#### **4. Get Nearby Threats (Geofence)**
```
GET /api/threats/nearby?lat=40.7128&lon=-74.0060&radius=1.0
Response: [ ... threats within 1km ... ]
```

#### **5. Get Statistics**
```
GET /api/stats
Response: {
  "total_scans": 150,
  "threats_detected": 12,
  "safe_networks": 138,
  "last_scan": "2024-04-30T11:00:00"
}
```

---

## 🤖 THREAT DETECTION LOGIC

### **Priority Order**

**1. EVIL TWIN DETECTION (Highest Priority)**
- Check: Same SSID but different MAC address within 10 minutes
- Risk Level: **CRITICAL**
- Action: Block immediately, notify user

**2. RULE-BASED DETECTION**
- Open Network (No Encryption) → **HIGH RISK**
- WEP Encryption → **HIGH RISK**
- MAC Address Spoofing (starts with 02:) → **MEDIUM RISK**

**3. MACHINE LEARNING DETECTION (Isolation Forest)**
- Trained on historical scan patterns
- Anomaly scoring: 0-1 (1 = anomaly)
- Threshold:
  - score > 0.7 → **HIGH RISK**
  - score 0.4-0.7 → **MEDIUM RISK**
  - score < 0.4 → **LOW RISK**

### **Features Used**
- Encryption Type (numerical: 0-3)
- Signal Strength (dBm: -30 to -100)
- MAC Randomization (binary)
- Historical patterns (if trained)

---

## 🗄️ DATABASE SCHEMA

### **network_scans Table**
```sql
CREATE TABLE network_scans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ssid TEXT,
    mac_address TEXT,
    encryption_type TEXT,
    signal_strength INTEGER,
    latitude REAL,
    longitude REAL,
    timestamp TEXT,
    is_flagged INTEGER DEFAULT 0
);
```

### **threat_zones Table**
```sql
CREATE TABLE threat_zones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ssid TEXT,
    mac_address TEXT,
    latitude REAL,
    longitude REAL,
    radius_meters REAL DEFAULT 50,
    threat_type TEXT,
    created_at TEXT
);
```

---

## 🔧 ANDROID BUILD CONFIGURATION

### **Key Settings (android/app/build.gradle.kts)**
```kotlin
android {
    compileSdk = 34
    minSdk = 21
    targetSdk = 34
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true  // For Java 8+ features
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

### **Required Permissions (AndroidManifest.xml)**
```xml
<!-- Network Access -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

<!-- Wi-Fi Scanning -->
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE"/>
<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES"/>

<!-- Location Services -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>

<!-- Background Work -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/>

<!-- Notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

---

## 🔐 SECURITY FEATURES

### **Implemented**
✅ CORS enabled for secure cross-origin API calls
✅ Rate limiting on backend endpoints
✅ Cleartext HTTP allowed for local development (can be disabled)
✅ SQLite database with proper query parameterization
✅ Permission validation before sensitive operations

### **Recommended (Not Yet Implemented)**
🔲 HTTPS/SSL for production backend
🔲 OAuth2 authentication
🔲 API key validation
🔲 Encrypted local storage
🔲 VPN detection

---

## 🎯 KEY FEATURES

### **Mobile App (Flutter)**
| Feature | Status | Implementation |
|---------|--------|-----------------|
| Real-time Wi-Fi Scanning | ✅ | WiFiScan plugin |
| Threat Detection | ✅ | Backend API integration |
| Live Threat Map | ✅ | flutter_map with OSM |
| Background Scanning | ✅ | WorkManager periodic task |
| Geofencing Alerts | ✅ | geofence_service plugin |
| Local Notifications | ✅ | flutter_local_notifications |
| Dashboard Stats | ✅ | /api/stats endpoint |
| Threat History | ✅ | Local SQLite + backend |

### **Backend (Flask)**
| Feature | Status | Implementation |
|---------|--------|-----------------|
| REST API | ✅ | Flask blueprints |
| AI Threat Detection | ✅ | Isolation Forest ML |
| Evil Twin Detection | ✅ | Historical comparison |
| Database Persistence | ✅ | SQLite |
| CORS Support | ✅ | flask-cors |
| Rate Limiting | ✅ | flask-limiter |

---

## 🚀 BUILD & DEPLOYMENT

### **Development Build (Debug APK)**
```powershell
cd frontend
flutter clean
flutter pub get
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### **Production Build (Release APK)**
```powershell
cd frontend
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### **Backend Deployment**
```bash
cd backend
pip install -r requirements.txt
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

### **IP Configuration**
- **Local Development:** `http://10.235.58.202:5000` (adjust to your PC IP)
- **Phone must be on same WiFi network** to reach backend
- Or use **ngrok/CloudFlare Tunnel** for remote access

---

## 🐛 KNOWN ISSUES & FIXES APPLIED

### **Fixed Issues**
1. ✅ **AndroidManifest.xml Corruption** - Missing `tools` namespace declaration
2. ✅ **Backend URL Mismatch** - Unified to single URL across services
3. ✅ **Unsafe URL Parameters** - Changed to `Uri.queryParameters`
4. ✅ **Geofence Not Subscribing** - Removed non-existent stream subscription
5. ✅ **Location Null Handling** - Added proper error handling with UI feedback
6. ✅ **Core Library Desugaring** - Enabled for Java 8+ feature compatibility

### **Current Limitations**
- ⚠️ Geofence_service package is **discontinued** (no longer maintained)
- ⚠️ Model training requires historical data (bootstrapping needed)
- ⚠️ Background scanning battery intensive
- ⚠️ Local development requires IP whitelisting

---

## 📋 DEPLOYMENT CHECKLIST

- [ ] Backend IP configured in `api_service.dart` (line 18)
- [ ] Backend running and accessible: `curl http://10.235.58.202:5000/health`
- [ ] Phone connected to same WiFi network
- [ ] USB debugging enabled on Android phone
- [ ] Flutter SDK installed and in PATH
- [ ] Android SDK configured (API 21+)
- [ ] APK built successfully: `flutter build apk --debug`
- [ ] App installed on phone: `flutter run --debug`
- [ ] All permissions granted on first launch
- [ ] Background scanning enabled in settings
- [ ] Test scan performed successfully

---

## 🔗 USEFUL COMMANDS

```powershell
# Navigate to frontend
cd c:\Users\Chetana\NET_FENCE_AI\Net_Fence_AI\frontend

# Check Flutter setup
flutter doctor

# List connected devices
flutter devices

# Run in debug mode
flutter run --debug

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Clean build
flutter clean

# Check dependencies
flutter pub outdated

# Get latest dependencies
flutter pub get

# Run tests
flutter test
```

```bash
# Backend commands
cd backend
pip install -r requirements.txt
python app.py                    # Development
gunicorn -w 4 -b 0.0.0.0:5000 app:app  # Production
python test_api.py              # Run API tests
```

---

## 👨‍💻 DEVELOPMENT WORKFLOW

1. **Write Code** → Make changes in any file
2. **Hot Reload** → `flutter run --debug` (press 'r' to reload)
3. **Test Backend** → Use Postman or `curl` for API testing
4. **Build APK** → `flutter build apk --debug`
5. **Deploy to Phone** → `flutter run --debug` or `adb install`
6. **Monitor Logs** → `flutter logs`

---

## 📞 SUPPORT & DEBUGGING

### **Common Issues & Solutions**

**Issue:** "Backend Offline" error in app
- **Solution:** Verify backend IP in code, restart backend server, check WiFi connection

**Issue:** Permissions not granted
- **Solution:** Go to Settings → Apps → Net-Fence AI → Permissions → Grant all permissions

**Issue:** Wi-Fi scan returns empty
- **Solution:** Ensure location permission granted, WiFi enabled, try again in 5 seconds

**Issue:** Background scanning not working
- **Solution:** Check battery optimization settings, disable Doze mode for app

**Issue:** Gradle build fails
- **Solution:** Run `flutter clean`, `flutter pub get`, verify Android SDK installed

---

## 📚 REFERENCES

- [Flutter Documentation](https://flutter.dev/docs)
- [scikit-learn Isolation Forest](https://scikit-learn.org/stable/modules/ensemble.html#isolation-forest)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Android Permissions](https://developer.android.com/guide/topics/permissions/overview)
- [OpenStreetMap](https://www.openstreetmap.org/)

---

**Last Updated:** April 30, 2026
**Version:** 1.0.0
**Maintainer:** Net-Fence AI Team
