import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_colors.dart';
import 'services/timer_service.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgPrimary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FocusPulseApp());
}

class FocusPulseApp extends StatefulWidget {
  const FocusPulseApp({super.key});

  @override
  State<FocusPulseApp> createState() => _FocusPulseAppState();
}

class _FocusPulseAppState extends State<FocusPulseApp> {
  late final TimerService _timerService;

  @override
  void initState() {
    super.initState();
    _timerService = TimerService();
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusPulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.bgPrimary,
        primaryColor: AppColors.greenPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.greenPrimary,
          surface: AppColors.surfaceDim,
        ),
      ),
      home: DashboardScreen(timerService: _timerService),
    );
  }
}
