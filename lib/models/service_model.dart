class ServiceModel {
  final int id;
  final String judul;
  final String? gambar;
  final double harga;
  final String? deskripsi;

  ServiceModel({
    required this.id,
    required this.judul,
    this.gambar,
    required this.harga,
    this.deskripsi,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id_keahlian'] is int ? json['id_keahlian'] : int.tryParse(json['id_keahlian'].toString()) ?? 0,
      judul: json['nama_keahlian'] ?? 'Unknown Service',
      gambar: json['gambar_layanan'],
      harga: json['harga'] is int 
          ? (json['harga'] as int).toDouble() 
          : double.tryParse(json['harga'].toString()) ?? 0.0,
      deskripsi: json['deskripsi'],
    );
  }
}
