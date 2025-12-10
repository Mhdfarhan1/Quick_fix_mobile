import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class VerifyResetOtpPage extends StatefulWidget {
  final String email;
  const VerifyResetOtpPage({super.key, required this.email});

  @override
  State<VerifyResetOtpPage> createState() => _VerifyResetOtpPageState();
}

class _VerifyResetOtpPageState extends State<VerifyResetOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;

  // State untuk validasi
  bool _otpError = false;
  bool _passwordError = false;
  bool _confirmError = false;

  @override
  void initState() {
    super.initState();

    // Real-time validation: hapus error saat user mengetik
    _otpController.addListener(() {
      if (_otpError && _otpController.text.isNotEmpty) {
        setState(() => _otpError = false);
      }
    });

    _passwordController.addListener(() {
      if (_passwordError && _passwordController.text.isNotEmpty) {
        setState(() => _passwordError = false);
      }
      if (_confirmError && _passwordController.text == _confirmController.text) {
        setState(() => _confirmError = false);
      }
    });

    _confirmController.addListener(() {
      if (_confirmError && _passwordController.text == _confirmController.text) {
        setState(() => _confirmError = false);
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    setState(() {
      // Reset error
      _otpError = otp.isEmpty;
      _passwordError = password.isEmpty;
      _confirmError = confirm.isEmpty || password != confirm;
    });

    if (_otpError || _passwordError || _confirmError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periksa kembali input Anda!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.post(
      endpoint: '/password/verify-otp',
      data: {
        'email': widget.email,
        'otp': otp,
        'password': password,
      },
    );

    setState(() => _isLoading = false);

    if (result['statusCode'] == 200 || result['statusCode'] == 201) {
      final data = result['data'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Password berhasil direset!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      final data = result['data'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'OTP atau Kata sandi salah.'),
          backgroundColor: Colors.red,
        ),
      );

      // Hanya field yang bermasalah
      setState(() {
        if (data['field'] == 'otp') _otpError = true;
        if (data['field'] == 'password') _passwordError = true;
      });
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon, bool error) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: error ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: error ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: error
            ? const BorderSide(color: Colors.red, width: 2)
            : const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Kata Sandi'),
        backgroundColor: const Color(0xFF0C4481),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Masukkan kode OTP yang dikirim ke email ${widget.email}:',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Kode OTP', Icons.lock_outline, _otpError),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration('Kata sandi Baru', Icons.password, _passwordError),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: _inputDecoration('Konfirmasi kata sandi', Icons.password_outlined, _confirmError),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                      'RESET KATA SANDI',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
