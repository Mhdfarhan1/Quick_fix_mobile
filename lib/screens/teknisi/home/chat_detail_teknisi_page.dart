import 'package:flutter/material.dart';

class ChatDetailTeknisiPage extends StatefulWidget {
  final String nama;

  const ChatDetailTeknisiPage({super.key, required this.nama});

  @override
  State<ChatDetailTeknisiPage> createState() => _ChatDetailTeknisiPageState();
}

class _ChatDetailTeknisiPageState extends State<ChatDetailTeknisiPage> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> messages = [
    {"text": "Selamat pagi, teknisi!", "isSender": false},
    {"text": "Pagi juga, ada yang bisa saya bantu?", "isSender": true},
    {"text": "AC saya rusak, bisa diperbaiki hari ini?", "isSender": false},
  ];

  void sendMessage() {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({"text": controller.text.trim(), "isSender": true});
    });

    controller.clear();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        messages.add({
          "text": "Baik, saya cek jadwal terlebih dahulu ya.",
          "isSender": false,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],

      // ---------------------------------------------------------
      // APPBAR DENGAN ICON CALL + TITIK TIGA
      // ---------------------------------------------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.nama,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            
          ],
        ),
        actions: [
          // 👉 Call dengan notifikasi
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Sedang memanggil pengguna..."),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          // 👉 Menu titik tiga
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              print("Menu dipilih: $value");
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'profil',
                  child: Text("Tampilkan Profil"),
                ),
                const PopupMenuItem(
                  value: 'home',
                  child: Text("Kembali ke halaman utama"),
                ),
                const PopupMenuItem(value: 'cari', child: Text("Cari")),
                const PopupMenuItem(value: 'mute', child: Text("Senyapkan")),
                const PopupMenuItem(
                  value: 'lapor',
                  child: Text("Laporkan pengguna ini"),
                ),
                const PopupMenuItem(
                  value: 'bantuan',
                  child: Text("Butuh bantuan?"),
                ),
              ];
            },
          ),
        ],
      ),

      // ---------------------------------------------------------
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg["isSender"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: ChatBubble(
                    text: msg["text"],
                    isSender: msg["isSender"],
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
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue[700],
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
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

// ---------------------------------------------------------
// CHAT BUBBLE
// ---------------------------------------------------------

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSender;

  const ChatBubble({super.key, required this.text, required this.isSender});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSender ? Colors.blue[700] : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSender ? Colors.white : Colors.black,
          fontSize: 14,
        ),
      ),
    );
  }
}
