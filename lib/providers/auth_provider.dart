import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

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

