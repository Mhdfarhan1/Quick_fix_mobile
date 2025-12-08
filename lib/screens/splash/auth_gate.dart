import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
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

    // delay sedikit supaya AuthProvider selesai load
    Future.delayed(const Duration(milliseconds: 300), () {
      checkLogin();
    });
  }

  Future<void> checkLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    print("=================================");
    print("[AUTH_GATE] Cek login dipanggil");
    print("[AUTH_GATE] Token: ${auth.token}");
    print("[AUTH_GATE] Role (before refresh): ${auth.userRole}");
    print("=================================");

    if (!mounted) return;

    // ❌ Tidak ada token → ke Login
    if (auth.token == null || auth.token!.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // 🔥 Tambahkan ini → memastikan role benar dari server
    await auth.refreshUser();

    // Setelah refresh, ambil role terbaru
    final role = auth.userRole?.toLowerCase();

    print("[AUTH_GATE] Role (after refresh): $role");

    if (role == "teknisi") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeTeknisiPage()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
