import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/home/home_screen.dart';
import 'screens/landing/landing_page.dart';
import 'screens/auth/phone_input_screen.dart';
import 'config/app_config.dart';
import 'services/api/api_client.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize app config
  await AppConfig.initialize();
  
  // Initialize API client
  ApiClient().initialize();
  
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Roadside Assistance - Customer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Wrapper to handle authentication state and routing
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while checking auth status
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If authenticated, show home screen
        if (authProvider.isAuthenticated) {
          return const CustomerHomePage();
        }

        // If not authenticated and on web, show landing page
        // On mobile, show login directly
        if (kIsWeb) {
          return const LandingPage();
        } else {
          return const PhoneInputScreen(role: 'CUSTOMER');
        }
      },
    );
  }
}
