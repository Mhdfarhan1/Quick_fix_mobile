import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class BaseUrl {
  static String get server {
    // Flutter Web
    if (kIsWeb) {
      return "http://localhost:8000";
    }

    // Android Emulator
    

    // iOS Simulator
    if (Platform.isIOS) {
      return "http://127.0.0.1:8000";
    }

    // Jika kamu pakai device fisik (bisa ubah IP ini)
    return "http://10.158.125.178:8000/api"; // Ganti IP dengan IP PC kamu
  }
}
