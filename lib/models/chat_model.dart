class ChatModel {
  final int idChat;
  final int idUser;
  final int idTeknisi;

  final String? namaUser;
  final String? namaTeknisi;

  final String? lastMessage;
  final DateTime? lastMessageAt;

  ChatModel({
    required this.idChat,
    required this.idUser,
    required this.idTeknisi,
    this.namaUser,
    this.namaTeknisi,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      idChat: json['id_chat'],
      idUser: json['id_user'],
      idTeknisi: json['id_teknisi'],

      // dari tabel user (pelanggan)
      namaUser: json['user']?['nama'],

      // dari teknisi → user → nama
      namaTeknisi: json['teknisi']?['user']?['nama'],

      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
    );
  }
}
