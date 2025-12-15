import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../config/base_url.dart';

class AuthProvider extends ChangeNotifier {
  int? userId;
  String? token;
  Map<String, dynamic>? userData;
  String? userRole;

  final storage = const FlutterSecureStorage();

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    token = await storage.read(key: "token");
    userId = prefs.getInt("id_user");
    userRole = prefs.getString("role");

    final userString = prefs.getString("user");
    if (userString != null) {
      userData = jsonDecode(userString);
    }

    print("AUTH LOADED — role: $userRole | userId: $userId");

    notifyListeners();
  }

  Future<void> refreshUser() async {
    final res = await ApiService.get('/user');  // endpoint get user login
    if (res['status'] == true) {
      setUser(res['data']);
    }
  }

  Future<void> fetchUser() async {
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.api}/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        userData = data['data'] ?? data;

        notifyListeners(); // 🔥 PENTING
      }
    } catch (e) {
      debugPrint('❌ fetchUser error: $e');
    }
  }



  void setUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();

    userId = user["id_user"];
    userRole = user["role"];
    userData = user;

    await prefs.setInt("id_user", userId!);
    await prefs.setString("role", userRole!);
    await prefs.setString("user", jsonEncode(user));

    notifyListeners();
  }

}

