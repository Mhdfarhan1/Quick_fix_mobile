import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import 'chat_page.dart';
import '../../widgets/user_bottom_nav.dart';

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

  Future<void> deleteChat(int idChat) async {
    final res = await ApiService.delete('/chat/delete/$idChat');

    if (res['statusCode'] == 200) {
      setState(() {
        chats.removeWhere((c) => c.idChat == idChat);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chat berhasil dihapus")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menghapus chat")),
      );
    }
  }

  void confirmDelete(String name, int idChat) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Yakin ingin menghapus\n$name", textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.only(top: 10),
          content: const SizedBox(height: 5),
          actions: [
            // 👉 GANTI BAGIAN INI
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // tutup popup (AMAN)

                // tampil loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  barrierColor: Colors.black.withOpacity(0.3),
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                await deleteChat(idChat);
                if (!mounted) return;

                Navigator.pop(context); // tutup loading
              },
              child: const Text("Iya", style: TextStyle(color: Colors.red)),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tidak"),
            ),
          ],
        );
      },
    );
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
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Center(
                    child: Text(
                      displayName,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Center(
                    child: Text(
                      "Hapus",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx); // 🔥 WAJIB pakai yg ini
                    confirmDelete(displayName, chat.idChat);
                  },
                ),
              ],
            );
          },
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
      bottomNavigationBar: userRole == "pelanggan"
        ? const UserBottomNav(selectedIndex: 2)
        : null,
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
