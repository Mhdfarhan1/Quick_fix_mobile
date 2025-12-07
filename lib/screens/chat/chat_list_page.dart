import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<ChatModel> chats = [];

  @override
  void initState() {
    super.initState();
    loadChats();
  }

  Future<void> loadChats() async {
    final res = await ApiService.get('/chat/list');

    if (res['statusCode'] == 200) {
      final data = res['data']['data'] as List;

      setState(() {
        chats = data.map((e) => ChatModel.fromJson(e)).toList();
      });
    }
  }

  Widget buildChatTile(ChatModel chat, String? role) {
    // Tentukan nama ditampilkan berdasarkan role
    final isTeknisi = role == "teknisi";

    final displayName = isTeknisi
        ? (chat.namaUser ?? "Pelanggan")
        : (chat.namaTeknisi ?? "Teknisi");

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF0C4481),
        child: Text(
          displayName[0],
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        displayName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat.lastMessage ?? 'Belum ada pesan',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: chat.lastMessageAt != null
          ? Text(
              TimeOfDay.fromDateTime(chat.lastMessageAt!).format(context),
              style: const TextStyle(fontSize: 12),
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              chatId: chat.idChat,
              idTeknisi: chat.idTeknisi,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<AuthProvider>(context).userRole ?? "pelanggan";

    print("📌 ChatListPage — role: $userRole");

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Chat",
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEAEA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Silahkan cari",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, i) {
                return buildChatTile(chats[i], userRole);
              },
            ),
          ),
        ],
      ),
    );
  }
}
