import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ApiTeknisi {
  final ApiService _api = ApiService();

  // Ambil semua teknisi
  Future<List<dynamic>> getListTeknisi() async {
    final response = await _api.get('get_teknisi_list');
    return response;
  }

  // Ambil detail teknisi berdasarkan ID
  Future<Map<String, dynamic>> getTeknisiById(int id) async {
    final response = await _api.get('get_teknisi?id=$id');
    return response;
  }
}
