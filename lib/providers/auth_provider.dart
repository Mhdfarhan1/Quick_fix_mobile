import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  int? userId;
  String? token;
  Map<String, dynamic>? userData;
  String? userRole;

  final storage = const FlutterSecureStorage();

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    token = await storage.read(key: "token");   // ← TOKEN AMAN
    userId = prefs.getInt("id_user");           // ← AMAN
    userRole = prefs.getString("role");
    final userString = prefs.getString("user");
    print("   - role dari SharedPreferences: $userRole");
    print("🔥 DEBUG AuthProvider.loadUserData()");

    if (userString != null) {
      userData = jsonDecode(userString);
    }

    print("AUTH LOADED — token: $token | userId: $userId");
    notifyListeners();
  }
}
