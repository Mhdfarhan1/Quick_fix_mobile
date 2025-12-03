import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/base_url.dart';

class TeknisiTrackingService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: onStart,
        isForegroundMode: true,
        notificationChannelId: 'tracking_channel',
        initialNotificationTitle: 'Tracking Teknisi',
        initialNotificationContent: 'Sedang mengirim lokasi...',
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        autoStart: false,
      ),
    );
  }

  static void onStart(ServiceInstance service) async {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      final prefs = await SharedPreferences.getInstance();

      final idTeknisi = prefs.getInt("id_teknisi");
      final status = prefs.getString("status");

      if (idTeknisi == null) return;

      if (status == 'selesai') {
        service.stopSelf();
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final url = "${BaseUrl.api}/update-lokasi-teknisi";

      await http.post(
        Uri.parse(url),
        body: {
          "id_teknisi": idTeknisi.toString(),
          "latitude": pos.latitude.toString(),
          "longitude": pos.longitude.toString(),
        },
      );
    });
  }
}
