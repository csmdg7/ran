import 'package:flutter/material.dart';
import 'package:net_fence_ai/screens/splash_screen.dart';
import 'package:net_fence_ai/services/notification_service.dart';
import 'package:net_fence_ai/theme/app_theme.dart';
import 'package:workmanager/workmanager.dart';
import 'package:net_fence_ai/services/geofence_service.dart';

import 'package:net_fence_ai/services/background_scan_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background Wi-Fi scanning task
    switch (task) {
      case 'wifiScanTask':
        return await BackgroundScanService.performBackgroundScan();
      default:
        return Future.value(true);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  
  // Initialize Workmanager for background tasks
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Initialize Geofence service
  await GeofenceManager().initialize();
  
  runApp(const NetFenceAiApp());
}

class NetFenceAiApp extends StatelessWidget {
  const NetFenceAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Net-Fence AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
