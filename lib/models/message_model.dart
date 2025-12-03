import '../config/base_url.dart';
import 'package:intl/intl.dart';

class MessageModel {
  final int idMessage;
  final int? senderUserId;
  final int? senderTeknisiId;
  final String? message;
  final String type;       // text, image, video, file
  final String? fileUrl;   // image OR video
  final String? thumbnailUrl;
  final String? createdAt;

  MessageModel({
    required this.idMessage,
    this.senderUserId,
    this.senderTeknisiId,
    this.message,
    required this.type,
    this.fileUrl,
    this.thumbnailUrl,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) {
    final List at = (j['attachments'] ?? []) as List;
    final attachment = at.isNotEmpty ? at.first : null;

    String? conv(String? p) {
      if (p == null || p.isEmpty) return null;
      if (p.startsWith("http")) return p;
      return "${BaseUrl.storage}/storage/$p";
    }

    // menentukan type pesan
    String detectType() {
      if (attachment == null) return "text";

      final mime = attachment['mime'] ?? "";

      if (mime.contains("image")) return "image";
      if (mime.contains("video")) return "video";
      return "file";
    }

    return MessageModel(
      idMessage: j['id_message'],
      senderUserId: j['sender_user_id'],
      senderTeknisiId: j['sender_teknisi_id'],
      message: j['message'],
      type: detectType(),
      fileUrl: conv(attachment?['path']),
      thumbnailUrl: conv(attachment?['thumbnail']),
      createdAt: j['created_at'],
    );
  }
}
