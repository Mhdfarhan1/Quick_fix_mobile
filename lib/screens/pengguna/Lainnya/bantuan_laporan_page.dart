import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'kategori_laporan_page.dart';
import 'pusat_bantuan_FAQ_page.dart';

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
            title: "Pusat Bantuan Pelanggan",
            subtitle: "Cari jawaban dan panduan penggunaan",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PusatBantuanFAQPage()),
              );
            },
          ),
          _buildCard(
            icon: CupertinoIcons.exclamationmark_bubble,
            title: "Laporkan Masalah",
            subtitle: "Laporkan masalah pesanan, pembayaran, atau aplikasi",
            onTap: () {
              Navigator.of(context).push(_slideRouteToKategori());
            },
          ),
          _buildCard(
            icon: CupertinoIcons.phone,
            title: "Kontak Dukungan",
            subtitle: "Email: support@example.com\nWA: 0812-3456-7890",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0C4481), size: 30),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.black54, height: 1.3),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

Route _slideRouteToKategori() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const KategoriLaporanPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      return SlideTransition(
        position: animation.drive(Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve))),
        child: FadeTransition(
          opacity: animation.drive(
              Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: curve))),
          child: child,
        ),
      );
    },
  );
}
