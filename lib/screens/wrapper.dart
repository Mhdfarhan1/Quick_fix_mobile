import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/pengguna/home/home_page.dart';
import '../screens/teknisi/home/Home_page_teknisi.dart';
import '../screens/auth/login_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _isLoading = true;
  Widget? _nextPage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userJson = prefs.getString('user');

    if (token != null && userJson != null) {
      final user = jsonDecode(userJson);
      final role = user['role']?.toString().toLowerCase();

      if (role == 'teknisi') {
        _nextPage = const HomeTeknisiPage();
      } else {
        _nextPage = const HomePage();
      }
    } else {
      _nextPage = const LoginScreen();
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return _nextPage!;
    }
  }
}
