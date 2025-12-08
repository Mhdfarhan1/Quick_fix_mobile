class NotificationModel {
  final int id;
  final int idUser;
  final String judul;
  final String pesan;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.idUser,
    required this.judul,
    required this.pesan,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      idUser: json['id_user'],
      judul: json['judul'],
      pesan: json['pesan'],
      isRead: json['is_read'] == 1,
      createdAt: json['created_at'] ?? "",
    );
  }
}
