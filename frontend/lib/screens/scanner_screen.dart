import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:net_fence_ai/services/api_service.dart';
import 'package:workmanager/workmanager.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _sweepController;
  bool _isScanning = false;
  bool _scanComplete = false;
  bool _threatDetected = false;
  bool _backgroundScanningEnabled = false;
  int _networksFound = 0;
  int _scanCycle = 0;
  List<Map<String, dynamic>> _scanResults = [];

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _scanResults = [];
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    // Request permissions
    final locationStatus = await Permission.location.request();
    final wifiStatus = await Permission.locationWhenInUse.request();

    if (!locationStatus.isGranted || !wifiStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission required for Wi-Fi scanning')),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _scanComplete = false;
      _scanResults = [];
      _scanCycle++;
    });

    try {
      // Start Wi-Fi scan
      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
        await Future.delayed(const Duration(seconds: 2)); // Wait for scan to complete
      }

      // Get scan results
      final accessPoints = await WiFiScan.instance.getScannedResults();

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final results = <Map<String, dynamic>>[];
      int threatsDetected = 0;

      for (final ap in accessPoints) {
        // Send each network to backend for AI analysis
        final response = await ApiService().uploadScan(
          ssid: ap.ssid ?? 'Unknown',
          macAddress: ap.bssid,
          encryptionType: ap.capabilities.contains('WPA') ? 'WPA2' :
                         ap.capabilities.contains('WEP') ? 'WEP' : 'Open',
          signalStrength: ap.level,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        final isThreat = response['threat_detected'] == true;
        if (isThreat) threatsDetected++;

        results.add({
          'ssid': ap.ssid ?? 'Hidden Network',
          'bssid': ap.bssid,
          'status': isThreat ? 'threat' : 'safe',
          'encryption': ap.capabilities.contains('WPA') ? 'WPA2' :
                       ap.capabilities.contains('WEP') ? 'WEP' : 'Open',
          'signal_strength': ap.level,
          'frequency': ap.frequency,
        });
      }

      final nearbyThreats = await ApiService().getNearbyThreats(position.latitude, position.longitude, radiusKm: 0.3);
      if (nearbyThreats.isNotEmpty) {
        await NotificationService.instance.showThreatNotification(
          title: 'Geo-Fence Alert',
          body: '${nearbyThreats.length} threat zone(s) detected near your location.',
        );
      }

      setState(() {
        _scanComplete = true;
        _isScanning = false;
        _threatDetected = threatsDetected > 0 || nearbyThreats.isNotEmpty;
        _networksFound = results.length;
        _scanResults = results;
      });

      if (nearbyThreats.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Warning: ${nearbyThreats.length} nearby threat zone(s) detected!')),
        );
      }

    } catch (e) {
      setState(() {
        _isScanning = false;
        _scanComplete = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e')),
      );
    }
  }

  Future<void> _toggleBackgroundScanning() async {
    if (_backgroundScanningEnabled) {
      // Stop background scanning
      await Workmanager().cancelByUniqueName('wifiScanTask');
      setState(() {
        _backgroundScanningEnabled = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Background scanning stopped')),
      );
    } else {
      // Start background scanning
      await Workmanager().registerPeriodicTask(
        'wifiScanTask',
        'wifiScanTask',
        frequency: const Duration(minutes: 15), // Scan every 15 minutes
        initialDelay: const Duration(minutes: 1),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
      );
      setState(() {
        _backgroundScanningEnabled = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Background scanning started - will scan every 15 minutes')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _isScanning
        ? 'SCANNING...'
        : _scanComplete
            ? 'SCAN COMPLETE — $_networksFound NETWORKS FOUND'
            : 'TAP TO SCAN';

    return Scaffold(
      appBar: AppBar(title: const Text('Network Scanner')),
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 312,
                  height: 312,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(190),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: CustomPaint(
                      painter: RadarPainter(
                        sweepAngle: _sweepController.value * pi * 2,
                        showBlips: _scanComplete || _isScanning,
                      ),
                      child: const SizedBox(width: double.infinity, height: double.infinity),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  statusText,
                  key: ValueKey(statusText),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    letterSpacing: 2,
                    color: _isScanning ? AppTheme.accentBlue : AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _buildScanButton(),
              const SizedBox(height: 16),
              _buildBackgroundScanningToggle(),
              const SizedBox(height: 26),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.cardShadow,
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Scan Results', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.accentNavy)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlueLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text('$_networksFound', style: const TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    if (_threatDetected)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.threatRedLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text('⚠ Threat Detected on this scan', style: TextStyle(color: AppTheme.threatRed, fontWeight: FontWeight.w700)),
                      ),
                    const SizedBox(height: 16),
                    ..._scanResults.map((network) => _buildResultRow(network)).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundScanningToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Background Scanning',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Automatically scan every 15 minutes',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _backgroundScanningEnabled,
            onChanged: (value) => _toggleBackgroundScanning(),
            activeColor: AppTheme.accentBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(Map<String, dynamic> result) {
    final status = result['status']?.toString() ?? 'safe';
    final isThreat = status.toLowerCase() == 'threat';
    final signalStrength = result['signal_strength']?.toString() ?? '--';
    final dotColor = isThreat ? AppTheme.threatRed : AppTheme.safeGreen;
    final pillText = isThreat ? 'THREAT' : 'SAFE';

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(result['ssid']?.toString() ?? 'Unknown', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.accentNavy))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: dotColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(pillText, style: TextStyle(color: dotColor, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(result['encryption']?.toString() ?? 'Unknown', style: GoogleFonts.jetBrainsMono(color: AppTheme.textSecondary, fontSize: 12)),
              const Spacer(),
              Row(
                children: List.generate(4, (index) {
                  final fill = index < (4 - ((signalStrength.contains('-') ? int.parse(signalStrength.replaceAll('-', '')) : 0) / 20).ceil());
                  return Container(
                    width: 6,
                    height: 18,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: fill ? dotColor : AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  RadarPainter({required this.sweepAngle, required this.showBlips});

  final double sweepAngle;
  final bool showBlips;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.stroke;

    final opacities = [0.08, 0.12, 0.16, 0.22];
    for (var i = 0; i < 4; i++) {
      paint
        ..color = AppTheme.accentBlue.withOpacity(opacities[i])
        ..strokeWidth = 1.4;
      canvas.drawCircle(center, radius * ((4 - i) / 4), paint);
    }

    paint
      ..color = AppTheme.accentBlue.withOpacity(0.08)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), paint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), paint);

    final sweepPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = SweepGradient(
        startAngle: sweepAngle - pi / 6,
        endAngle: sweepAngle,
        colors: [AppTheme.accentBlue.withOpacity(0.0), AppTheme.accentBlue.withOpacity(0.5)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), sweepAngle - pi / 6, pi / 6, true, sweepPaint);

    if (showBlips) {
      final blipPositions = [
        Offset(center.dx - radius * 0.22, center.dy - radius * 0.3),
        Offset(center.dx + radius * 0.18, center.dy - radius * 0.12),
        Offset(center.dx - radius * 0.08, center.dy + radius * 0.28),
      ];
      for (final position in blipPositions) {
        final dotPaint = Paint()..color = AppTheme.accentBlue;
        canvas.drawCircle(position, 8, dotPaint);
        canvas.drawCircle(position, 10, Paint()..style = PaintingStyle.stroke..color = AppTheme.accentBlue.withOpacity(0.18)..strokeWidth = 2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle || oldDelegate.showBlips != showBlips;
  }
}
