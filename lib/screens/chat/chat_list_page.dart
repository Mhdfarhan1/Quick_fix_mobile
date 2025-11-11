import 'package:flutter/material.dart';
import 'chat_detail_page.dart'; // pastikan file ini ada

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  int _selectedIndex = 2; // posisi default di tab Chat

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Contoh: Navigator.push ke Beranda
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const BerandaPage()));
        break;
      case 1:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const AktivitasPage()));
        break;
      case 2:
        // Sudah di halaman Chat
        break;
      case 3:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiPage()));
        break;
      case 4:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = [
      {
        'name': 'Mas Cahyo',
        'message': 'Lorem ipsum lihat seleng...',
        'time': '09:42 AM',
        'unread': 10,
      },
      {
        'name': 'Rahmat TV',
        'message': 'Lorem ipsum lihat seleng...',
        'time': '09:42 AM',
        'unread': 0,
      },
      {
        'name': 'Bagas Bengkel',
        'message': 'Lorem ipsum lihat seleng...',
        'time': '09:42 AM',
        'unread': 5,
      },
      {
        'name': 'Adil Teknisi pipa',
        'message': 'Lorem ipsum lihat seleng...',
        'time': '09:42 AM',
        'unread': 0,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chat",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: "Silahkan cari",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey,
                      ),
                      title: Text(
                        chat['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(chat['message']),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            chat['time'],
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          if (chat['unread'] > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${chat['unread']}+",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChatDetailPage(name: chat['name']),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF0C4481),
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: const Color(0xFFFFC918),
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Aktivitas'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Notifikasi'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}
