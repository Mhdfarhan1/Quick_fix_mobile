import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/base_url.dart';
import '../models/task_model.dart';

class TaskService {
  final String baseUrl = BaseUrl.api; // ✅ clean

  Future<List<Task>> fetchTasks(int teknisiId) async {
    try {
      final url = Uri.parse('$baseUrl/teknisi/$teknisiId/tugas');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['status'] == true && body['data'] != null) {
          final List data = body['data'];
          return data.map((item) => Task.fromJson(item)).toList();
        }

        print('⚠️ ${body['message'] ?? "Tidak ada data tugas"}');
        return [];
      }

      print('❌ Gagal memuat data: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error fetchTasks: $e');
      return [];
    }
  }
}
