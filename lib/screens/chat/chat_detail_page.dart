import 'package:flutter/material.dart';

class ChatDetailPage extends StatefulWidget {
  final String name;
  const ChatDetailPage({super.key, required this.name});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      'text':
          'AC di rumah saya mengeluarkan suara berisik dan keluar bau tidak sedap, bisa dibersihkan lagi? Saya butuh bantuan untuk membersihkannya menyeluruh.',
      'isMe': true,
      'time': '10:24',
    },
    {
      'text': 'Baik, saya segera kesana!',
      'isMe': false,
      'time': '10:24',
    },
    {
      'text': 'Pekerjaan sudah selesai',
      'isMe': false,
      'time': '10:24',
    },
    {
      'text': 'Bapak sudah bisa cek AC bapak',
      'isMe': false,
      'time': '10:24',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      messages.add({
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': '10:25',
      });
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF004E92),
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const Text("Online",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              // Handle each menu
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Tampilkan Profil')),
              const PopupMenuItem(value: 'home', child: Text('Kembali ke halaman utama')),
              const PopupMenuItem(value: 'search', child: Text('Cari')),
              const PopupMenuItem(value: 'mute', child: Text('Senyapkan')),
              const PopupMenuItem(value: 'report', child: Text('Laporkan pengguna ini')),
              const PopupMenuItem(value: 'help', child: Text('Butuh bantuan?')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 1) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Hari ini",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }

                final msg = messages[index > 1 ? index - 1 : 0];
                final isMe = msg['isMe'] as bool;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFF004E92)
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                            Radius.circular(isMe ? 16 : 0),
                        bottomRight:
                            Radius.circular(isMe ? 0 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'],
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe
                                ? Colors.white70
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo, color: Colors.blue),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.blue),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Lorem ipsum lihat selengkapnya",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
