import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/base_url.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OrderService {
  final String baseUrl = BaseUrl.api;

  Future<List<dynamic>> getOrders() async {
    final storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );

    final token = await storage.read(key: 'token');


    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/get_pemesanan_by_user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == true) {
        return body['data'];
      }
    }
    return [];
  }
}
