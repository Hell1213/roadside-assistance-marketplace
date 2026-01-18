import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }
}
