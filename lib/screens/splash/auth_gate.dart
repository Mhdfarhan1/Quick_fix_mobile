import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../pengguna/home/home_page.dart';
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
    Future.delayed(const Duration(milliseconds: 300), () {
      checkLogin();
    });

  }

  Future<void> checkLogin() async {
    final token = await ApiService.storage.read(key: 'token');


    // Tambah delay agar FlutterSecureStorage siap digunakan
    await Future.delayed(const Duration(milliseconds: 300));

    

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');

    print("[AUTH_GATE] Cek login dipanggil");
    print("[AUTH_GATE] Token terbaca: $token");
    print("[AUTH_GATE] User JSON terbaca: $userJson");
;

    if (!mounted) return;

    if (token != null && token.trim().isNotEmpty && userJson != null) {
      final user = jsonDecode(userJson);
      final role = user['role'].toString().toLowerCase();

      if (role == 'teknisi') {
        print("[AUTH_GATE] Role: $role");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeTeknisiPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
