// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp diubah dari const agar bisa menampung ThemeData
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // TAMBAHKAN BAGIAN INI UNTUK MENERAPKAN FONT
      theme: ThemeData(
        // Atur font default aplikasi menjadi 'Lato'
        fontFamily: 'Lato',

        // (Opsional) Anda juga bisa mengatur warna tema utama di sini
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Warna latar belakang seperti di homepage
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //---------------------------------------------

      home: const SplashScreen(), // <-- Halaman utama tetap SplashScreen
    );
  }
}