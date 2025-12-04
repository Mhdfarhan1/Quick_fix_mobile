import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../models/notification_model.dart';
import '../config/base_url.dart';
import 'api_service.dart';


class NotificationService {
  static String baseUrl = BaseUrl.api;


  late PusherChannelsFlutter _pusher;
  bool _initialized = false;

  Future<List<NotificationModel>> getNotifications(int userId) async {

    final res = await ApiService. request(
      method: "GET",
      endpoint: "/notifications",
    );

    print("NOTIF RESPONSE => ${res['data']}");

    if (res["statusCode"] != 200) {
      throw Exception("Gagal mengambil notifikasi");
    }

    final data = res["data"]["data"] as List;

    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markAsRead(int id) async {
    await http.post(Uri.parse("$baseUrl/notifications/$id/read"));
  }

  // ==== PUSHER REALTIME ====
  Future<void> initPusher({
    required int userId,
    required Function(NotificationModel notif) onMessage,
  }) async {
    if (_initialized) return;

    _pusher = PusherChannelsFlutter.getInstance();

    await _pusher.init(
      apiKey: "01cf58de43745499fa3f",
      cluster: "ap1",
      onEvent: (event) {
        final data = jsonDecode(event.data);
        onMessage(NotificationModel.fromJson(data));
      },
    );

    await _pusher.subscribe(
      channelName: "notifikasi.$userId",
    );



    _initialized = true;
  }
}
