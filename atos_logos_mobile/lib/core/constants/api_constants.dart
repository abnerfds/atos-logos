import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  /// Your machine's local network IP (for physical device testing).
  /// Update this if your IP changes.
  static const _localNetworkIp = '192.168.1.9';

  /// Base URL for the API.
  /// - Web/Desktop: localhost
  /// - Android/iOS physical device: local network IP
  /// - Android emulator: 10.0.2.2 (maps to host localhost)
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid || Platform.isIOS) {
      // Use 10.0.2.2 for Android emulator, or your local IP for physical device
      return 'http://192.168.1.9:3000';
    }
    return 'http://localhost:3000';
  }

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
}
