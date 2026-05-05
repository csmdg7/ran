# 🔄 Net-Fence AI - Real-Time Working & APK Safety Guide

## 📡 Complete Real-Time Workflow

### **Phase 1: App Startup & Initialization**

```
User taps app icon
    ↓
SplashScreen loads (2-3 seconds)
    ↓
System checks permissions:
├─ Location Permission
├─ Wi-Fi Permission  
├─ Notification Permission
└─ Background Service Permission
    ↓
If any permission missing:
├─ Show permission dialog
├─ User grants permission
└─ App initializes services
    ↓
DashboardScreen loads with:
├─ Total scans statistic
├─ Threats detected count
├─ Safe networks percentage
└─ Last scan timestamp
    ↓
✅ App ready for use
```

---

### **Phase 2: Manual Scanning (User Initiates)**

```
User taps "Scan Now" button on ScannerScreen
    ↓
App requests current location via GPS
    ↓
Location acquired (may take 5-10 seconds)
    ↓
WiFiScan plugin activates:
├─ Enables Wi-Fi scan mode
├─ Scans for available networks
└─ Collects network details:
   ├─ SSID (network name)
   ├─ MAC address
   ├─ Encryption type
   ├─ Signal strength
   └─ Frequency band
    ↓
For EACH network found (e.g., 8 networks):
├─ Create network object
├─ Prepare threat analysis request
└─ Send to backend API
    ↓
Backend Processing (per network):
├─ Receive network details
├─ Run advanced analysis:
│  ├─ Check for known threats
│  ├─ Analyze network patterns
│  ├─ Compare with historical data
│  └─ Generate threat score
├─ Determine threat level:
│  ├─ GREEN = Safe (Low Risk)
│  ├─ YELLOW = Caution (Medium Risk)
│  ├─ RED = Dangerous (High Risk)
│  └─ BLACK = Critical (Block Immediately)
└─ Return results to app
    ↓
App receives results:
├─ Display network list with threat indicators
├─ Show threat descriptions
├─ Enable tap-for-details functionality
└─ Store results in local database
    ↓
User sees ScannerScreen filled with:
├─ Network name
├─ Threat level (color-coded)
├─ Signal strength indicator
└─ Last detection time
    ↓
✅ Scan complete & stored
```

---

### **Phase 3: Background Scanning (Continuous)**

```
App configured for background scanning
    ↓
WorkManager registers periodic task (every 5-15 minutes)
    ↓
At scheduled interval:
├─ Wake up background service
├─ Check if Wi-Fi enabled
├─ Request location
└─ Perform quick scan
    ↓
Quick scan process:
├─ Scan for networks
├─ Send to backend (same as Phase 2)
├─ Receive threat analysis
└─ Store results
    ↓
Threat detection logic:
├─ If threat detected:
│  ├─ Check if previously detected
│  ├─ Create local notification
│  ├─ Add to threat database
│  └─ Check geofence zones
│
└─ If no threat:
   ├─ Silent success
   ├─ Update statistics
   └─ Continue monitoring
    ↓
Geofence check:
├─ Get current location
├─ Compare against threat zones database
├─ If inside threat zone radius:
│  ├─ Send critical alert
│  ├─ Notify user
│  └─ Log incident
│
└─ If outside threat zone:
   └─ Continue monitoring
    ↓
Next scheduled scan triggers after interval
    ↓
✅ Continuous background protection active
```

---

### **Phase 4: Geofence-Based Alerts**

```
Geofence service active in background
    ↓
Every 30 seconds:
├─ Get current device location
└─ Compare with known threat zones
    ↓
Threat Zone Database:
├─ SSID: "MaliciousWiFi"
├─ Location: (40.7128, -74.0060)
├─ Radius: 100 meters
└─ Threat Type: Evil Twin
    ↓
Proximity Check:
├─ Calculate distance to threat zone
├─ Is device < radius distance?
│  └─ YES → Entering threat zone
│
└─ NO → Safe distance
    ↓
If entering threat zone:
├─ Vibrate phone
├─ Show critical notification
├─ Display alert dialog
├─ Log incident with timestamp
└─ User can view location on map
    ↓
If exiting threat zone:
├─ Show "now safe" notification
└─ Clear alert
    ↓
✅ Location monitoring complete
```

