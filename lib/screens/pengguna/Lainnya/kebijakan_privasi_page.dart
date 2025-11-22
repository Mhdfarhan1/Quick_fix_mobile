import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KebijakanPrivasiPage extends StatelessWidget {
  const KebijakanPrivasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        title: const Text(
          "Kebijakan Privasi",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            icon: CupertinoIcons.lock_shield,
            title: "Privasi & Keamanan Data",
            content:
                "Kami berkomitmen menjaga privasi dan keamanan data pengguna. "
                "Setiap informasi yang dikumpulkan digunakan untuk meningkatkan pengalaman layanan.",
          ),
          _buildCard(
            icon: CupertinoIcons.doc_text,
            title: "Pengumpulan Informasi",
            content:
                "Kami mengumpulkan data seperti nama, email, nomor telepon, dan riwayat pemesanan. "
                "Data ini digunakan untuk kebutuhan operasional aplikasi.",
          ),
          _buildCard(
            icon: CupertinoIcons.eye,
            title: "Akses & Kontrol Pengguna",
            content:
                "Anda memiliki hak untuk mengubah, memperbarui, atau menghapus data pribadi kapan saja.",
          ),
          _buildCard(
            icon: CupertinoIcons.shield_lefthalf_fill,
            title: "Keamanan Sistem",
            content:
                "Aplikasi kami menggunakan enkripsi modern untuk melindungi data pengguna "
                "dari akses tidak sah.",
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Color(0xFF0C4481), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black54, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
