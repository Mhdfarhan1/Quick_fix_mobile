import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../splash/auth_gate.dart';
import 'package:flutter/services.dart';
import 'dart:math';


class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {

  String otpValue = "";

  // ===== Countdown Timer =====
  int timer = 30;
  bool isResending = false;
  Timer? countdown;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    startTimer();

    // ====================================================
    // 🔥 SHAKE ANIMATION (lebih smooth & realistis)
    // ====================================================
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    countdown?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  // ====================================================
  // 🔥 Countdown
  // ====================================================
  void startTimer() {
    timer = 30;
    countdown?.cancel();

    countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timer == 0) {
        t.cancel();
      } else {
        setState(() => timer--);
      }
    });
  }

  // ====================================================
  // 🔥 Modal Loading
  // ====================================================
  void showLoadingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black45,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text("Memproses...", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================
  // 🔥 Verifikasi OTP
  // ====================================================
  Future<void> _verifyOtp() async {
    if (otpValue.length != 6) return;

    showLoadingModal();

    try {
      final api = await ApiService.verifyOtp(
        email: widget.email,
        otp: otpValue,
      );

      Navigator.pop(context);

      final status = api['statusCode'];
      final body = api['data'];

      if (status == 200 && body['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final user = body['user'];

        await prefs.setString('token', body['token']);
        await prefs.setString('user', jsonEncode(user));
        await prefs.setInt('id_user', user['id_user']);
        await prefs.setString('nama', user['nama'] ?? '');
        await prefs.setString('email', user['email'] ?? '');
        await prefs.setString('role', user['role'] ?? '');
        await prefs.setString('no_hp', user['no_hp'] ?? '');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP berhasil diverifikasi!"),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthGate()),
          );
        });

      } else {
        _shakeController.forward(from: 0);
        HapticFeedback.mediumImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message'] ?? "OTP salah."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kesalahan koneksi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ====================================================
  // 🔥 Resend OTP
  // ====================================================
  Future<void> resendOtp() async {
    setState(() => isResending = true);

    final api = await ApiService.resendOtp(email: widget.email);

    setState(() => isResending = false);

    final status = api['statusCode'];
    final data = api['data'];

    if (status == 200 && data['status'] == true) {
      startTimer(); // reset timer
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP baru telah dikirim!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? "Gagal mengirim OTP."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ====================================================
  // 🔥 UI
  // ====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A3A7A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),

            SizedBox(
              width: 260,
              child: Image.asset("assets/images/Logo_quickfix.png"),
            ),

            const SizedBox(height: 20),

            const Text(
              "QUICKFIX",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // ================= SHAKE EFFECT =====================
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final offset = sin(_shakeController.value * pi * 10) * 12;

                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  cursorColor: Colors.black,
                  autoFocus: true,

                  onCompleted: (value) {
                    otpValue = value;
                    _verifyOtp();
                  },

                  onChanged: (value) => otpValue = value,

                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 50,
                    fieldWidth: 45,
                    inactiveColor: Colors.grey.shade300,
                    activeColor: Colors.grey.shade600,
                    selectedColor: Colors.blue,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ====== Resend Button ======
            Center(
              child: timer > 0
                  ? Text(
                      "Kirim ulang dalam $timer detik",
                      style: TextStyle(color: Colors.grey[300]),
                    )
                  : TextButton(
                      onPressed: isResending ? null : resendOtp,
                      child: isResending
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Text(
                              "Kirim ulang OTP",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 220,
              height: 45,
              child: ElevatedButton(
                onPressed: otpValue.length == 6 ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC727),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Verifikasi",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
