class Payout {
  final int id;
  final int teknisiId;
  final int totalPendapatan;
  final int totalDitahan;
  final int totalDibayar;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Payout({
    required this.id,
    required this.teknisiId,
    required this.totalPendapatan,
    required this.totalDitahan,
    required this.totalDibayar,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['id'],
      teknisiId: json['id_teknisi'],
      totalPendapatan: json['total_pendapatan'],
      totalDitahan: json['total_ditahan'],
      totalDibayar: json['total_dibayar'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_teknisi": teknisiId,
      "total_pendapatan": totalPendapatan,
      "total_ditahan": totalDitahan,
      "total_dibayar": totalDibayar,
      "status": status,
    };
  }
}
