import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../config/base_url.dart';

class TeknisiTrackingService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
        notificationTitle: "Tracking Teknisi",
        notificationText: "Sedang mengirim lokasi...",
        notificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: (_) async => true,
      ),
    );
  }

  static void onStart(ServiceInstance service) async {
    Timer.periodic(Duration(seconds: 5), (timer) async {

      final result = await service.getSharedPreferences();

      final idTeknisi = result?.getInt("id_teknisi");
      final status = result?.getString("status");

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
