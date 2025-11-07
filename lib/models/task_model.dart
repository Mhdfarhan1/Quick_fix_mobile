// lib/models/task_model.dart
class Task {
  final int id;
  final String namaPelanggan;
  final String deskripsi;
  final String statusTugas;
  final String estimasi;
  final double? latitude;
  final double? longitude;

  Task({
    required this.id,
    required this.namaPelanggan,
    required this.deskripsi,
    required this.statusTugas,
    required this.estimasi,
    this.latitude,
    this.longitude,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      namaPelanggan: json['nama_pelanggan'],
      deskripsi: json['deskripsi'],
      statusTugas: json['status_tugas'],
      estimasi: json['estimasi'],
      latitude: (json['latitude'] != null)
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: (json['longitude'] != null)
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }
}
