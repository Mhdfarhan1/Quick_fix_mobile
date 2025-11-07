import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/splash/auth_gate.dart'; // pastikan path ini sesuai

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lato',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // Gunakan logika atau widget khusus untuk menentukan halaman awal
      home: const SplashScreenWrapper(),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Contoh: tunggu splash 2 detik dan cek status login
    await Future.delayed(const Duration(seconds: 2));

    // Misal cek dari SharedPreferences (ini dummy)
    setState(() {
      _isLoggedIn = false; // ubah ke true kalau user sudah login
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    } else {
      return _isLoggedIn ? const AuthGate() : const SplashScreen();
    }
  }
}
