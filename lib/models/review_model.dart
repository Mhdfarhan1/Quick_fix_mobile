class TechnicianReview {
  final int id;
  final int idPemesanan;
  final int idPelanggan;
  final int idTeknisi;
  final int rating;
  final String komentar;
  final String namaPelanggan;
  final String? fotoUrl; // ✅ TAMBAH INI
  final DateTime? createdAt;

  TechnicianReview({
    required this.id,
    required this.idPemesanan,
    required this.idPelanggan,
    required this.idTeknisi,
    required this.rating,
    required this.komentar,
    required this.namaPelanggan,
    this.fotoUrl, // ✅ TAMBAH INI
    required this.createdAt,
  });

  factory TechnicianReview.fromJson(Map<String, dynamic> json) {
    return TechnicianReview(
      id: json['id_ulasan'],
      idPemesanan: json['id_pemesanan'],
      idPelanggan: json['id_pelanggan'],
      idTeknisi: json['id_teknisi'],
      rating: json['rating'],
      komentar: json['komentar'] ?? "",
      namaPelanggan: json['pelanggan']?['nama'] ?? "Tidak diketahui",

      // ✅ AMBIL LANGSUNG DARI API
      fotoUrl: json['pelanggan']?['foto_url'],

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
