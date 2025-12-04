import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/chat_model.dart';
import 'chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListPage extends StatefulWidget {
  @override
  State<ChatListPage> createState() => _ChatListPageState();
  
}

class _ChatListPageState extends State<ChatListPage> {
  List<ChatModel> chats = [];

  String role = "pelanggan";

  @override
  void initState() {
    super.initState();
    loadRole();
    loadChats();
  }



  String formatTime(DateTime? time) {
    if (time == null) return "";

    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }

    return "${time.day}/${time.month}";
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString("role") ?? "pelanggan";
    });
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

  Widget buildChatTile(ChatModel chat, String role) {

    // Kalau user biasa → tampilkan nama teknisi
    // Kalau teknisi → tampilkan nama user
    final displayName = role == "teknisi"
        ? chat.namaUser ?? "Pelanggan"
        : chat.namaTeknisi ?? "Teknisi";

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(0xFF0C4481),
        child: Text(
          displayName[0],
          style: TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        displayName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat.lastMessage ?? 'Belum ada pesan',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: chat.lastMessageAt != null
          ? Text(
              TimeOfDay.fromDateTime(chat.lastMessageAt!).format(context),
              style: TextStyle(fontSize: 12),
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
    return Scaffold(
      backgroundColor: Color(0xFFF5FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Chat", style: TextStyle(
          color: Colors.black,
          fontSize: 28,
          fontWeight: FontWeight.bold
        )),
      ),

      body: Column(
        children: [

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Color(0xFFEDEAEA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Silahkan cari",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          SizedBox(height: 15),

          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, i) {
                return buildChatTile(chats[i], role);
              },
            ),
          ),
        ],
      ),
    );
  }
}
