import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Future<void> initializeTrackingService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      autoStart: false,
      onStart: onStart,
      isForegroundMode: true,
      notificationChannelId: 'tracking_channel',
      initialNotificationTitle: 'Tracking Aktif',
      initialNotificationContent: 'Melacak lokasi teknisi...',
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      autoStart: false,
    ),
  );
}

void onStart(ServiceInstance service) {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: 'Tracking Teknisi',
      content: 'Mengirim lokasi...',
    );
  }

  Timer.periodic(const Duration(seconds: 10), (timer) async {

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await http.post(
      Uri.parse("https://yourdomain.com/api/update-lokasi-teknisi"),
      body: {
        "lat": position.latitude.toString(),
        "lng": position.longitude.toString(),
        "id_teknisi": "1", // ganti dari auth
      },
    );
  });
}
