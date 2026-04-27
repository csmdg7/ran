import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:net_fence_ai/models/threat_model.dart';
import 'package:net_fence_ai/services/api_service.dart';
import 'package:net_fence_ai/theme/app_theme.dart';

class ThreatsScreen extends StatefulWidget {
  const ThreatsScreen({super.key});

  @override
  State<ThreatsScreen> createState() => _ThreatsScreenState();
}

class _ThreatsScreenState extends State<ThreatsScreen> {
  final _searchController = TextEditingController();
  String _selectedChip = 'All';
  bool _loading = true;
  bool _error = false;
  List<ThreatZone> _allThreats = [];
  List<ThreatZone> _filteredThreats = [];

  final List<String> _filters = ['All', 'evil_twin', 'mac_spoof', 'open_network', 'weak_encryption'];

  @override
  void initState() {
    super.initState();
    _loadThreats();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadThreats() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    // Try to get threats with location names first
    var raw = await ApiService().getThreatsWithLocationNames();
    if (raw.isEmpty) {
      // Fallback to regular threats if location enriched endpoint fails
      raw = await ApiService().getAllThreats();
    }
    if (raw.isEmpty) {
      setState(() {
        _loading = false;
        _error = true;
      });
      return;
    }
    final zones = raw.map((item) => ThreatZone.fromJson(item)).toList();
    setState(() {
      _allThreats = zones;
      _filteredThreats = zones;
      _loading = false;
    });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    final selectedType = _selectedChip;
    final filtered = _allThreats.where((zone) {
      final matchesSearch = zone.ssid.toLowerCase().contains(query);
      final matchesType = selectedType == 'All' || zone.threatType.toLowerCase() == selectedType.toLowerCase();
      return matchesSearch && matchesType;
    }).toList();
    setState(() {
      _filteredThreats = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Threats'),
        actions: [
          if (!_loading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.threatRedLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${_allThreats.length} Threat${_allThreats.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: AppTheme.threatRed, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
      backgroundColor: AppTheme.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentBlue))
          : _error
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppTheme.threatRed, size: 48),
                      const SizedBox(height: 14),
                      const Text('Unable to load threats', style: TextStyle(color: AppTheme.threatRed, fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      ElevatedButton(onPressed: _loadThreats, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentNavy), child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadThreats,
                  backgroundColor: AppTheme.surface,
                  color: AppTheme.accentBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        _buildFilterChips(),
                        const SizedBox(height: 18),
                        if (_filteredThreats.isEmpty) _buildEmptyState(),
                        ..._filteredThreats.asMap().entries.map((entry) {
                          final index = entry.key;
                          final zone = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ThreatCard(zone: zone).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: 60 * index)).slideY(begin: 24, end: 0, duration: 500.ms, curve: Curves.easeOut),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppTheme.accentBlue),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search by network name...',
                hintStyle: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _applyFilters();
              },
              child: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final selected = filter == _selectedChip;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(
                filter == 'All' ? 'All' : filter.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _selectedChip = filter;
                });
                _applyFilters();
              },
              selectedColor: AppTheme.accentBlue,
              backgroundColor: AppTheme.surface,
              side: BorderSide(color: selected ? Colors.transparent : AppTheme.cardBorder),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.shield_rounded, size: 64, color: AppTheme.safeGreen),
        const SizedBox(height: 18),
        Text('All Clear', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.accentNavy)),
        const SizedBox(height: 10),
        const Text('No threats detected in your area', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _ThreatCard extends StatelessWidget {
  const _ThreatCard({required this.zone});
  final ThreatZone zone;

  Color get _pillColor {
    switch (zone.threatType.toLowerCase()) {
      case 'evil_twin':
        return AppTheme.threatRed.withOpacity(0.12);
      case 'mac_spoof':
        return AppTheme.warningAmberLight;
      case 'open_network':
        return AppTheme.warningAmberLight;
      case 'weak_encryption':
        return AppTheme.warningAmberLight;
      default:
        return AppTheme.accentBlueLight;
    }
  }

  Color get _pillTextColor {
    switch (zone.threatType.toLowerCase()) {
      case 'evil_twin':
        return AppTheme.threatRed;
      case 'mac_spoof':
      case 'open_network':
      case 'weak_encryption':
        return AppTheme.warningAmber;
      default:
        return AppTheme.accentBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(zone.ssid, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.accentNavy)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _pillColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(zone.threatLabel, style: TextStyle(color: _pillTextColor, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(zone.macAddress, style: GoogleFonts.jetBrainsMono(color: AppTheme.textMuted, fontSize: 12)),
          if (zone.locationName != null && zone.locationName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '📍 ${zone.locationName}',
                style: GoogleFonts.jetBrainsMono(color: AppTheme.accentBlue, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text('${zone.latitude.toStringAsFixed(4)}, ${zone.longitude.toStringAsFixed(4)}', style: GoogleFonts.jetBrainsMono(color: AppTheme.textMuted, fontSize: 11))),
              Text(zone.createdAt, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Text('${zone.radiusMeters.toStringAsFixed(0)}m radius', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
