import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService._internal();

  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  // Configure these for your environment
  static const String DEFAULT_BACKEND_URL = 'http://10.235.58.202:5000';
  static const String LOCALHOST_URL = 'http://localhost:5000';
  static const String PRODUCTION_URL = 'http://api.netfence.local:5000'; // Update with your prod URL

  String get baseUrl {
    // Use environment variable if available, otherwise use defaults
    const String envUrl = String.fromEnvironment('BACKEND_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    if (kIsWeb) {
      return LOCALHOST_URL;
    }
    
    // For Android/iOS, try to detect network environment
    return DEFAULT_BACKEND_URL; // Change to PRODUCTION_URL when deploying
  }

  /// Set custom backend URL for testing or multi-environment support
  static String? _customUrl;
  
  static void setCustomBackendUrl(String url) {
    _customUrl = url;
  }
  
  static void resetBackendUrl() {
    _customUrl = null;
  }

  Future<Map<String, dynamic>> getStats() async {
    final uri = Uri.parse('$baseUrl/api/stats');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      print('ApiService.getStats error: ${response.statusCode}');
    } catch (error) {
      print('ApiService.getStats exception: $error');
    }
    return <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getAllThreats() async {
    final uri = Uri.parse('$baseUrl/api/threats');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return List<Map<String, dynamic>>.from(body);
        }
        if (body is Map<String, dynamic> && body['threats'] is List) {
          return List<Map<String, dynamic>>.from(body['threats'] as List);
        }
      }
      print('ApiService.getAllThreats error: ${response.statusCode}');
    } catch (error) {
      print('ApiService.getAllThreats exception: $error');
    }
    return <Map<String, dynamic>>[];
  }

  Future<List<Map<String, dynamic>>> getNearbyThreats(double lat, double lon, {double radiusKm = 1.0}) async {
    final uri = Uri.parse('$baseUrl/api/threats/nearby').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'radius': radiusKm.toString(),
      },
    );
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return List<Map<String, dynamic>>.from(body);
        }
        if (body is Map<String, dynamic> && body['threats'] is List) {
          return List<Map<String, dynamic>>.from(body['threats'] as List);
        }
      }
      print('ApiService.getNearbyThreats error: ${response.statusCode}');
    } catch (error) {
      print('ApiService.getNearbyThreats exception: $error');
    }
    return <Map<String, dynamic>>[];
  }

  Future<List<Map<String, dynamic>>> getAllThreatZones() async {
    final uri = Uri.parse('$baseUrl/api/threats');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return List<Map<String, dynamic>>.from(body);
        }
        if (body is Map<String, dynamic> && body['threats'] is List) {
          return List<Map<String, dynamic>>.from(body['threats'] as List);
        }
      }
      print('ApiService.getAllThreatZones error: ${response.statusCode}');
    } catch (error) {
      print('ApiService.getAllThreatZones exception: $error');
    }
    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> uploadScan({
    required String ssid,
    required String macAddress,
    required String encryptionType,
    required int signalStrength,
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('$baseUrl/api/scan');
    final payload = {
      'ssid': ssid,
      'mac_address': macAddress,
      'encryption_type': encryptionType,
      'signal_strength': signalStrength,
      'latitude': latitude,
      'longitude': longitude,
    };

    try {
      final response = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      print('ApiService.uploadScan error: ${response.statusCode}');
    } catch (error) {
      print('ApiService.uploadScan exception: $error');
    }
    return <String, dynamic>{};
  }

  Future<bool> checkHealth() async {
    final uri = Uri.parse('$baseUrl/api/health');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (error) {
      print('ApiService.checkHealth exception: $error');
      return false;
    }
  }

  Future<Map<String, dynamic>> getLocationInfo(double latitude, double longitude) async {
    final uri = Uri.parse('$baseUrl/api/location-info?lat=$latitude&lon=$longitude');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      print('ApiService.getLocationInfo error: ${response.statusCode}');
    } catch (error) {
      print('ApiService.getLocationInfo exception: $error');
    }
    return <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getThreatsWithLocationNames() async {
    final uri = Uri.parse('$baseUrl/api/threats-with-locations');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return List<Map<String, dynamic>>.from(body);
        }
        if (body is Map<String, dynamic> && body['threats'] is List) {
          return List<Map<String, dynamic>>.from(body['threats'] as List);
        }
      }
      print('ApiService.getThreatsWithLocationNames error: ${response.statusCode}');
    } catch (error) {
      print('ApiService.getThreatsWithLocationNames exception: $error');
    }
    return <Map<String, dynamic>>[];
  }
}
