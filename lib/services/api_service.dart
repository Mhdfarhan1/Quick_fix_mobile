import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/base_url.dart';
import '../utils/ui_helper.dart';

class ApiService {
  static void log(String message) {
    // ignore: avoid_print
    print('[ApiService] $message');
  }
  // ─────────────── LOGIN ───────────────
  // ─────────────── LOGIN ───────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    final url = Uri.parse('${BaseUrl.api}/auth/login');
    OverlayEntry? loader;
    if (context != null) loader = UIHelper.showLoading(context, text: 'Login...');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        final prefs = await SharedPreferences.getInstance();

        // 🟢 Simpan token
        await prefs.setString('token', data['token']);


        // 🟢 Simpan user info lengkap
        if (data['user'] != null) {
          final user = data['user'];
          await prefs.setInt('id_user', user['id_user']);
          await prefs.setString('nama', user['nama'] ?? '');
          await prefs.setString('email', user['email'] ?? '');
          await prefs.setString('role', user['role'] ?? '');
          await prefs.setString('no_hp', user['no_hp'] ?? '');

          // optional: alamat default
          if (user['alamat_default'] != null) {
            await prefs.setString('alamat_default', user['alamat_default']);
          }
          if (user['id_alamat_default'] != null) {
            await prefs.setInt('id_alamat_default', user['id_alamat_default']);
          }

          log('✅ Login berhasil. Role disimpan: ${user['role']} | ID: ${user['id_user']}');
        }
      } else {
        log('⚠️ Login gagal: ${data['message']}');
      }

      return {'statusCode': response.statusCode, 'data': data};
    } catch (e) {
      log('❌ Error login: $e');
      return {'statusCode': 500, 'data': {'status': false, 'message': 'Error: $e'}};
    } finally {
      loader?.remove();
    }
  }

  // ─────────────── POST GENERIK ───────────────
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> data,
    BuildContext? context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    OverlayEntry? loader;
    if (context != null) loader = UIHelper.showLoading(context);

    final url = Uri.parse('${BaseUrl.api}$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      return {'statusCode': response.statusCode, 'data': jsonDecode(response.body)};
    } catch (e) {
      return {'statusCode': 500, 'data': {'status': false, 'message': 'Error: $e'}};
    } finally {
      loader?.remove();
    }
  }

  // ─────────────── REGISTER ───────────────
  // ─────────────── REGISTER (OTP REQUEST) ───────────────
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String role,
    String? noHp,
    BuildContext? context,
  }) async {
    final url = Uri.parse('${BaseUrl.api}/auth/register-request');

    print("===== REGISTER REQUEST (OTP) =====");
    print("URL: $url");
    print("Body:");
    print({
      'nama': nama,
      'email': email,
      'password': password,
      'role': role,
      'no_hp': noHp ?? '',
    });
    print("==================================");

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'password': password,
          'role': role,
          'no_hp': noHp ?? '',
        }),
      );

      print("===== REGISTER RESPONSE (OTP) =====");
      print("Status Code: ${response.statusCode}");
      print("Raw Body: ${response.body}");
      print("==================================");

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print("❌ JSON ERROR: $e");
        print("❌ BODY: ${response.body}");
      }

      return {'statusCode': response.statusCode, 'data': data};
    } catch (e) {
      print("❌ REGISTER ERROR BESAR: $e");
      return {
        'statusCode': 500,
        'data': {'status': false, 'message': 'Error: $e'}
      };
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

      print("STATUS CODE: ${res.statusCode}");
      print("RESPONSE BODY: ${res.body}");
      print("FULL URL: ${BaseUrl.api}/auth/verify-otp");



      // CEK kalau bukan JSON
      if (!res.headers['content-type']!.contains('application/json')) {
        return {
          'statusCode': res.statusCode,
          'data': {
            'status': false,
            'message': 'Server tidak mengirim JSON. HTML dikembalikan.',
            'raw': res.body,
          }
        };
      }

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
      final response = await http.post(
        url,
        body: {"email": email},
      );

      return {
        "statusCode": response.statusCode,
        "data": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "data": {"status": false, "message": "Gagal terhubung ke server: $e"},
      };
    }
  } 


  // ─────────────── AMBIL BUKTI PEKERJAAN BERDASARKAN ID TEKNISI ───────────────
  static Future<List<dynamic>> getBuktiByTeknisi(int idTeknisi) async {
    final url = Uri.parse('${BaseUrl.api}/bukti/$idTeknisi');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat bukti pekerjaan');
    }
  }

  // ─────────────── GET DETAIL PEMESANAN ───────────────
    static Future<Map<String, dynamic>> getDetailPemesanan(String kode) async {
      final url = Uri.parse('${BaseUrl.api}/get_pemesanan_by_kode/$kode');

      try {
        final response = await http.get(url);

        return {
          'statusCode': response.statusCode,
          'data': jsonDecode(response.body),
        };
      } catch (e) {
        return {
          'statusCode': 500,
          'data': {
            'status': false,
            'message': 'Error: $e',
          },
        };
      }
    }
    // ─────────────── GET PEMESANAN BERDASARKAN USER ───────────────
  static Future<List<dynamic>> getPesanan({
    required int idUser,
    required String role,
  }) async {
    log('📦 [fetchPesanan] Mulai memuat data pesanan...');
    final url = Uri.parse('${BaseUrl.api}/get_pemesanan?${role == "pelanggan" ? "id_pelanggan" : "id_teknisi"}=$idUser');
    log('🌐 [fetchPesanan] Memanggil API: $url');

    try {
      final response = await http.get(url);
      log('📥 [fetchPesanan] Status code: ${response.statusCode}');
      log('🧩 [fetchPesanan] Response: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['data'] is List) {
          log('✅ [fetchPesanan] Ditemukan ${decoded['data'].length} data pesanan.');
          return decoded['data'];
        } else {
          log('⚠️ [fetchPesanan] Struktur respons tidak sesuai: $decoded');
        }
      }
      return [];
    } catch (e) {
      log('❌ [fetchPesanan] Error: $e');
      return [];
    }
  }

  // ─────────────── GET GALERI TEKNISI (REKOMENDASI RANDOM) ───────────────
  static Future<List<dynamic>> getGaleriTeknisi() async {
    log('Memuat galeri teknisi...');
    final url = Uri.parse('${BaseUrl.api}/get_teknisi_rekomendasi');

    try {
      final response = await http.get(url);
      log('Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      log('Error getGaleriTeknisi: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> acceptOrder({
    required int idPemesanan,
    BuildContext? context,
  }) async {
    // endpoint tanpa base karena post() menambahkan BaseUrl.api
    final endpoint = '/pemesanan/$idPemesanan/terima';
    // kirim body kosong (atau bisa dikirim alasan/metadata)
    return await post(endpoint: endpoint, data: {}, context: context);
  }
}
