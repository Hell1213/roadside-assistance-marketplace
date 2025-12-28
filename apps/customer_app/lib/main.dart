import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'screens/auth/phone_input_screen.dart';

void main() {
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roadside Assistance - Customer',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const PhoneInputScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}