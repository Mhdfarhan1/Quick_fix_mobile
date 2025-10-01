// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'signup_screen.dart'; // Import untuk navigasi kembali ke Sign Up

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenSize.height,
          child: Stack(
            children: [
              // Latar belakang biru
              Container(
                height: screenSize.height * 0.4,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF0C4481), // Warna biru yang lebih gelap
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Logo_quickfix.png',
                      height: 180,
                    ),
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
                      _buildTextField(icon: Icons.person_outline, hintText: 'Username'),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 24),
                      const Center(child: Text('Or Login Using', style: TextStyle(color: Colors.grey))),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(icon: FontAwesomeIcons.google, color: Colors.red),
                          const SizedBox(width: 20),
                          _buildSocialButton(icon: FontAwesomeIcons.facebook, color: Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              // Navigasi ke halaman Sign Up
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUpScreen()),
                              );
                            },
                            child: const Text('SIGN UP', style: TextStyle(color: Color(0xFF0C4481), fontWeight: FontWeight.bold)),
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

  // Helper widget yang sama bisa kita gunakan di sini
  Widget _buildTextField({required IconData icon, required String hintText}) {
    return TextField(
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

  Widget _buildPasswordField() {
    return TextField(
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        hintText: 'Password',
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
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