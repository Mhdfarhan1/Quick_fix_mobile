import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';
import '../../screens/pengguna/home/home_page.dart';
import '../../screens/teknisi/home/Home_page_teknisi.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _textController;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Animasi text (fade in setelah logo muncul)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // Jalankan animasi berurutan
    _logoController.forward().then((_) {
      _textController.forward();
    });

    // Cek login status setelah 5 detik
    Timer(const Duration(seconds: 5), _checkLoginStatus);
  }

  /// 🔍 Cek apakah user sudah login & arahkan sesuai role
  Future<void> _checkLoginStatus() async {

    final token = await ApiService.storage.read(key: 'token');   // ✔ baca token yg benar

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');         // user tetap dari SharedPrefs

    print("[SPLASH] Mulai cek login");
    print("[SPLASH] Token dari SecureStorage: $token");
    print("[SPLASH] UserJson dari SharedPrefs: $userJson");
    


    if (token != null && token.trim().isNotEmpty && userJson != null) {
      try {
        final user = jsonDecode(userJson);
        final role = user['role']?.toString().toLowerCase();

        if (role == 'teknisi') {
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
      } catch (e) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        print("[SPLASH] ERROR decode user: $e");

      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C4481),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo dengan animasi fade + scale
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/Logo_quickfix.png',
                  width: 110,
                ),
              ),
            ),

            const SizedBox(width: 1),

            // Judul dengan shimmer + fade
            FadeTransition(
              opacity: _textFadeAnimation,
              child: Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Colors.yellowAccent,
                child: const Text(
                  "QuickFix",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
