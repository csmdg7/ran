import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wifi_scan/wifi_scan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:net_fence_ai/services/notification_service.dart';
import 'package:net_fence_ai/services/api_service.dart';

class BackgroundScanService {
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

      // Send each network individually to backend for proper threat detection
      bool allSent = true;
      for (final result in results) {
        try {
          final scanData = {
            'ssid': result.ssid ?? 'Hidden SSID',
            'mac_address': result.bssid ?? 'unknown',
            'encryption_type': _parseEncryption(result.capabilities ?? ''),
            'signal_strength': result.level ?? -100,
            'latitude': position?.latitude ?? 0.0,
            'longitude': position?.longitude ?? 0.0,
            'vendor': 'Unknown',
          };

          final response = await http.post(
            Uri.parse('${ApiService().baseUrl}/api/scan'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(scanData),
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200 || response.statusCode == 201) {
            final result = jsonDecode(response.body);
            if (result['threat_detected'] == true) {
              // Show notification for detected threat
              await NotificationService.instance.showThreatNotification(
                title: 'Threat Detected',
                body: '${scanData['ssid']}: ${result['threat_type']}',
              );
            }
          } else {
            allSent = false;
          }
        } catch (e) {
          allSent = false;
        }
      }

      // NOTE: Geofence update disabled - package is discontinued
      // await GeofenceManager().updateGeofencesFromThreatZones();
      
      return allSent;
    } catch (e) {
      return false;
    }
  }

  static String _parseEncryption(String capabilities) {
    final caps = capabilities.toUpperCase();
    if (caps.contains('WPA2')) return 'WPA2';
    if (caps.contains('WPA')) return 'WPA';
    if (caps.contains('WEP')) return 'WEP';
    if (caps.contains('OPEN')) return 'OPEN';
    return caps.isEmpty ? 'OPEN' : 'WPA2'; // Default to WPA2 if not recognized
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