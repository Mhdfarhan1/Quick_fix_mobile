import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pengguna/home/home_page.dart';
import '../auth/login_screen.dart';
import '../teknisi/home/Home_page_teknisi.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userJson = prefs.getString('user');

    if (token != null && userJson != null) {
      final user = jsonDecode(userJson);
      final role = user['role']?.toString().toLowerCase();

      if (role == 'teknisi') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeTeknisiPage()),
        );
      } else if (role == 'pelanggan') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
