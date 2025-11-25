import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/base_url.dart';
import '../utils/ui_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static void log(String message) {
    print('[ApiService] $message');
  }

  // Reusable secure storage instance
  static final FlutterSecureStorage storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );



  // -----------------------
  // Helpers
  // -----------------------
  static Future<String?> _getToken() async {
    try {
      
      final token = await storage.read(key: 'token');
      print("[API] Membaca token dari SecureStorage...");
      print("[API] TOKEN TERBACA: $token");
      return token;
    } catch (e) {
      log("Gagal baca token: $e");
      return null;
    }
  }

  static Future<Map<String, String>> _buildHeaders({
    bool json = true,
    bool includeAuthIfExists = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (json) headers['Content-Type'] = 'application/json';
    if (includeAuthIfExists) {
      final token = await _getToken();
      print("[API] Token di header: $token");

      print("DEBUG TOKEN HEADER: $token");    // <–– Tambahkan baris ini

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static dynamic _safeDecode(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      // jika bukan JSON, kembalikan string mentah
      return body;
    }
  }

  // Generic request helper (ke semua method agar konsisten)
  static Future<Map<String, dynamic>> _request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    BuildContext? context,
    bool jsonBody = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final url = Uri.parse('${BaseUrl.api}$endpoint');
    OverlayEntry? loader;
    if (context != null) loader = UIHelper.showLoading(context);

    try {
      final headers = await _buildHeaders(json: jsonBody, includeAuthIfExists: true);
      http.Response res;

      log('$method $url');
      log('Headers: $headers');
      if (body != null) log('Body: $body');

      if (method == 'GET') {
        res = await http.get(url, headers: headers).timeout(timeout);
      } else if (method == 'POST') {
        final encoded = jsonBody ? jsonEncode(body ?? {}) : (body?['raw'] ?? '');
        res = await http.post(url, headers: headers, body: encoded).timeout(timeout);
      } else if (method == 'PUT') {
        final encoded = jsonBody ? jsonEncode(body ?? {}) : (body?['raw'] ?? '');
        res = await http.put(url, headers: headers, body: encoded).timeout(timeout);
      } else if (method == 'DELETE') {
        res = await http.delete(url, headers: headers).timeout(timeout);
      } else {
        throw UnsupportedError('HTTP method $method not supported');
      }

      final parsed = _safeDecode(res.body);
      log('Response ${res.statusCode}: ${res.body}');

      return {
        'statusCode': res.statusCode,
        'data': parsed,
      };
    } catch (e) {
      log('Request error: $e');
      return {
        'statusCode': 500,
        'data': {'status': false, 'message': 'Error: $e'},
      };
    } finally {
      loader?.remove();
    }
  }

  // -----------------------
  // Public methods (preserve original signatures)
  // -----------------------

  // LOGIN (keaslian behavior dipertahankan: simpan token & user seperti sebelumnya)
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    final url = Uri.parse('${BaseUrl.api}/auth/login');
    final prefs = await SharedPreferences.getInstance();
    

    OverlayEntry? loader;
    if (context != null) loader = UIHelper.showLoading(context, text: 'Login...');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = _safeDecode(response.body);

      if (response.statusCode == 200 && data is Map && data['status'] == true) {
        // simpan token
        final token = data['token'] as String?;
        if (token != null) {
          await storage.write(key: 'token', value: token);
          log("[LOGIN] Token diterima dari server: $token");
          log("[LOGIN] Menyimpan token ke SecureStorage...");
        }

        // simpan user ke shared prefs (seperti sebelumnya)
        if (data['user'] != null) {
          final user = data['user'];
          await prefs.setString('user', jsonEncode(user));
          
          if (user['id_user'] != null) {
            await prefs.setInt('id_user', user['id_user']);
          }

          if (user['role'] != null) {
            await prefs.setString('role', user['role'].toString().toLowerCase());
          }
          log("User disimpan: $user");
        }

        
        
        

        log('✅ Login berhasil. Role: ${data['user']?['role']} | ID: ${data['user']?['id_user']}');
      } else {
        log('⚠️ Login gagal: ${data is Map ? data['message'] : data}');
      }

      return {
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      log('❌ Error login: $e');
      return {
        'statusCode': 500,
        'data': {'status': false, 'message': 'Error: $e'},
      };
    } finally {
      loader?.remove();
    }
  }

  // Generic GET wrapper (preserve function name get)
  static Future<Map<String, dynamic>> get(String endpoint) async {
    return await _request(method: 'GET', endpoint: endpoint);
  }

  // POST generik (preserve signature)
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> data,
    BuildContext? context,
  }) async {
    return await _request(method: 'POST', endpoint: endpoint, body: data, context: context);
  }

  // -----------------------
  // Register / Verify / Resend (preserve behavior)
  // -----------------------
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String role,
    String? noHp,
    BuildContext? context,
  }) async {
    final url = Uri.parse('${BaseUrl.api}/auth/register-request');

    OverlayEntry? loader;
    if (context != null) loader = UIHelper.showLoading(context);

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

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body);
      } catch (_) {}

      return {'statusCode': response.statusCode, 'data': data};
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'status': false, 'message': 'Error: $e'},
      };
    } finally {
      loader?.remove();
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('${BaseUrl.api}/auth/verify-otp');

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      return {
        'statusCode': res.statusCode,
        'data': jsonDecode(res.body),
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'message': 'Kesalahan koneksi: $e'},
      };
    }
  }

  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    final url = Uri.parse('${BaseUrl.api}/auth/resend-otp');

    try {
      final res = await http.post(url, body: {'email': email});
      return {'statusCode': res.statusCode, 'data': jsonDecode(res.body)};
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'message': 'Error: $e'},
      };
    }
  }

  // -----------------------
  // Specific endpoints (ke semua GET pakai wrapper sehingga Authorization dikirim)
  // -----------------------

  static Future<List<dynamic>> getBuktiByTeknisi(int idTeknisi) async {
    final res = await get('/bukti/$idTeknisi');
    if (res['statusCode'] == 200 && res['data'] is List) {
      return res['data'] as List<dynamic>;
    } else if (res['statusCode'] == 200 && res['data'] is Map && res['data']['data'] is List) {
      return res['data']['data'] as List<dynamic>;
    } else {
      throw 'Gagal memuat bukti pekerjaan';
    }
  }

  static Future<Map<String, dynamic>> getDetailPemesanan(String kode) async {
    final res = await get('/get_pemesanan_by_kode/$kode');
    if (res['data'] == null) {
      return {'statusCode': res['statusCode'], 'data': {}};
    }
    return res;
  }

  static Future<List<dynamic>> getPesanan({
    required int idUser,
    required String role,
  }) async {
    log('📦 Load pesanan...');
    final param = role == "pelanggan" ? "id_pelanggan" : "id_teknisi";
    final res = await get('/get_pemesanan?$param=$idUser');

    if (res['statusCode'] == 200) {
      final data = res['data'];
      if (data is Map && data['data'] is List) return data['data'] as List<dynamic>;
      if (data is List) return data;
    }
    return [];
  }

  static Future<List<dynamic>> getGaleriTeknisi() async {
    final res = await get('/get_teknisi_rekomendasi');
    if (res['statusCode'] == 200 && res['data'] is List) {
      return res['data'] as List<dynamic>;
    }
    return [];
  }

  static Future<Map<String, dynamic>> acceptOrder({
    required int idPemesanan,
    BuildContext? context,
  }) async {
    return await post(
      endpoint: '/pemesanan/$idPemesanan/terima',
      data: {},
      context: context,
    );
  }

  // Logout helper (tidak menghapus data lain — hanya token & user prefs seperti biasa)
  static Future<void> logout() async {
    try {
      await storage.delete(key: 'token');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('id_user');
      log('User logged out, token and prefs removed.');
    } catch (e) {
      log('Logout error: $e');
    }
  }
}
