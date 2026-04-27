import 'package:flutter/material.dart';
import 'package:net_fence_ai/theme/app_theme.dart';

class ThreatZone {
  final int id;
  final String ssid;
  final String macAddress;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String threatType;
  final String createdAt;
  final String? locationName;

  ThreatZone({
    required this.id,
    required this.ssid,
    required this.macAddress,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.threatType,
    required this.createdAt,
    this.locationName,
  });

  factory ThreatZone.fromJson(Map<String, dynamic> json) {
    return ThreatZone(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      ssid: json['ssid']?.toString() ?? 'Unknown Network',
      macAddress: json['mac_address']?.toString() ?? json['macAddress']?.toString() ?? '00:00:00:00:00:00',
      latitude: (json['latitude'] is num ? json['latitude'].toDouble() : double.tryParse('${json['latitude']}')) ?? 0.0,
      longitude: (json['longitude'] is num ? json['longitude'].toDouble() : double.tryParse('${json['longitude']}')) ?? 0.0,
      radiusMeters: (json['radius_meters'] is num
              ? json['radius_meters'].toDouble()
              : double.tryParse('${json['radius_meters']}')) ??
          (json['radiusMeters'] is num ? json['radiusMeters'].toDouble() : 120.0),
      threatType: json['threat_type']?.toString() ?? json['threatType']?.toString() ?? 'unknown',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? json['locationName']?.toString(),
    );
  }

  Color get threatColor {
    switch (threatType.toLowerCase()) {
      case 'evil_twin':
      case 'mac_spoof':
      case 'threat':
        return AppTheme.threatRed;
      case 'open_network':
        return AppTheme.warningAmber;
      case 'weak_encryption':
        return AppTheme.warningAmber;
      default:
        return AppTheme.accentBlue;
    }
  }

  String get threatLabel {
    switch (threatType.toLowerCase()) {
      case 'evil_twin':
        return 'Evil Twin';
      case 'mac_spoof':
        return 'MAC Spoof';
      case 'open_network':
        return 'Open Network';
      case 'weak_encryption':
        return 'Weak Encryption';
      case 'threat':
        return 'Threat';
      default:
        return 'Unknown Threat';
    }
  }
}
