import 'package:flutter/material.dart';
import 'package:net_fence_ai/screens/dashboard_screen.dart';
import 'package:net_fence_ai/screens/map_screen.dart';
import 'package:net_fence_ai/screens/scanner_screen.dart';
import 'package:net_fence_ai/screens/threats_screen.dart';
import 'package:net_fence_ai/theme/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const DashboardScreen(),
    const MapScreen(),
    const ThreatsScreen(),
    const ScannerScreen(),
  ];

  static final List<String> _labels = [
    'Dashboard',
    'Live Map',
    'Threats',
    'Scanner',
  ];

  static final List<IconData> _icons = [
    Icons.dashboard_rounded,
    Icons.map_rounded,
    Icons.wifi_tethering_error_rounded,
    Icons.radar_rounded,
  ];

  Widget _buildNavIcon(IconData icon, bool selected) {
    return Container(
      width: 48,
      height: 32,
      decoration: selected
          ? BoxDecoration(
              color: AppTheme.accentBlueLight,
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 22,
        color: selected ? AppTheme.accentBlue : AppTheme.textMuted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentNavy.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: AppTheme.surface,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'Inter'),
          unselectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'Inter'),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: List.generate(_labels.length, (index) {
            final selected = index == _selectedIndex;
            return BottomNavigationBarItem(
              icon: _buildNavIcon(_icons[index], selected),
              label: _labels[index],
            );
          }),
        ),
      ),
    );
  }
}