---

### **Phase 5: Real-Time Map Display**

```
User opens Map screen
    ↓
App loads OpenStreetMap
    ↓
Query threat database for all threats
    ↓
For each threat in database:
├─ Create marker on map
├─ Color code by threat level:
│  ├─ RED = Critical threats
│  ├─ ORANGE = High threats
│  ├─ YELLOW = Medium threats
│  └─ GREEN = Low/safe areas
├─ Add threat zone radius circle
└─ Display threat name on hover
    ↓
User can:
├─ Tap marker for details
├─ Zoom in/out
├─ Pan around map
└─ View real-time location
    ↓
Current location indicator shows:
├─ Current device position (blue dot)
├─ Distance to nearest threat
└─ Threat zones in vicinity
    ↓
✅ Interactive threat map ready
```

---

### **Phase 6: Threat History & Statistics**

```
User views Threats screen / Dashboard
    ↓
App queries local SQLite database
    ↓
Statistics calculated:
├─ Total networks scanned: COUNT(*) from network_scans
├─ Threats detected: COUNT(*) where is_flagged = 1
├─ Safe networks: Total scanned - Threats detected
├─ Detection rate: (Threats / Total) × 100
└─ Most recent threat: MAX(timestamp)
    ↓
Threat history displayed:
├─ Sort by newest first
├─ Show detailed info per threat:
│  ├─ Network name
│  ├─ Detection timestamp
│  ├─ Threat type
│  ├─ Location coordinates
│  └─ Risk level
│
└─ Allow filtering by:
   ├─ Date range
   ├─ Threat level
   └─ Location radius
    ↓
User actions on history:
├─ View threat on map
├─ Add to whitelist/blacklist
├─ Delete old entries
└─ Export threat report
    ↓
✅ History & stats available
```

---

## 🔒 APK Safety, Integrity & Functionality Checklist

### **Building APK Safely (Pre-Build)**

```
✅ Step 1: Clean Build Environment
   └─ cd frontend
   └─ flutter clean
   └─ rm -rf build/ .dart_tool/
   └─ flutter pub get

✅ Step 2: Verify Dependencies
   └─ flutter pub outdated
   └─ Ensure no deprecated packages
   └─ Check compatibility matrix

✅ Step 3: Run Linting
   └─ flutter analyze
   └─ Fix any warnings/errors
   └─ Check code quality

✅ Step 4: Run Tests (if available)
   └─ flutter test
   └─ Verify all tests pass
   └─ Check code coverage

✅ Step 5: Verify Build Config
   └─ Check android/app/build.gradle.kts:
      ├─ compileSdk = 34 ✓
      ├─ minSdk = 21 ✓
      ├─ targetSdk = 34 ✓
      └─ coreLibraryDesugaringEnabled = true ✓
```

---

### **Building Release APK Safely**

```bash
# Command to build
cd c:\Users\Chetana\NET_FENCE_AI\Net_Fence_AI\frontend
flutter build apk --release

# Output location
# build/app/outputs/flutter-apk/app-release.apk
```

**Expected Output:**
```
✓ Built build/app/outputs/flutter-apk/app-release.apk (47.2 MB).
```

---

### **APK Integrity Verification**

#### **1. File Size Check (Indicates Corruption)**
```bash
# Get APK file size
dir build\app\outputs\flutter-apk\app-release.apk

# Expected: 40-60 MB
# If < 30 MB or > 80 MB → Possible corruption
```

**Safe Size Range:** 40-60 MB  
**Corrupted Indicators:** <30 MB, >80 MB, or 0 KB

---

