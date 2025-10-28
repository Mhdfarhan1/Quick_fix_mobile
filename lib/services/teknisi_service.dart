import 'dart:convert';
import 'package:http/http.dart' as http;

class TeknisiService {
  // Ganti 'localhost' jadi '10.0.2.2' kalau kamu pakai emulator Android
  final String baseUrl = 'http://172.29.76.247:8000/api';

  /// 🔹 Ambil semua teknisi
  Future<List<dynamic>> getTeknisiList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_teknisi_list'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // kalau response berupa array langsung, bukan objek {data:[]}, sesuaikan
        return data is List ? data : (data['data'] ?? []);
      } else {
        throw Exception('Gagal memuat data teknisi (${response.statusCode})');
      }
    } catch (e) {
      print('Error getTeknisiList: $e');
      return [];
    }
  }

  /// 🔹 Ambil teknisi berdasarkan ID
  Future<Map<String, dynamic>?> getTeknisiById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_teknisi?id=$id'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data.first : data['data'];
      } else {
        throw Exception('Gagal memuat detail teknisi (${response.statusCode})');
      }
    } catch (e) {
      print('Error getTeknisiById: $e');
      return null;
    }
  }

  /// 🔹 Ambil status pesanan (opsional)
  Future<List<dynamic>> getStatusPesanan(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_pemesanan?id_pelanggan=$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : (data['data'] ?? []);
      } else {
        throw Exception('Gagal memuat status pesanan (${response.statusCode})');
      }
    } catch (e) {
      print('Error getStatusPesanan: $e');
      return [];
    }
  }
}
