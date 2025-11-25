import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service_ios/flutter_background_service_ios.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../config/base_url.dart';

class TeknisiTrackingService {
  // ----------------------------------------------------
  // INIT SERVICE
  // ----------------------------------------------------
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

  // ----------------------------------------------------
  // SERVICE START
  // ----------------------------------------------------
  static void onStart(ServiceInstance service) async {
    // Pastikan lokasi sudah granted
    await _checkLocationPermission();

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      final prefs = await service.getSharedPreferences();

      final idTeknisi = prefs?.getInt("id_teknisi");
      final status = prefs?.getString("status");

      // Debug
      print("[TRACKING] id_teknisi: $idTeknisi | status: $status");

      if (idTeknisi == null) {
        print("[TRACKING] ID teknisi null → stop pengiriman lokasi");
        return;
      }

      if (status == 'selesai') {
        print("[TRACKING] Pesanan selesai → berhenti tracking");
        service.stopSelf();
        return;
      }

      // Ambil lokasi
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("[TRACKING] Lokasi → ${pos.latitude}, ${pos.longitude}");

      // API request
      final url = Uri.parse("${BaseUrl.api}/update-lokasi-teknisi");

      try {
        final res = await http.post(
          url,
          body: {
            "id_teknisi": idTeknisi.toString(),
            "latitude": pos.latitude.toString(),
            "longitude": pos.longitude.toString(),
          },
        );

        print("[TRACKING] API → ${res.statusCode} | ${res.body}");
      } catch (e) {
        print("[TRACKING] ERROR SEND → $e");
      }
    });
  }

  // ----------------------------------------------------
  // PERMISSION HANDLER
  // ----------------------------------------------------
  static Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("[TRACKING] Lokasi mati, minta user hidupkan GPS");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      print("[TRACKING] Izin lokasi ditolak permanen!");
    }
  }
}
