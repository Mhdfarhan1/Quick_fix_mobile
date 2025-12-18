import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/base_url.dart';
import '../utils/ui_helper.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class ApiService {
  

  static final Dio dio = Dio();

  static void setToken(String? token){
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }



  static Future<Map<String, dynamic>> postMultipart(String endpoint, FormData data) async {
    final url = "${BaseUrl.api}/$endpoint";

    try {
      print("URL => $url");

      final response = await dio.post(
        url,
        data: data,
        options: Options(headers: await _buildHeaders(json: false)),
      );

      print("RESPONSE => ${response.data}");

      return {
        'statusCode': response.statusCode,
        'data': response.data,
      };
    } catch(e) {
      print("ERROR => $e");
      rethrow;
    }
  }





  static void log(String message) {
    // ignore: avoid_print
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
  // PUBLIC wrapper (WAJIB ADA)
  static Future<String?> getToken() async {
    return await _getToken();
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
  static Future<Map<String, dynamic>> request({
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
    OverlayEntry? loader;
    if (context != null) loader = UIHelper.showLoading(context, text: 'Login...');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      if (response.statusCode == 200 && data is Map && data['status'] == true) {
        // simpan token
        final token = data['token'] as String?;
        if (token != null) {
          await storage.write(key: 'token', value: token);
          ApiService.setToken(token);  // <── WAJIB TAMBAH
        }

        // simpan user ke shared prefs (seperti sebelumnya)
        if (data['user'] != null) {
          final user = data['user'];
          await prefs.setInt('id_user', user['id_user']);
          await prefs.setString('nama', user['nama'] ?? '');
          await prefs.setString('email', user['email'] ?? '');
          await prefs.setString('role', user['role'] ?? '');
          await prefs.setString('no_hp', user['no_hp'] ?? '');
          await prefs.setString('user', jsonEncode(user));

          if (user['id_teknisi'] != null) {
            await prefs.setInt('id_teknisi', user['id_teknisi']);
            log("✅ ID Teknisi disimpan: ${user['id_teknisi']}");
          } else {
            log("⚠️ User bukan teknisi atau id_teknisi tidak ditemukan!");
          }

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

  // Generic GET wrapper (preserve function name get)
  static Future<Map<String, dynamic>> get(String endpoint) async {
    return await request(method: 'GET', endpoint: endpoint);
  }

  // POST generik (preserve signature)
  // ─────────────── POST GENERIK ───────────────
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> data,
    BuildContext? context,
  }) async {
    return await request(method: 'POST', endpoint: endpoint, body: data, context: context);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_user');
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
  // ---------------------
// NEW: Ambil daftar keahlian
// ---------------------
static Future<Map<String, dynamic>> fetchKeahlian({int? kategoriId}) async {
  final uri = kategoriId == null
      ? Uri.parse('${BaseUrl.api}/keahlian')
      : Uri.parse('${BaseUrl.api}/keahlian?kategori_id=$kategoriId');
  try {
    final response = await http.get(uri, headers: {'Accept': 'application/json'});
    final body = response.body;
    Map<String, dynamic> parsed = {};
    try {
      parsed = jsonDecode(body);
    } catch (e) {
      return {'statusCode': response.statusCode, 'data': {'status': false, 'message': 'Response bukan JSON', 'raw': body}};
    }
    return {'statusCode': response.statusCode, 'data': parsed};
  } catch (e) {
    return {'statusCode': 500, 'data': {'status': false, 'message': 'Gagal koneksi: $e'}};
  }
}

// ---------------------
// Fetch kategori
// ---------------------
static Future<Map<String, dynamic>> fetchKategori() async {
  final url = Uri.parse('${BaseUrl.api}/kategori');
  try {
    final response = await http.get(url, headers: {'Accept': 'application/json'});
    final body = response.body;
    Map<String, dynamic> parsed = {};
    try {
      parsed = jsonDecode(body);
    } catch (e) {
      return {'statusCode': response.statusCode, 'data': {'success': false, 'message': 'Response bukan JSON', 'raw': body}};
    }
    return {'statusCode': response.statusCode, 'data': parsed};
  } catch (e) {
    return {'statusCode': 500, 'data': {'success': false, 'message': 'Gagal koneksi: $e'}};
  }
}

// ---------------------
// NEW: Upload keahlian teknisi (multipart/form-data)
// ---------------------
static Future<Map<String, dynamic>> uploadKeahlianTeknisi({
  int? idKeahlian,
  String? nama,
  int? harga, // ← ganti!
  String? deskripsi,
  File? gambarFile,
  BuildContext? context,
}) async {
  final token = await ApiService._getToken();
  OverlayEntry? loader;
  if (context != null) loader = UIHelper.showLoading(context, text: 'Mengunggah layanan...');

  try {
    final uri = Uri.parse('${BaseUrl.api}/teknisi/keahlian');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (idKeahlian != null) request.fields['id_keahlian'] = idKeahlian.toString();
    if (nama != null) request.fields['nama'] = nama;
    if (harga != null) request.fields['harga'] = harga.toString(); // ← hanya satu harga
    if (deskripsi != null && deskripsi.isNotEmpty) request.fields['deskripsi'] = deskripsi;

    if (gambarFile != null) {
      final mimeType = lookupMimeType(gambarFile.path) ?? 'image/jpeg';
      request.files.add(await http.MultipartFile.fromPath(
        'gambar_layanan', gambarFile.path,
        contentType: MediaType.parse(mimeType),
      ));
    }

    final streamed = await request.send();
    final respStr = await streamed.stream.bytesToString();

    dynamic data;
    try {
      data = jsonDecode(respStr);
    } catch (e) {
      data = {'status': false, 'message': 'Response bukan JSON', 'raw': respStr};
    }

    return {'statusCode': streamed.statusCode, 'data': data};
  } finally {
    loader?.remove();
  }
}


// ---------------------
// Fetch layanan teknisi
// ---------------------
static Future<Map<String, dynamic>> getLayananTeknisi(
  int teknisiId,
  {BuildContext? context}
) async {
  final token = await ApiService._getToken();

  try {
    final url = Uri.parse('${BaseUrl.api}/teknisi/$teknisiId/keahlian');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(response.body);
    } catch (e) {
      return {
        'statusCode': response.statusCode,
        'data': {
          'success': false,
          'message': 'Response bukan JSON',
          'raw': response.body
        }
      };
    }

    return {'statusCode': response.statusCode, 'data': parsed};
  } catch (e) {
    return {'statusCode': 500, 'data': {'success': false, 'message': '$e'}};
  }
}


// ---------------------
// Update layanan teknisi
// ---------------------
static Future<Map<String, dynamic>> updateLayananTeknisi({
  required int id,
  int? idKeahlian,
  String? nama,
  int? harga, // ← ganti!
  String? deskripsi,
  File? gambarFile,
  BuildContext? context,
}) async {
  final token = await ApiService._getToken();
  OverlayEntry? loader;
  if (context != null) loader = UIHelper.showLoading(context, text: 'Memperbarui layanan...');

  try {
    final uri = Uri.parse('${BaseUrl.api}/teknisi/keahlian/$id');
    final request = http.MultipartRequest('POST', uri);
    request.fields['_method'] = 'PUT';

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (idKeahlian != null) request.fields['id_keahlian'] = idKeahlian.toString();
    if (nama != null) request.fields['nama'] = nama;
    if (harga != null) request.fields['harga'] = harga.toString(); // ← satu harga
    if (deskripsi != null && deskripsi.isNotEmpty) request.fields['deskripsi'] = deskripsi;

    if (gambarFile != null) {
      final mimeType = lookupMimeType(gambarFile.path) ?? 'image/jpeg';
      request.files.add(await http.MultipartFile.fromPath(
        'gambar_layanan', gambarFile.path,
        contentType: MediaType.parse(mimeType),
      ));
    }

    final streamed = await request.send();
    final respStr = await streamed.stream.bytesToString();

    dynamic data;
    try {
      data = jsonDecode(respStr);
    } catch (e) {
      data = {'success': false, 'message': 'Response bukan JSON', 'raw': respStr};
    }

    return {'statusCode': streamed.statusCode, 'data': data};
  } finally {
    loader?.remove();
  }
}


// ---------------------
// Delete layanan teknisi
// ---------------------
static Future<Map<String, dynamic>> deleteLayananTeknisi({
  required int id,
  BuildContext? context,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = await ApiService._getToken();


  OverlayEntry? loader;
  if (context != null) loader = UIHelper.showLoading(context, text: 'Menghapus layanan...');

  try {
    final url = Uri.parse('${BaseUrl.api}/teknisi/keahlian/$id');
    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final body = response.body;
    Map<String, dynamic> parsed = {};
    try {
      parsed = jsonDecode(body);
    } catch (e) {
      return {'statusCode': response.statusCode, 'data': {'success': false, 'message': 'Response bukan JSON', 'raw': body}};
    }

    return {'statusCode': response.statusCode, 'data': parsed};
  } catch (e) {
    return {'statusCode': 500, 'data': {'success': false, 'message': 'Error: $e'}};
  } finally {
    loader?.remove();
  }
}


  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = await _getToken(); // ambil token dulu
      final url = "${BaseUrl.api}$endpoint";

      print("API DELETE: $url");

      final res = await Dio().delete(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      print("DELETE STATUS: ${res.statusCode}");
      print("DELETE RESP: ${res.data}");

      return {
        'statusCode': res.statusCode,
        'data': res.data,
      };

    } catch (e) {
      print("❌ DELETE ERROR: $e");
      return {
        'statusCode': null,
        'data': null,
      };
    }
  }

  static Future<Map<String, dynamic>> getNotifications() async {
    return await request(
      method: "GET",
      endpoint: "/notifications",
    );
  }


  static Future<Map<String, dynamic>> markNotifRead(int id) async {
    return await request(
      method: "POST",
      endpoint: "/notifications/$id/read",
      body: {},
    );
  }


  static Future<Map<String, dynamic>> readNotifikasi(int idNotifikasi) async {
    return await request(
      method: 'PUT',
      endpoint: '/notifikasi/$idNotifikasi/read',
      body: {},  // body kosong
    );
  }

  static Future<Map<String, dynamic>> deleteNotifikasi(int idNotifikasi) async {
    return await request(
      method: 'DELETE',
      endpoint: '/notifikasi/$idNotifikasi',
    );
  }

  static Future<Map<String, dynamic>> getUlasanTeknisi(int idTeknisi) async {
    return await ApiService.get('/teknisi/$idTeknisi/ulasan');
  }


  static Future<Map<String, dynamic>> updateProfilTeknisi({
    required String deskripsi,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('${BaseUrl.api}/teknisi/update_profile');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "deskripsi": deskripsi,
      }),
    );

    return {
      "statusCode": response.statusCode,
      "data": jsonDecode(response.body),
    };
  }





  static Future<Map<String, dynamic>> uploadGaleri(File file) async {
    final url = Uri.parse('${BaseUrl.api}/teknisi/upload_galeri');
    final token = await _getToken();

    final request = http.MultipartRequest("POST", url);
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),  // field sesuai Laravel
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    return {
      "statusCode": response.statusCode,
      "data": jsonDecode(responseBody),  // <--- ini data utama
    };
  }



  static Future<Map<String,dynamic>> deleteGaleri(String token, int idGaleri) async {
    final url = Uri.parse('${BaseUrl.api}/teknisi/galeri/$idGaleri');
    final res = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    return {'statusCode': res.statusCode, 'body': res.body.isNotEmpty ? jsonDecode(res.body) : null};
  }

  static Future<Map<String, dynamic>> getGaleri(int teknisiId) async {
    final url = Uri.parse('${BaseUrl.api}/teknisi/$teknisiId/galeri');
    final token = await _getToken();

    final res = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json'
    });

    return {
      "statusCode": res.statusCode,
      "data": jsonDecode(res.body)
    };
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String nama,
    required String email,
    String? noHp,
  }) async {
    final url = Uri.parse('${BaseUrl.api}/user/update');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama': nama,
        'email': email,
        'no_hp': noHp,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'data': body};
    } else if (response.statusCode == 422) {
      // validasi gagal
      return {'success': false, 'status': 422, 'errors': body};
    } else {
      return {
        'success': false,
        'status': response.statusCode,
        'message': body['message'] ?? 'Terjadi kesalahan'
      };
    }
  }

  

}
