// lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // --- VARIABEL STATE ---
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // 1. TAMBAHKAN CONTROLLER UNTUK MENGAMBIL DATA DARI FORM
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // 2. BERSIHKAN CONTROLLER SETELAH TIDAK DIGUNAKAN UNTUK MENCEGAH KEBOCORAN MEMORI
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenSize.height,
          child: Stack(
            children: [
              Container(
                height: screenSize.height * 0.4,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF0C4481),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Logo_quickfix.png', // PERBAIKI: Gunakan nama file yang konsisten (huruf kecil)
                      height: 120,
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
              Positioned(
                top: screenSize.height * 0.3,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
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
                      // 3. HUBUNGKAN SETIAP TEXT FIELD DENGAN CONTROLLER-NYA
                      _buildTextField(
                          icon: Icons.email_outlined,
                          hintText: 'Email',
                          controller: _emailController),
                      const SizedBox(height: 16),
                      _buildTextField(
                          icon: Icons.person_outline,
                          hintText: 'Username',
                          controller: _usernameController),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        hintText: 'Password',
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        hintText: 'Confirm Password',
                        obscureText: _obscureConfirmPassword,
                        controller: _confirmPasswordController,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        // 4. TAMBAHKAN AKSI PADA TOMBOL SIGN UP
                        // --- BLOK BARU (DENGAN AKSI) ---
                        onPressed: () {
                          // 1. Ambil data dari form (sama seperti sebelumnya)
                          final email = _emailController.text;
                          final username = _usernameController.text;
                          final password = _passwordController.text;

                          // Di sini nanti kamu akan menambahkan logika untuk menyimpan data ke database.
                          // Untuk sekarang, kita anggap pendaftaran selalu berhasil.

                          // 2. Tampilkan pesan sukses di bagian bawah layar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pendaftaran Berhasil! Silakan Login.'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // 3. Tunggu sebentar lalu pindah ke halaman Login
                          Future.delayed(const Duration(seconds: 2), () {
                            // pushReplacement digunakan agar pengguna tidak bisa kembali ke halaman Sign Up
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('SIGN UP',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 24),
                      const Center(
                          child: Text('Or Sign Up Using',
                              style: TextStyle(color: Colors.grey))),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                              icon: FontAwesomeIcons.google, color: Colors.red),
                          const SizedBox(width: 20),
                          _buildSocialButton(
                              icon: FontAwesomeIcons.facebook, color: Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have account?'),
                          TextButton(
                            // 5. TAMBAHKAN NAVIGASI KE HALAMAN LOGIN
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text('LOGIN',
                                style: TextStyle(
                                    color: Color(0xFF0C4481),
                                    fontWeight: FontWeight.bold)),
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

  // Helper widget dimodifikasi untuk menerima controller
  Widget _buildTextField(
      {required IconData icon,
        required String hintText,
        required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Helper widget dimodifikasi untuk menerima controller
  Widget _buildPasswordField(
      {required String hintText,
        required bool obscureText,
        required VoidCallback onToggleVisibility,
        required TextEditingController controller}) {
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
          borderSide: BorderSide.none,
        ),
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