#### **2. APK Signature Verification**
```bash
# Verify APK is properly signed
jarsigner -verify -verbose build\app\outputs\flutter-apk\app-release.apk

# Expected output: "jar verified"
# If fails: APK is corrupted or unsigned
```

---

#### **3. APK Contents Check**
```bash
# Extract and verify APK structure
7z l build\app\outputs\flutter-apk\app-release.apk | findstr ".dex"

# Should show: classes.dex (main code file)
# If missing: APK is corrupted
```

---

#### **4. Runtime Validation**
```bash
# Install APK
adb install build\app\outputs\flutter-apk\app-release.apk

# Expected: "Success"
# If installation fails: APK corrupted

# Check installation
adb shell pm list packages | findstr "net_fence_ai"
# Should output: "com.example.net_fence_ai_frontend"
```

---

### **APK Safety Validation Before Distribution**

```
✅ Checksum Verification (SHA-256)
   └─ Generate: certutil -hashfile app-release.apk SHA256
   └─ Document hash value
   └─ Share with users for verification
   └─ Users can verify: certutil -hashfile app-release.apk SHA256

✅ Antivirus Scan
   └─ Upload to VirusTotal.com
   └─ Ensure 0 detections
   └─ Document scan report

✅ Code Obfuscation (Recommended)
   └─ Enable in pubspec.yaml
   └─ Protects proprietary code
   └─ Reduces reverse engineering risk

✅ Signing Certificate
   └─ Use release.keystore (already configured)
   └─ Never lose the signing key
   └─ Store securely (encrypted backup)
```

---

## ⚙️ Real-Time Data Flow Diagram

```
┌─────────────────┐
│  ANDROID PHONE  │
│  Net-Fence AI   │
└────────┬────────┘
         │
    ┌────┴────────────────────────────┐
    │                                 │
    ↓                                 ↓
┌─────────────────┐          ┌──────────────────┐
│ Wi-Fi Scanning  │          │ GPS/Location     │
│ (Built-in)      │          │ Service          │
└────────┬────────┘          └────────┬─────────┘
         │                           │
    ┌────┴───────────────────────────┴─────┐
    │                                      │
    ↓                                      ↓
┌──────────────────────────────────────────────────┐
│  Flutter App (Dart)                              │
│  ├─ DashboardScreen                             │
│  ├─ ScannerScreen                               │
│  ├─ MapScreen                                   │
│  └─ ThreatsScreen                              │
└────────────────┬─────────────────────────────────┘
                 │
                 │ HTTP POST Request
                 │ (network data)
                 ↓
    ┌────────────────────────┐
    │  BACKEND (Flask)       │
    │  http://[IP]:5000      │
    │                        │
    │  POST /api/scan        │
    │  ├─ Receives: SSID,    │
    │  │    MAC, encryption  │
    │  └─ Returns: threat    │
    │     status, risk level │
    └────────┬───────────────┘
             │
             ↓
    ┌────────────────────────┐
    │  ML Analysis Engine    │
    │  - Pattern Detection   │
    │  - Threat Scoring      │
    │  - Risk Classification │
    └────────┬───────────────┘
             │
             ↓
    ┌────────────────────────┐
    │  SQLite Database       │
    │  ├─ Threats stored     │
    │  ├─ Scan history       │
    │  └─ Statistics         │
    └────────────────────────┘
             │
             │ HTTP Response
             │ (threat data)
             ↓
    ┌────────────────────────┐
    │  Local SQLite (Phone)  │
    │  ├─ Cache results      │
    │  ├─ Threat zones       │
    │  └─ Scan history       │
    └────────┬───────────────┘
             │
             ↓
    ┌────────────────────────┐
    │  UI Update & Display   │
    │  ├─ Color-code results │
    │  ├─ Show map markers   │
    │  └─ Send notifications │
    └────────────────────────┘
```

---

## 🔐 APK Distribution Checklist

Before sharing APK publicly:

