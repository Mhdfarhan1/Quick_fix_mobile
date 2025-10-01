import 'package:flutter/material.dart';
import 'dart:async';
import '../auth/signup_screen.dart'; //

//--- WIDGET SPLASH SCREEN ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// State class dengan TickerProvider untuk animasi
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Menginisialisasi controller untuk durasi animasi
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Durasi animasi 1.5 detik
    );

    // 2. Membuat animasi membesar (scale)
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // 3. Membuat animasi memudar (fade in)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Memulai animasi
    _controller.forward();

    // 4. Pindah ke halaman utama setelah 3 detik
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignUpScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Membersihkan controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C4481), // Warna latar belakang biru
      body: Center(
        // 5. Menerapkan animasi ke logo
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              'assets/images/Logo_quickfix.png', // Pastikan path dan nama file logo benar
              width: 200,
            ),
          ),
        ),
      ),
    );
  }
}