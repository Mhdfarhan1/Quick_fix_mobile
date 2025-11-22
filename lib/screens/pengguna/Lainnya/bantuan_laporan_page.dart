import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BantuanLaporanPage extends StatelessWidget {
  const BantuanLaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        title: const Text(
          "Bantuan & Laporan",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            icon: CupertinoIcons.chat_bubble_2_fill,
            title: "Pusat Bantuan",
            subtitle: "Cari jawaban dan panduan penggunaan",
          ),
          _buildCard(
            icon: CupertinoIcons.exclamationmark_bubble,
            title: "Laporkan Masalah",
            subtitle: "Laporkan error, bug, atau kendala aplikasi",
          ),
          _buildCard(
            icon: CupertinoIcons.phone,
            title: "Kontak Dukungan",
            subtitle: "Email: support@example.com\nWA: 0812-3456-7890",
          ),
          _buildCard(
            icon: CupertinoIcons.info,
            title: "Tentang Aplikasi",
            subtitle: "Versi 1.0.0 - Build Stable",
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF0C4481), size: 30),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.black54, height: 1.3),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
