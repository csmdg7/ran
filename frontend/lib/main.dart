import 'package:flutter/material.dart';
import 'package:net_fence_ai/screens/splash_screen.dart';
import 'package:net_fence_ai/services/notification_service.dart';
import 'package:net_fence_ai/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
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
