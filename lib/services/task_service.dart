import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/base_url.dart';
import '../models/task_model.dart';

class TaskService {
  final String baseUrl = BaseUrl.api;

  Future<List<Task>> fetchTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('❌ Token tidak ditemukan, user belum login');
        return [];
      }

      final url = Uri.parse('$baseUrl/tugas-teknisi');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Response API: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['status'] == true) {
          final List data = body['data'];
          return data.map((i) => Task.fromJson(i)).toList();
        }

        return [];
      }

      print('❌ Status error: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error fetchTasks: $e');
      return [];
    }
  }

  Future<List<Task>> fetchPesananBaru() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("❌ Token tidak ditemukan");
        return [];
      }

      final url = Uri.parse("$baseUrl/teknisi/pesanan/baru");

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📥 PESANAN BARU: ${response.body}");

      if (response.statusCode != 200) {
        print("❌ Status code: ${response.statusCode}");
        return [];
      }

      final body = jsonDecode(response.body);

      if (body['status'] == true && body['data'] is List) {
        final List data = body['data'];
        return data.map((e) => Task.fromJson(e)).toList();
      } else {
        print("⚠️ Tidak ada pesanan baru");
        return [];
      }
    } catch (e) {
      print("❌ Error fetchPesananBaru: $e");
      return [];
    }
  }
}
