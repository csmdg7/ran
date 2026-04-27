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
    _geofenceService.setup(
      interval: 5000, // Check location every 5 seconds
      accuracy: 100, // 100 meters accuracy
      loiteringDelayMs: 60000, // 1 minute delay for dwell events
      statusChangeDelayMs: 10000, // 10 seconds delay for status changes
      useActivityRecognition: true,
      allowMockLocations: false,
      printDevLog: false,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC,
    );

    // Listen to geofence events
    _geofenceSubscription = _geofenceService.listenToGeofenceStatus.stream.listen(
      (GeofenceStatus status) async {
        await _handleGeofenceEvent(status);
      },
    );

    // Start geofence service
    await _geofenceService.start();
  }

  Future<void> _handleGeofenceEvent(GeofenceStatus status) async {
    final geofence = status.geofence;
    final event = status.event;

    // Only handle ENTER events for threat zones
    if (event == GeofenceEvent.ENTER) {
      // Extract threat zone info from geofence data
      final zoneData = geofence.data;
      if (zoneData != null && zoneData['isThreatZone'] == true) {
        final zoneName = zoneData['zoneName'] ?? 'Unknown Threat Zone';
        final threatLevel = zoneData['threatLevel'] ?? 'High';

        // Show notification
        await NotificationService.instance.showThreatNotification(
          title: '🚨 Threat Zone Entered!',
          body: 'You have entered $zoneName. Threat level: $threatLevel. Exercise caution!',
        );

        // Optionally, vibrate or play sound
        // You can add more sophisticated alerts here
      }
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
          data: {
            'isThreatZone': true,
            'zoneName': zone['name'] ?? 'Threat Zone ${zone['id']}',
            'threatLevel': zone['threat_level'] ?? 'High',
            'zoneId': zone['id'],
          },
        );
        geofences.add(geofence);
      }

      // Add geofences to service
      if (geofences.isNotEmpty) {
        await _geofenceService.addGeofenceList(geofences);
        _activeGeofences = geofences;
      }
    } catch (e) {
      print('Error updating geofences: $e');
    }
  }

  Future<void> _clearAllGeofences() async {
    if (_activeGeofences.isNotEmpty) {
      await _geofenceService.removeGeofenceList(_activeGeofences);
      _activeGeofences.clear();
    }
  }

  Future<void> stopGeofencing() async {
    await _clearAllGeofences();
    await _geofenceService.stop();
    await _geofenceSubscription?.cancel();
  }

  List<Geofence> get activeGeofences => _activeGeofences;
}