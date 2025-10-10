import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../notifikasi/notif.dart'; // Pastikan file notif.dart ada di folder yang sama

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      "sender": "Ahmad Sahroni",
      "message": "Halo kak, saya teknisi yang akan membantu hari ini.",
      "isUser": false,
      "time": DateTime.now(),
    },
    {
      "sender": "Kamu",
      "message": "Halo bang Ahmad, iya siap!",
      "isUser": true,
      "time": DateTime.now(),
    },
  ];

  // 🔹 Fungsi kirim pesan
  void _sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add({
        "sender": "Kamu",
        "message": trimmed,
        "isUser": true,
        "time": DateTime.now(),
      });
    });

    _controller.clear();

    // 🔁 Simulasi balasan otomatis (1 detik)
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          "sender": "Ahmad Sahroni",
          "message": "Terima kasih sudah mengirim pesan!",
          "isUser": false,
          "time": DateTime.now(),
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D3557),
        elevation: 3,
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/teknisi.jpg'),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Ahmad Sahroni',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur panggilan belum tersedia')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotifikasiPage()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              String message = switch (value) {
                'Profil' => 'Lihat Profil Teknisi',
                'Permintaan Baru' => 'Buat Permintaan Baru',
                'Laporkan' => 'Laporkan Masalah',
                _ => '',
              };
              if (message.isNotEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(message)));
              }
            },
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem(value: 'Profil', child: Text('Lihat Profil Teknisi')),
              PopupMenuItem(value: 'Permintaan Baru', child: Text('Buat Permintaan Baru')),
              PopupMenuItem(value: 'Laporkan', child: Text('Laporkan Masalah')),
            ],
          ),
        ],
      ),

      // 💬 Body Chat
      body: Column(
        children: [
          // 🗨️ List Pesan
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final bool isUser = msg['isUser'] as bool;
                final formattedTime = DateFormat('HH:mm').format(msg['time']);

                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFFFFCC33)
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                        isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight:
                        isUser ? Radius.zero : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg['message'],
                          style: TextStyle(
                            fontSize: 15,
                            color: isUser ? Colors.black : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time,
                                size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 3),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ✏️ Input Pesan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, -1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined,
                        color: Colors.grey),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: const InputDecoration(
                        hintText: "Tulis pesan...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: Color(0xFF1D3557), size: 26),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
