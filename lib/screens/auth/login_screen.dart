import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'signup_screen.dart';
import '../auth/reset_password_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../teknisi/home/Home_page_teknisi.dart';
import '../pengguna/home/home_page.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan Password tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(email: email, password: password);

      print('Response dari API Laravel: ${result['data']}');
      print('Status code: ${result['statusCode']}');

      if (result['statusCode'] == 200) {
        final data = result['data'];

        if (data['status'] == true) {
          final token = data['token'];
          final user = data['user'];

          print("From server user data: $user");
          print("Correct id_user: ${user['id_user']}");

          // 🔐 SIMPAN TOKEN DI SECURE STORAGE
          await ApiService.storage.write(key: "token", value: token);
          await Future.delayed(const Duration(milliseconds: 200));

          // panggil AuthProvider agar state global update
          final auth = Provider.of<AuthProvider>(context, listen: false);
          auth.setUser(user);



          print("TOKEN DISIMPAN DI SECURE STORAGE: $token");

          // ⭐ SIMPAN DATA USER DI SHARED PREFS
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(user));
          await prefs.setInt('id_user', user['id_user']);
          await prefs.setString('role', user['role'].toString().toLowerCase()); // <-- WAJIB


          

          // 🎯 ARAHKAN KE HALAMAN SESUAI ROLE
          final role = user['role'].toString().toLowerCase();


          if (!mounted) return;

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


          // Pastikan alamat_default benar
          final alamatDefault = user['alamat_default'];
          final idAlamatDefault = user['id_alamat_default'];

          if (alamatDefault != null && alamatDefault.toString().isNotEmpty) {
            await prefs.setString('alamat_default', alamatDefault.toString());

            if (idAlamatDefault != null) {
              await prefs.setInt(
                'id_alamat_default',
                idAlamatDefault is int ? idAlamatDefault : int.tryParse(idAlamatDefault.toString()) ?? 0,
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Login gagal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (result['statusCode'] == 423) {
      // 🔒 Saat Laravel mengembalikan error "Locked"
      final data = result['data'];
      final message = data['message'] ?? 'Akun dikunci sementara';
      final lockedUntil = data['locked_until'];

      // ✅ Tampilkan dialog ke user
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Akun Dikunci',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            lockedUntil != null
                ? '$message\n\nBuka kembali: $lockedUntil'
                : message,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    else if (result['statusCode'] == 401 || result['statusCode'] == 403) {
      // Salah email/password biasa
      final data = result['data'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Email atau password salah'),
          backgroundColor: Colors.red,
        ),
      );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan, coba lagi nanti'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenSize.height,
          child: Stack(
            children: [
              // Background biru
              Container(
                height: screenSize.height * 0.4,
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFF0C4481)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/Logo_quickfix.png', height: 180),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
              // Form putih
              Positioned(
                top: screenSize.height * 0.3,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                  constraints: BoxConstraints(
                      minHeight: screenSize.height * 0.9, // full ke bawah
                    ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _passwordController,
                        hintText: 'Sandi',
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                            );
                          },
                          child: const Text('Lupa Sandi?'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                                'Masuk',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Belum punya akun?"),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignUpScreen()),
                              );
                            },
                            child: const Text(
                              'DAFTAR',
                              style: TextStyle(
                                color: Color(0xFF0C4481),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required Color color}) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.grey[200],
      child: FaIcon(icon, color: color),
    );
  }
}
