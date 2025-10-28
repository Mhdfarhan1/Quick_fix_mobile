// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  /// LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login'); // ⬅ sesuai dengan route di Laravel

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
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
        'data': {
          'status': false,
          'message': 'Terjadi kesalahan koneksi: $e',
        },
      };
    }
  }

  /// REGISTER
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String role,
    String? noHp,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/register'); // ⬅ disesuaikan juga

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'password': password,
          'role': role,
          'no_hp': noHp ?? '',
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
        'data': {
          'status': false,
          'message': 'Terjadi kesalahan koneksi: $e',
        },
      };
    }
  }
  /// AMBIL BUKTI PEKERJAAN BERDASARKAN ID TEKNISI
  static Future<List<dynamic>> getBuktiByTeknisi(int idTeknisi) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/bukti/$idTeknisi');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat bukti pekerjaan');
    }
  }

}
