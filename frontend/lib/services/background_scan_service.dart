import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wifi_scan/wifi_scan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:net_fence_ai/services/notification_service.dart';
import 'package:net_fence_ai/services/geofence_service.dart';

class BackgroundScanService {
  static const String baseUrl = 'http://192.168.43.1:5000'; // Update with your backend IP

  static Future<bool> performBackgroundScan() async {
    try {
      // Check permissions
      bool wifiGranted = await _checkWifiPermission();
      bool locationGranted = await _checkLocationPermission();

      if (!wifiGranted || !locationGranted) {
        return false;
      }

      // Start Wi-Fi scan
      final can = await WiFiScan.instance.canStartScan();
      if (can == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
        await Future.delayed(const Duration(seconds: 2)); // Wait for scan
      }

      // Get scan results
      final results = await WiFiScan.instance.getScannedResults();

      if (results.isEmpty) {
        return true; // No networks found, but task succeeded
      }

      // Get current location
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        // Location not available, continue without it
      }

      // Prepare scan data
      final scanData = {
        'networks': results.map((result) => {
          'ssid': result.ssid,
          'bssid': result.bssid,
          'capabilities': result.capabilities,
          'frequency': result.frequency,
          'level': result.level,
          'timestamp': DateTime.now().toIso8601String(),
        }).toList(),
        'location': position != null ? {
          'latitude': position.latitude,
          'longitude': position.longitude,
        } : null,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Send to backend
      final response = await http.post(
        Uri.parse('$baseUrl/api/scan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(scanData),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['threat_detected'] == true) {
          // Show notification for detected threat
          await NotificationService.instance.showThreatNotification(
            title: 'Threat Detected',
            body: result['threat_details'] ?? 'Unknown threat detected',
          );
        }

        // Update geofences with any new threat zones
        await GeofenceManager().updateGeofencesFromThreatZones();
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkWifiPermission() async {
    // WiFi scanning permission is handled by the wifi_scan package
    // For Android, it requires ACCESS_FINE_LOCATION
    return true; // Assume granted if we reach here
  }

  static Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
  }
}