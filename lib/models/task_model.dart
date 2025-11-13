// lib/models/task_model.dart
import 'package:intl/intl.dart';

class Task {
  final int id;
  final String namaPelanggan;
  final String deskripsi;
  final String statusTugas;
  final int? harga;
  final String alamatLengkap;
  final String? latitude;
  final String? longitude;
  final String? jamBooking; // raw dari API
  final String? jamBookingFormatted; // hasil format HH:mm WIB
  final DateTime createdAt;

  Task({
    required this.id,
    required this.namaPelanggan,
    required this.deskripsi,
    required this.statusTugas,
    this.harga,
    required this.alamatLengkap,
    this.latitude,
    this.longitude,
    this.jamBooking,
    this.jamBookingFormatted,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // ambil jam booking mentah
    String? rawJam = json['jam_booking'];

    // format jam_booking ke "HH:mm WIB"
    String? formattedJam;
    if (rawJam != null && rawJam.isNotEmpty) {
      try {
        DateTime parsed = DateTime.parse(rawJam);
        formattedJam = DateFormat('HH:mm').format(parsed) + ' WIB';
      } catch (_) {
        formattedJam = rawJam;
      }
    }

    // parsing createdAt, fallback ke sekarang
    DateTime created = DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now();

    return Task(
      id: json['id'] ?? 0,
      namaPelanggan: json['nama_pelanggan'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      statusTugas: json['status_tugas'] ?? '',
      harga: json['harga'] != null ? int.tryParse(json['harga'].toString()) : null,
      alamatLengkap: json['alamat_lengkap'] ?? '',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      jamBooking: rawJam,
      jamBookingFormatted: formattedJam,
      createdAt: created,
    );
  }
}
