import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:net_fence_ai/models/threat_model.dart';
import 'package:net_fence_ai/services/api_service.dart';
import 'package:net_fence_ai/theme/app_theme.dart';
import 'package:net_fence_ai/services/geofence_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _loading = true;
  List<ThreatZone> _zones = [];

  @override
  void initState() {
    super.initState();
    _loadThreats();
  }

  Future<void> _loadThreats() async {
    setState(() => _loading = true);
    // Try to get threats with location names first
    var raw = await ApiService().getThreatsWithLocationNames();
    if (raw.isEmpty) {
      // Fallback to regular threats if location enriched endpoint fails
      raw = await ApiService().getAllThreats();
    }
    final zones = raw.map((item) => ThreatZone.fromJson(item)).toList();
    setState(() {
      _zones = zones;
      _loading = false;
    });

    // Update geofences with the latest threat zones
    await GeofenceManager().updateGeofencesFromThreatZones();
  }

  void _showThreatDetails(ThreatZone zone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: zone.threatColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  zone.threatLabel,
                  style: TextStyle(color: zone.threatColor, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              const SizedBox(height: 18),
              Text(zone.ssid, style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.accentNavy)),
              const SizedBox(height: 10),
              Text(zone.macAddress, style: GoogleFonts.jetBrainsMono(color: AppTheme.textMuted, fontSize: 13)),
              if (zone.locationName != null && zone.locationName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '📍 ${zone.locationName}',
                    style: GoogleFonts.jetBrainsMono(color: AppTheme.accentBlue, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 16),
              Text('Coordinates', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              Text('${zone.latitude.toStringAsFixed(6)}, ${zone.longitude.toStringAsFixed(6)}', style: GoogleFonts.jetBrainsMono(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              Text('Radius', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              Text('${zone.radiusMeters.toStringAsFixed(0)} meters', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('View in Threats List'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = _zones.isNotEmpty
        ? LatLng(_zones.first.latitude, _zones.first.longitude)
        : const LatLng(12.9716, 77.5946);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Threat Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadThreats,
            tooltip: 'Refresh Geofences',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: center,
              zoom: 12,
              minZoom: 3,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'net_fence_ai_frontend',
              ),
              CircleLayer(
                circles: _zones
                    .map(
                      (zone) => CircleMarker(
                        point: LatLng(zone.latitude, zone.longitude),
                        radius: zone.radiusMeters / 30,
                        useRadiusInMeter: false,
                        color: AppTheme.threatRed.withValues(alpha: 0.15),
                        borderColor: AppTheme.threatRed.withValues(alpha: 0.8),
                        borderStrokeWidth: 2,
                      ),
                    )
                    .toList(),
              ),
              MarkerLayer(
                markers: _zones
                    .map(
                      (zone) => Marker(
                        width: 32,
                        height: 32,
                        point: LatLng(zone.latitude, zone.longitude),
                        builder: (context) {
                          return GestureDetector(
                            onTap: () => _showThreatDetails(zone),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.threatRed,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.threatRed.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Center(child: SizedBox(width: 8, height: 8, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)))),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          Positioned(
            top: 52,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded, color: AppTheme.accentNavy),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Live Threat Map', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.accentNavy)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlueLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${_zones.length} Threat${_zones.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Showing ${_zones.length} zone${_zones.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_zones.isNotEmpty) {
                        _mapController.move(center, 12);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Center Map'),
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.white.withValues(alpha: 0.7),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.accentBlue),
              ),
            ),
        ],
      ),
    );
  }
}
