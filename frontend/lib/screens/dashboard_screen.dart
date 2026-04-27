import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:net_fence_ai/services/api_service.dart';
import 'package:net_fence_ai/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  bool _error = false;
  int _totalScans = 0;
  int _totalThreats = 0;
  int _safeNetworks = 0;
  int _activeZones = 0;
  List<Map<String, dynamic>> _breakdown = [];
  Map<String, dynamic>? _latestThreat;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    final result = await ApiService().getStats();
    if (result.isEmpty) {
      setState(() {
        _loading = false;
        _error = true;
      });
      return;
    }

    setState(() {
      _totalScans = result['total_scans'] is int ? result['total_scans'] as int : int.tryParse('${result['total_scans']}') ?? 0;
      _totalThreats = result['threats_found'] is int ? result['threats_found'] as int : int.tryParse('${result['threats_found']}') ?? 0;
      _safeNetworks = result['safe_networks'] is int ? result['safe_networks'] as int : int.tryParse('${result['safe_networks']}') ?? 0;
      _activeZones = result['active_zones'] is int ? result['active_zones'] as int : int.tryParse('${result['active_zones']}') ?? 0;
      _breakdown = _parseBreakdown(result['threat_breakdown']);
      _latestThreat = result['latest_threat'] is Map<String, dynamic> ? result['latest_threat'] as Map<String, dynamic> : <String, dynamic>{};
      _loading = false;
    });
  }

  List<Map<String, dynamic>> _parseBreakdown(dynamic raw) {
    if (raw is List) {
      return raw.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }
        return <String, dynamic>{};
      }).toList();
    }
    if (raw is Map<String, dynamic>) {
      return raw.entries
          .map((entry) => {
                'label': entry.key.toString(),
                'count': int.tryParse('${entry.value}') ?? 0,
              })
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'evil_twin':
      case 'threat':
        return AppTheme.threatRed;
      case 'mac_spoof':
        return AppTheme.warningAmber;
      case 'open_network':
        return AppTheme.warningAmber;
      case 'weak_encryption':
        return AppTheme.warningAmber;
      default:
        return AppTheme.accentBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _loadStats,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentNavy,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentBlue),
            )
          : _error
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppTheme.threatRed, size: 48),
                      const SizedBox(height: 14),
                      const Text('Backend Offline', style: TextStyle(color: AppTheme.threatRed, fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadStats,
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentNavy),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  backgroundColor: AppTheme.surface,
                  color: AppTheme.accentBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBanner(),
                        const SizedBox(height: 20),
                        _buildStatGrid(),
                        const SizedBox(height: 20),
                        _buildThreatBreakdown(),
                        const SizedBox(height: 20),
                        _buildLatestThreatCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatusBanner() {
    final bool threatActive = _totalThreats > 0;
    final Color accent = threatActive ? AppTheme.threatRed : AppTheme.safeGreen;
    final String title = threatActive ? '⚠ Threats Detected' : '✓ All Networks Clear';
    final String subtitle = threatActive ? 'Review the latest security events.' : 'No dangerous networks found in the last scan.';

    return Container(
      decoration: BoxDecoration(
        color: threatActive ? AppTheme.threatRedLight : AppTheme.safeGreenLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 120,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: accent)),
                  const SizedBox(height: 8),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              '$_totalThreats',
              style: GoogleFonts.spaceGrotesk(fontSize: 48, fontWeight: FontWeight.w700, color: accent),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).move(begin: const Offset(-30, 0), end: Offset.zero, duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildStatGrid() {
    final cards = [
      _StatCard(
        title: 'Total Scans',
        value: _totalScans,
        icon: Icons.wifi_rounded,
        backgroundColor: AppTheme.accentBlueLight,
        iconColor: AppTheme.accentBlue,
      ),
      _StatCard(
        title: 'Threats Found',
        value: _totalThreats,
        icon: Icons.gpp_bad_rounded,
        backgroundColor: AppTheme.threatRedLight,
        iconColor: AppTheme.threatRed,
      ),
      _StatCard(
        title: 'Safe Networks',
        value: _safeNetworks,
        icon: Icons.gpp_good_rounded,
        backgroundColor: AppTheme.safeGreenLight,
        iconColor: AppTheme.safeGreen,
      ),
      _StatCard(
        title: 'Active Zones',
        value: _activeZones,
        icon: Icons.location_on_rounded,
        backgroundColor: AppTheme.warningAmberLight,
        iconColor: AppTheme.warningAmber,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.15,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return cards[index]
            .animate()
            .fadeIn(duration: 500.ms, delay: Duration(milliseconds: 80 * index))
            .scale(begin: Offset(0.9, 0.9), end: Offset(1.0, 1.0), duration: 500.ms, curve: Curves.easeOut);
      },
    );
  }

  Widget _buildThreatBreakdown() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Threat Breakdown', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlueLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('${_totalThreats} total', style: const TextStyle(color: AppTheme.accentBlue, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ..._breakdown.map((item) {
            final label = item['label']?.toString() ?? 'Unknown';
            final count = item['count'] is int ? item['count'] as int : int.tryParse('${item['count']}') ?? 0;
            final typeColor = _typeColor(label);
            final progress = (_totalThreats > 0 ? (count / _totalThreats).clamp(0.0, 1.0) : 0.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(label.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w700))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(color: typeColor, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 10,
                      color: AppTheme.surfaceAlt,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [typeColor.withOpacity(0.9), AppTheme.warningAmber.withOpacity(0.6)]),
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.4, end: 0, duration: 500.ms),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLatestThreatCard() {
    if (_latestThreat == null || _latestThreat!.isEmpty) {
      return Container();
    }

    final threatType = _latestThreat!['threat_type']?.toString() ?? 'Threat';
    final ssid = _latestThreat!['ssid']?.toString() ?? 'Unknown SSID';
    final mac = _latestThreat!['mac_address']?.toString() ?? _latestThreat!['macAddress']?.toString() ?? '00:00:00:00:00:00';
    final coords = '${_latestThreat!['latitude'] ?? '0.0'}, ${_latestThreat!['longitude'] ?? '0.0'}';
    final createdAt = _latestThreat!['created_at']?.toString() ?? _latestThreat!['createdAt']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.threatRedLight,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text('Latest Threat', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.threatRed)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.threatRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(threatType.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(color: AppTheme.threatRed, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ssid, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 10),
                Text(mac, style: GoogleFonts.jetBrainsMono(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Text(coords, style: GoogleFonts.jetBrainsMono(color: AppTheme.textSecondary, fontSize: 12))),
                    Text(createdAt, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 18),
          Text('$value', style: GoogleFonts.spaceGrotesk(fontSize: 34, fontWeight: FontWeight.w700, color: iconColor)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
