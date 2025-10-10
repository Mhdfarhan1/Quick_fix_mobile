import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notif.dart';



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

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        "sender": "Kamu",
        "message": text,
        "isUser": true,
        "time": DateTime.now(),
      });

      // Simulasi balasan otomatis Ahmad Sahroni
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({
            "sender": "Ahmad Sahroni",
            "message": "Terima kasih sudah mengirim pesan!",
            "isUser": false,
            "time": DateTime.now(),
          });
        });
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D3557),
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
                    color: Colors.white,
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
              // Aksi panggilan bisa ditambahkan di sini
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
              // Handle opsi menu di sini
              switch (value) {
                case 'Profil':
                  print('Lihat Profil Teknisi');
                  break;
                case 'Permintaan Baru':
                  print('Buat Permintaan Baru');
                  break;
                case 'Laporkan':
                  print('Laporkan Masalah');
                  break;
              }
            },
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem<String>(
                value: 'Profil',
                child: Text('Lihat Profil Teknisi'),
              ),
              PopupMenuItem<String>(
                value: 'Permintaan Baru',
                child: Text('Buat Permintaan Baru'),
              ),
              PopupMenuItem<String>(
                value: 'Laporkan',
                child: Text('Laporkan Masalah'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final formattedTime = DateFormat('HH:mm').format(msg['time']);
                final isUser = msg['isUser'];

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color.fromARGB(255, 245, 185, 19)
                          : const Color(0xFFFFFFFF),
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
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
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
                    decoration: const InputDecoration(
                      hintText: "Tulis pesan...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF1D3557)),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
