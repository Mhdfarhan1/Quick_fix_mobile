import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'login_screen.dart';
import 'otp_screen.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '####-####-####',
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _phoneError;

  String _selectedRole = 'pelanggan';
  final List<String> _roles = ['pelanggan', 'teknisi'];

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();

    setState(() {
      _emailError = null;
      _usernameError = null;
      _passwordError = null;
      _phoneError = null;
    });

    bool isValid = true;

    if (email.isEmpty) {
      setState(() => _emailError = 'Email wajib diisi');
      isValid = false;
    }
    if (username.isEmpty) {
      setState(() => _usernameError = 'Username wajib diisi');
      isValid = false;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Kata sandi wajib diisi');
      isValid = false;
    }
    if (phone.isEmpty) {
      setState(() => _phoneError = 'Nomor HP wajib diisi');
      isValid = false;
    } else if (_phoneFormatter.getUnmaskedText().length != 12) {
      // Validasi panjang input angka saja
      setState(() => _phoneError = 'Nomor HP harus 12 digit');
      isValid = false;
    }

    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.register(
        nama: username,
        email: email,
        password: password,
        role: _selectedRole,
        noHp: phone,
      );

      final statusCode = response['statusCode'];
      final data = response['data'] ?? {};

      if (statusCode == 200 || statusCode == 201) {
        final status = data['status'] ?? false;
        final serverEmail = data['email'];

        if (status != true) {
          final msg = data['message'] ?? 'Registrasi gagal.';
          _showSnackBar(msg, Colors.red);
          return;
        }

        final emailResponse = (serverEmail is String && serverEmail.isNotEmpty)
            ? serverEmail
            : email;

        _showSnackBar('Registrasi berhasil! OTP telah dikirim.', Colors.green);

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(email: emailResponse),
            ),
          );
        });
      } else if (statusCode == 422 && data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        
        setState(() {
          if (errors['email'] != null) _emailError = errors['email'][0];
          if (errors['nama'] != null) _usernameError = errors['nama'][0];
          if (errors['password'] != null) _passwordError = errors['password'][0];
          if (errors['no_hp'] != null) _phoneError = errors['no_hp'][0];
        });

        _showSnackBar('Harap perbaiki data yang salah.', Colors.red);
      } else {
        final message = data['message'] ?? 'Terjadi kesalahan server.';
        _showSnackBar(message, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan koneksi: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 14)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
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
              Container(
                height: screenSize.height * 0.4,
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFF0C4481)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/Logo_quickfix.png', height: 120),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
              Positioned(
                top: screenSize.height * 0.3,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: screenSize.height * 0.9,
                  ),
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
                      _buildTextField(
                        icon: Icons.email_outlined,
                        hintText: 'Email',
                        controller: _emailController,
                        errorText: _emailError,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        icon: Icons.person_outline,
                        hintText: 'Username',
                        controller: _usernameController,
                        errorText: _usernameError,
                      ),
                      const SizedBox(height: 16),

                      _buildRoleDropdown(),
                      const SizedBox(height: 16),

                      _buildPasswordField(
                        hintText: 'Kata Sandi',
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        onToggleVisibility: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        errorText: _passwordError,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        icon: Icons.phone_android,
                        hintText: 'Nomor HP',
                        controller: _phoneController,
                        errorText: _phoneError,
                        inputFormatters: [
                          _phoneFormatter,
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text('DAFTAR',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Sudah punya akun? ",
                            style: TextStyle(fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Masuk",
                              style: TextStyle(
                                fontSize: 14,
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

  Widget _buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FCFD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _selectedRole,
        isExpanded: true,
        underline: const SizedBox(),
        items: _roles.map((role) {
          return DropdownMenuItem(
            value: role,
            child: Text(role[0].toUpperCase() + role.substring(1)),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedRole = value!),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hintText,
        errorText: errorText,
        filled: true,
        fillColor: const Color(0xFFF4FCFD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF20C9E2)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEA0C0C)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEA0C0C)),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required TextEditingController controller,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        hintText: hintText,
        errorText: errorText,
        filled: true,
        fillColor: const Color(0xFFF4FCFD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF20C9E2)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEA0C0C)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEA0C0C)),
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
}
