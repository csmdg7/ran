import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as gc;

class OSMService {
  static final OSMService _instance = OSMService._internal();
  factory OSMService() => _instance;
  OSMService._internal();

  // Nominatim API endpoint (free, open source)
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org';
  final Map<String, String> _placeNameCache = {};

  /// Get place name from coordinates using reverse geocoding
  Future<String> getPlaceNameFromCoordinates(double latitude, double longitude) async {
    final cacheKey = '$latitude,$longitude';
    
    // Check cache first
    if (_placeNameCache.containsKey(cacheKey)) {
      return _placeNameCache[cacheKey]!;
    }

    try {
      // Try using built-in geocoding first (faster)
      final placemarks = await gc.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        String placeName = placemark.name ?? '';
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          placeName = '${placemark.locality}, ${placemark.administrativeArea}';
        }
        if (placeName.isEmpty && placemark.street != null) {
          placeName = placemark.street ?? 'Unknown Location';
        }
        
        _placeNameCache[cacheKey] = placeName;
        return placeName;
      }
    } catch (e) {
      print('Built-in geocoding failed: $e');
    }

    // Fallback to Nominatim API
    try {
      final uri = Uri.parse(
        '$_nominatimUrl/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1'
      );
      
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'Net-Fence-AI/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract place name from response
        String placeName = data['name'] ?? 'Unknown Location';
        
        if (data['address'] != null) {
          final address = data['address'];
          final parts = <String>[];
          
          if (address['road'] != null) parts.add(address['road']);
          if (address['suburb'] != null) parts.add(address['suburb']);
          if (address['city'] != null) parts.add(address['city']);
          if (address['country'] != null) parts.add(address['country']);
          
          if (parts.isNotEmpty) {
            placeName = parts.join(', ');
          }
        }
        
        _placeNameCache[cacheKey] = placeName;
        return placeName;
      }
    } catch (e) {
      print('Nominatim reverse geocoding failed: $e');
    }

    // Return coordinates as fallback
    final fallback = '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    _placeNameCache[cacheKey] = fallback;
    return fallback;
  }

  /// Get coordinates from place name
  Future<Map<String, double>?> getCoordinatesFromPlaceName(String placeName) async {
    try {
      final locations = await gc.locationFromAddress(placeName);
      if (locations.isNotEmpty) {
        return {
          'latitude': locations.first.latitude,
          'longitude': locations.first.longitude,
        };
      }
    } catch (e) {
      print('Built-in geocoding for place name failed: $e');
    }

    // Fallback to Nominatim
    try {
      final uri = Uri.parse(
        '$_nominatimUrl/search?format=json&q=${Uri.encodeComponent(placeName)}&limit=1'
      );
      
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'Net-Fence-AI/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final results = jsonDecode(response.body);
        if (results.isNotEmpty) {
          return {
            'latitude': double.parse(results[0]['lat'].toString()),
            'longitude': double.parse(results[0]['lon'].toString()),
          };
        }
      }
    } catch (e) {
      print('Nominatim geocoding failed: $e');
    }

    return null;
  }

  /// Get detailed location info from coordinates
  Future<Map<String, dynamic>> getLocationDetails(double latitude, double longitude) async {
    try {
      final uri = Uri.parse(
        '$_nominatimUrl/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1&extratags=1&namedetails=1'
      );
      
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'Net-Fence-AI/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return {
          'name': data['name'] ?? 'Unknown',
          'address': data['address'] ?? {},
          'display_name': data['display_name'] ?? '',
          'osm_id': data['osm_id'],
          'osm_type': data['osm_type'],
          'importance': data['importance'] ?? 0.0,
          'place_rank': data['place_rank'] ?? 0,
        };
      }
    } catch (e) {
      print('Error getting location details: $e');
    }

    return {};
  }

  /// Clear the cache
  void clearCache() {
    _placeNameCache.clear();
  }

  /// Get cache statistics
  Map<String, int> getCacheStats() {
    return {
      'cached_locations': _placeNameCache.length,
    };
  }
}