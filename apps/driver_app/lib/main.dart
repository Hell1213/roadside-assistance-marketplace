import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'screens/dashboard/driver_dashboard_screen.dart';

void main() {
  runApp(const DriverApp());
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roadside Assistance - Driver',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const DriverDashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}