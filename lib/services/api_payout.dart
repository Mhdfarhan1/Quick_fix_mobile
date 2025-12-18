import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payout.dart';
import '../config/base_url.dart';

class ApiPayoutService {
  static Future<List<Payout>> getPayoutByTeknisi(String token) async {
    final url = Uri.parse("${BaseUrl.api}/payout/teknisi");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      return data.map((e) => Payout.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data payout");
    }
  }

  static Future<bool> requestPayout({
    required String token,
    required int totalDibayar,
  }) async {
    final url = Uri.parse("${BaseUrl.api}/payout/request");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "total_dibayar": totalDibayar,
      }),
    );

    return response.statusCode == 200;
  }
}
