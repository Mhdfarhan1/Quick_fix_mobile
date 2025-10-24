import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  final List<Map<String, String>> notifications = const [
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
      "subtitle": "Sudah waktunya servis rutin, nih! Cegah kerusakan...",
      "time": "6 jam lalu"
    },
    {
      "title": "Garansi",
      "subtitle": "Garansi kamu aktif sampai tanggal tertentu...",
      "time": "1 hari lalu"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: const Color(0xFF1D3557),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                item["title"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(item["subtitle"]!),
              trailing: Text(
                item["time"]!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              onTap: () {
                // nanti bisa dikaitkan dengan detail pesan
              },
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFFF0F2F5),
    );
  }
}
