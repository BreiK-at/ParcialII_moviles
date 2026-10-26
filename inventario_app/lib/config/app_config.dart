import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl {
    if (dotenv.isInitialized) {
      return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';
    }
    return 'http://10.0.2.2:3000/api';
  }

  static const int connectionTimeout = 10000;
  static const int receiveTimeout = 10000;
}
