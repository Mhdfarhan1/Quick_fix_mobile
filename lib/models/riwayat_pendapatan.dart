class RiwayatPendapatan {
  final String namaKeahlian;
  final int amount;
  final DateTime tanggal;

  RiwayatPendapatan({
    required this.namaKeahlian,
    required this.amount,
    required this.tanggal,
  });

  factory RiwayatPendapatan.fromJson(Map<String, dynamic> json) {
    return RiwayatPendapatan(
      namaKeahlian: json['nama_keahlian'],
      amount: json['amount'],
      tanggal: DateTime.parse(json['created_at']),
    );
  }
}
