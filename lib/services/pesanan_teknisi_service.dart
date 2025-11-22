import 'dart:convert';
import 'package:http/http.dart' as http;

class PesananTeknisiService {
  final String baseUrl;

  PesananTeknisiService(this.baseUrl);

  Future<List<dynamic>> getPesananBaru(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/teknisi/pesanan/baru"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = json.decode(res.body);
    return data['data'] ?? [];
  }

  Future<List<dynamic>> getPesananDijadwalkan(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/teknisi/pesanan/dijadwalkan"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = json.decode(res.body);
    return data['data'] ?? [];
  }
}
