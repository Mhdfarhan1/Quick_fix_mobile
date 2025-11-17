import 'package:flutter/material.dart';
import 'chat_detail_teknisi_page.dart';

class ChatTeknisiPage extends StatelessWidget {
  const ChatTeknisiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = [
      {
        "nama": "Rizky Hidayat",
        "pesan": "Lorem ipsum lihat seleng...",
        "jam": "09:42 AM",
        "badge": "10+",
      },
      {
        "nama": "Rani Syahrini",
        "pesan": "Sedang menunggu konfirmasi...",
        "jam": "09:12 AM",
        "badge": "",
      },
      {
        "nama": "Mahfuz Hadid",
        "pesan": "Terima kasih atas bantuannya!",
        "jam": "08:50 AM",
        "badge": "2+",
      },
      {
        "nama": "Farhan Ali",
        "pesan": "Kapan teknisi bisa datang?",
        "jam": "07:35 AM",
        "badge": "",
      },
      {
        "nama": "Rahel",
        "pesan": "Hai,apasi bisa membantukuu?",
        "jam": "07:55 AM",
        "badge": "",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[50],
        elevation: 0,
        title: const Text(
          "Chat",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 🔍 Kolom pencarian
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Silahkan cari",
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ),

          // 💬 List Chat
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return GestureDetector(
                  onTap: () {
                    // Navigasi ke detail chat
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailTeknisiPage(
                          nama: chat["nama"],
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    showChatOptionDialog(context, chat["nama"]);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(width: 12),

                        // Nama & Pesan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat["nama"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                chat["pesan"],
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Jam + Badge
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              chat["jam"],
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            if (chat["badge"] != "")
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[800],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  chat["badge"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
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
        ],
      ),
    );
  }
}

// 🔸 Dialog popup ketika ditekan lama
void showChatOptionDialog(BuildContext context, String nama) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nama,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Chat ditandai sebagai dibaca"),
                    ),
                  );
                },
                child: const Text(
                  "Dibaca",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  showDeleteConfirmationDialog(context, nama);
                },
                child: const Text(
                  "Hapus",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// 🔸 Konfirmasi hapus
void showDeleteConfirmationDialog(BuildContext context, String nama) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Yakin ingin menghapus $nama?",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("$nama berhasil dihapus")),
                      );
                    },
                    child: const Text(
                      "Iya",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Tidak",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
