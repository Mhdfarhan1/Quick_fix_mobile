import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'masalah_pesanan_page.dart';
import 'masalah_pembayaran_page.dart';
import 'masalah_aplikasi_page.dart';
import 'masalah_akun_page.dart';

class KategoriLaporanPage extends StatelessWidget {
  const KategoriLaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        title: const Text(
          "Pilih Jenis Kendala",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildItem(context, "Masalah Pesanan", CupertinoIcons.cube_box),
          _buildItem(context, "Masalah Pembayaran", CupertinoIcons.creditcard),
          _buildItem(context, "Masalah Aplikasi", CupertinoIcons.ant),
          _buildItem(
            context,
            "Masalah Akun",
            CupertinoIcons.person_crop_circle_badge_exclam,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0C4481), size: 28),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (title == "Masalah Pesanan") {
            Navigator.of(context)
                .push(_smoothRoute(const MasalahPesananPage()));
          } else if (title == "Masalah Pembayaran") {
            Navigator.of(context)
                .push(_smoothRoute(const MasalahPembayaranPage()));
          } else if (title == "Masalah Aplikasi") {
            Navigator.of(context)
                .push(_smoothRoute(const MasalahAplikasiPage()));
          } else if (title == "Masalah Akun") {
            Navigator.of(context)
                .push(_smoothRoute(const MasalahAkunPage()));
          }
        },
      ),
    );
  }
}

/// Route dengan animasi smooth: slide dari kanan + fade
Route _smoothRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // mulai dari kanan
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      final slideTween =
      Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final fadeTween =
      Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
  );
}
