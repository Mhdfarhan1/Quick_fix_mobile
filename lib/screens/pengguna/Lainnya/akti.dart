import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AktivitasPage extends StatelessWidget {
  const AktivitasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        title: const Text(
          "Aktivitas",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            icon: CupertinoIcons.clock,
            title: "Login Berhasil",
            subtitle: "Anda login pada 20 November 2025, 10:21",
          ),
          _buildCard(
            icon: CupertinoIcons.cart,
            title: "Melakukan Pemesanan",
            subtitle: "Pemesanan servis AC - 19 November 2025",
          ),
          _buildCard(
            icon: CupertinoIcons.creditcard,
            title: "Pembayaran Berhasil",
            subtitle: "Transaksi #INV-009812 - 18 November 2025",
          ),
          _buildCard(
            icon: CupertinoIcons.doc_text_search,
            title: "Melihat Riwayat Pemesanan",
            subtitle: "18 November 2025",
          ),
          _buildCard(
            icon: CupertinoIcons.arrow_2_circlepath,
            title: "Perubahan Profil",
            subtitle: "Anda memperbarui nama dan email",
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF0C4481), size: 30),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
