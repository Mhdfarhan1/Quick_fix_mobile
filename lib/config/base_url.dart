import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class BaseUrl {
  // Coba pakai ngrok dulu, kalau offline pakai lokal
  static String get server {
    const ngrokUrl = "https://85342055a81d.ngrok-free.app";
    final localIp = "http://192.168.1.4:8000";

    // Flutter Web
    if (kIsWeb) return "http://localhost:8000";

    // Android Emulator / Device
    if (Platform.isAndroid) return localIp;

    // iOS Simulator / Device
    if (Platform.isIOS) return localIp;

    return localIp; // fallback
  }

  static String get api => "$server/api";
  static String get storage => "$server/storage";
}

