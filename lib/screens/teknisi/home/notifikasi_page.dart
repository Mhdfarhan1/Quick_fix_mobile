import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifs = [
      {
        "title": "Pembayaran",
        "subtitle": "Yay! Pembayarannya untuk servis AC sudah berhasil...",
        "time": "2 menit lalu"
      },
      {
        "title": "Teknisi segera datang!",
        "subtitle": "Jangan lupa, teknisi akan datang hari ini...",
        "time": "5 menit lalu"
      },
      {
        "title": "Pemesanan",
        "subtitle": "Hai! Anda baru saja memesan servis...",
        "time": "1 jam lalu"
      },
      {
        "title": "Penilaian",
        "subtitle": "Gimana hasil servisnya kemarin? Yuk, kasih rating...",
        "time": "3 jam lalu"
      },
      {
        "title": "Waktunya Perawatan!",
        "subtitle": "Sudah waktunya servis rutin nih! Cegah kerusakan...",
        "time": "6 jam lalu"
      },
      {
        "title": "Garansi",
        "subtitle": "Garansi kamu aktif sampai tanggal tertentu...",
        "time": "1 hari lalu"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),
      appBar: AppBar(
        backgroundColor:  Color.fromARGB(255, 12, 68, 129),
        foregroundColor: Colors.white, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // otomatis putih
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifs.length,
        itemBuilder: (context, i) {
          final n = notifs[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      n["title"]!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      n["time"]!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  n["subtitle"]!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
