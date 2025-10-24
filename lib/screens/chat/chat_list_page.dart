import 'package:flutter/material.dart';
import 'chat.dart'; // Pastikan file ini sudah ada

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final List<Map<String, String>> _teknisiList = [
    {
      "nama": "Barji Jegel",
      "gambar": "https://randomuser.me/api/portraits/men/1.jpg",
    },
    {
      "nama": "Agus Pratama",
      "gambar": "https://randomuser.me/api/portraits/men/2.jpg",
    },
    {
      "nama": "uhuy",
      "gambar": "https://randomuser.me/api/portraits/women/3.jpg",
    },
    {
      "nama": "Budi santoso",
      "gambar": "https://randomuser.me/api/portraits/men/4.jpg",
    },
    {
      "nama": "Carolyn Francis",
      "gambar": "https://randomuser.me/api/portraits/women/5.jpg",
    },
    {
      "nama": "Isaiah McGee",
      "gambar": "https://randomuser.me/api/portraits/men/6.jpg",
    },
    {
      "nama": "Mark Holmes",
      "gambar": "https://randomuser.me/api/portraits/men/7.jpg",
    },
    {
      "nama": "Russell McGuire",
      "gambar": "https://randomuser.me/api/portraits/women/8.jpg",
    },
  ];

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredList = _teknisiList
        .where((teknisi) =>
            teknisi["nama"]!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        title: const Text(
          "Chat Kamu",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 🔹 Search Bar
          Container(
            color: const Color(0xFF0C4481),
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🔹 List Chat
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final teknisi = filteredList[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(teknisi["gambar"]!),
                  ),
                  title: Text(teknisi["nama"]!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _iconButton(
                        icon: Icons.chat,
                        color: const Color(0xFFFFCC33),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                namaTeknisi: teknisi["nama"]!,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _iconButton(
                        icon: Icons.call,
                        color: const Color(0xFF0C4481),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Memanggil ${teknisi["nama"]}...",
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Custom tombol ikon
  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
