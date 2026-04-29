import 'dart:async';
import 'package:geofence_service/geofence_service.dart';
import 'package:net_fence_ai/services/notification_service.dart';
import 'package:net_fence_ai/services/api_service.dart';

class GeofenceManager {
  static final GeofenceManager _instance = GeofenceManager._internal();
  factory GeofenceManager() => _instance;
  GeofenceManager._internal();

  final GeofenceService _geofenceService = GeofenceService.instance;
  StreamSubscription<GeofenceStatus>? _geofenceSubscription;
  List<Geofence> _activeGeofences = [];

  Future<void> initialize() async {
    await _setupGeofenceService();
  }

  Future<void> _setupGeofenceService() async {
    // Configure geofence service
    try {
      _geofenceService.setup(
        interval: 5000, // Check location every 5 seconds
        accuracy: 100, // 100 meters accuracy
        loiteringDelayMs: 60000, // 1 minute delay for dwell events
        statusChangeDelayMs: 10000, // 10 seconds delay for status changes
        useActivityRecognition: true,
        allowMockLocations: false,
        printDevLog: false,
      );

      // Start geofence service
      await _geofenceService.start();
    } catch (e) {
      print('Geofence service setup error: $e');
    }
  }

  Future<void> _handleGeofenceEvent(GeofenceStatus status) async {
    // Handle geofence event - placeholder for future implementation
    try {
      // Show notification for geofence entry
      await NotificationService.instance.showThreatNotification(
        title: '⚠️ Geofence Event',
        body: 'A geofence event has been detected in your area.',
      );
    } catch (e) {
      print('Error handling geofence event: $e');
    }
  }

  Future<void> updateGeofencesFromThreatZones() async {
    try {
      // Get all threat zones from backend
      final threatZones = await ApiService().getAllThreatZones();

      // Clear existing geofences
      await _clearAllGeofences();

      // Create geofences for each threat zone
      final geofences = <Geofence>[];

      for (final zone in threatZones) {
        final geofence = Geofence(
          id: 'threat_zone_${zone['id']}',
          latitude: zone['latitude'],
          longitude: zone['longitude'],
          radius: zone['radius'] ?? 100.0, // Default 100 meters
        );
        geofences.add(geofence);
      }

      // Add geofences to service
      if (geofences.isNotEmpty) {
        try {
          _geofenceService.addGeofenceList(geofences);
          _activeGeofences = geofences;
        } catch (e) {
          print('Error adding geofences: $e');
        }
      }
    } catch (e) {
      print('Error updating geofences: $e');
    }
  }

  Future<void> _clearAllGeofences() async {
    if (_activeGeofences.isNotEmpty) {
      try {
        _geofenceService.removeGeofenceList(_activeGeofences);
        _activeGeofences.clear();
      } catch (e) {
        print('Error clearing geofences: $e');
      }
    }
  }

  Future<void> stopGeofencing() async {
    await _clearAllGeofences();
    await _geofenceService.stop();
    await _geofenceSubscription?.cancel();
  }

  List<Geofence> get activeGeofences => _activeGeofences;
}