// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json', // wajib agar Laravel kembalikan JSON
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // parse response body
      final data = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'status': false, 'message': 'Terjadi kesalahan: $e'},
      };
    }
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json', // wajib agar Laravel kembalikan JSON
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'status': false, 'message': 'Terjadi kesalahan: $e'},
      };
    }
  }
}