```
Pre-Release (Development APK)
├─ ✅ Builds successfully without errors
├─ ✅ Installs on test device without crashing
├─ ✅ All permissions request correctly
├─ ✅ Scanning works and returns results
├─ ✅ Map displays correctly
├─ ✅ Notifications trigger properly
├─ ✅ Background service runs
├─ ✅ No sensitive data in logs
└─ ✅ File size is within expected range (40-60 MB)

Release Build (Production APK)
├─ ✅ Signed with release keystore
├─ ✅ Passes antivirus scan (0 detections)
├─ ✅ SHA-256 hash documented
├─ ✅ Size verified (not corrupted)
├─ ✅ All features tested on multiple devices
├─ ✅ No debug symbols included
├─ ✅ No hardcoded credentials
├─ ✅ Permissions are necessary & minimal
├─ ✅ Privacy policy included
└─ ✅ Backend URL configured for production
```

---

## 🚨 Detecting APK Corruption

### **Signs of Corruption**

| Issue | Indicator | Fix |
|-------|-----------|-----|
| **Incomplete Download** | File size < 30 MB | Re-download APK |
| **Corrupted Signature** | Install fails with "Parse error" | Rebuild APK |
| **Missing Dependencies** | App crashes on startup | Clean build + rebuild |
| **Bad Manifest** | "Application not installed" | Check build config |
| **Corrupted Dex** | Constant crashes | Rebuild with `flutter clean` |

---

## 📊 Real-Time Monitoring

### **During Active Scanning**

```
Backend Logs (watch in real-time):
└─ POST /api/scan received
   ├─ Timestamp
   ├─ Network: "WiFi-Name"
   ├─ MAC: "AA:BB:CC:DD:EE:FF"
   └─ Risk Analysis:
      ├─ Isolation Forest Score: 0.35 (Low)
      ├─ Evil Twin Check: PASS
      ├─ Rule-Based: SAFE
      └─ Final Result: GREEN (Safe Network)

App Logs (flutter logs command):
└─ [INFO] Scan initiated at location 40.7128, -74.0060
   ├─ [INFO] 8 networks detected
   ├─ [INFO] Sending to backend...
   ├─ [INFO] Response received (200 OK)
   └─ [INFO] Results displayed to user
```

---

## ✅ Verification Steps After Installation

```
On Android Phone:

1. Tap App Icon → SplashScreen appears (2-3 sec)
   ├─ Verify: No crashes during launch

2. Accept Permission Requests
   ├─ Verify: All dialogs appear
   ├─ Verify: Permissions granted successfully

3. Dashboard Screen Loads
   ├─ Verify: Statistics display correctly
   ├─ Verify: No empty/null values

4. Tap "Scan Now"
   ├─ Verify: Scanning starts
   ├─ Verify: Networks detected (give 15-30 seconds)
   ├─ Verify: Results show threat levels

5. Tap Map
   ├─ Verify: OpenStreetMap loads
   ├─ Verify: Threat markers visible
   ├─ Verify: Current location shows

6. Enable Background Scanning
   ├─ Verify: Permission granted
   ├─ Verify: Service starts
   ├─ Verify: Notifications appear periodically

7. Leave App Running
   ├─ Verify: No crashes after 1 hour
   ├─ Verify: Background tasks complete
   ├─ Verify: Battery usage reasonable (<5%/hour)
```

---

## 🎯 Successful Deployment Sign-Off

```
✅ APK Safety Verified
   └─ Signature valid
   └─ No tampering detected
   └─ SHA-256 hash documented

✅ APK Functionality Verified
   └─ All features working
   └─ No crashes or exceptions
   └─ Performance acceptable

✅ APK Un-Corrupted Verified
   └─ Proper file size (40-60 MB)
   └─ All required files present
   └─ Installation successful on multiple devices

✅ Ready for Distribution
   └─ Can share with users
   └─ Can deploy to app stores
   └─ Can publish as open source
```

---

**Your APK is safe, working, and un-corrupted when all verification steps pass! 🎉**
