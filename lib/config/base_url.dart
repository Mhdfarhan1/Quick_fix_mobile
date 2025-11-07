import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class BaseUrl {
  static String get server {
    // Flutter Web (browser)
    if (kIsWeb) {
      return "http://localhost:8000";
    }

    // Android Emulator (default)
    if (Platform.isAndroid) {
      return "http://192.168.1.2:8000";
    }

    // iOS Simulator
    if (Platform.isIOS) {
      return "http://127.0.0.1:8000";
    }

    // Fallback (device fisik)
    return "http://192.168.1.2:8000"; // ganti IP sesuai PC-mu
  }

  // API endpoint
  static String get api => "$server/api";

  // Storage (gambar)
  static String get storage => "$server/storage";
}
