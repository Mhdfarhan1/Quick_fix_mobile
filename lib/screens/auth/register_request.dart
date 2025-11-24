// register_request.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<http.Response> registerRequest({
  required String baseUrl,
  required String nama,
  required String email,
  required String password,
  required String role,
  String? noHp,
}) {
  final url = Uri.parse('$baseUrl/api/auth/register-request');
  return http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'nama': nama,
      'email': email,
      'password': password,
      'role': role,
      'no_hp': noHp,
    }),
  );
}

// verify_otp.dart
Future<http.Response> verifyOtp({
  required String baseUrl,
  required String email,
  required String otp,
}) {
  final url = Uri.parse('$baseUrl/api/auth/verify-otp');
  return http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'otp': otp}),
  );
}
