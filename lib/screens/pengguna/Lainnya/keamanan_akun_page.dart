import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KeamananAkunPage extends StatelessWidget {
  const KeamananAkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        title: const Text(
          "Keamanan Akun",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              icon: CupertinoIcons.lock,
              title: "Ganti Password",
              subtitle: "Ubah sandi akun Anda",
            ),
          ],
        ),
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
        leading: Icon(icon, color: Color(0xFF0C4481), size: 28),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
