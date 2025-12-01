import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/base_url.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeranjangService {
  Future<List<dynamic>> getKeranjang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idUser = prefs.getInt('id_user');

    final response = await http.get(
      Uri.parse("${BaseUrl.server}/api/keranjang?id_pelanggan=$idUser"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is List ? data : [];
    } else {
      throw Exception('Gagal memuat keranjang');
    }
  }

  Future<bool> tambahKeranjang({
      required int idTeknisi,
      required int idKeahlian,
      required int harga,
    }) async {
      try {
        final storage = FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );
        final token = await storage.read(key: 'token');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? idUser = prefs.getInt('id_user');

        if (idUser == null) {
          print("❌ User belum login");
          return false;
        }

        final url = Uri.parse("${BaseUrl.api}/keranjang/add");
        final response = await http.post(
          url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "id_pelanggan": idUser,
            "id_teknisi": idTeknisi,
            "id_keahlian": idKeahlian,
            "harga": harga,
          }),
        );

        print("📡 [POST] $url → ${response.statusCode}");
        print("Response: ${response.body}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data["status"] == true;
        } else {
          return false;
        }
      } catch (e) {
        print("🔥 Error tambahKeranjang: $e");
        return false;
      }
    }

  Future<bool> deleteKeranjang(int idKeranjang) async {
    final response = await http.delete(
      Uri.parse("${BaseUrl.server}/api/keranjang/$idKeranjang"),
    );

    return response.statusCode == 200;
  }

  Future<bool> checkout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idUser = prefs.getInt('id_user');

    final response = await http.post(
      Uri.parse("${BaseUrl.server}/api/keranjang/checkout"),
      body: {'id_pelanggan': idUser.toString()},
    );

    return response.statusCode == 200;
  }
}
