import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/base_url.dart';
import 'api_service.dart';

class ChatService {
  static Future<int?> createOrGetChat(
      int idTeknisi, int idUser) async {
    try {
      final token = await ApiService.storage.read(key: 'token');

      Map<String, String> body = {
        "id_user": idUser.toString(),
        "id_teknisi": idTeknisi.toString(),
      };

      print("============================================");
      print("🔵 [CHAT REQUEST]");
      print("URL: ${BaseUrl.server}/api/chat/start");
      print("Body: $body");
      print("Token: $token");
      print("--------------------------------------------");

      final response = await http.post(
        Uri.parse("${BaseUrl.server}/api/chat/start"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: body,
      );

      print("🔵 [CHAT RESPONSE]");
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");
      print("--------------------------------------------");

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        return data["chat"]["id_chat"];
      }
    } catch (e) {
      print("❌ ChatService Exception: $e");
    }

    print("❌ Gagal membuat/mengambil chat ID");
    return null;
  }
}
