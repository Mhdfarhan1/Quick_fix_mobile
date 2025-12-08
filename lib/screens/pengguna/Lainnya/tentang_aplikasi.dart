import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class TentangAplikasiPage extends StatefulWidget {
  const TentangAplikasiPage({super.key});

  @override
  State<TentangAplikasiPage> createState() => _TentangAplikasiPageState();
}

class _TentangAplikasiPageState extends State<TentangAplikasiPage> {
  String _version = "-";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version; // otomatis dari pubspec.yaml
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Logo dan Nama
            Center(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/Logo_quickfix.png",
                    width: 85,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "QUICKFIX",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Aplikasi Teknisi Profesional\nVersi $_version",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildDivider(),

            // Deskripsi panjang revisi
            const Text(
              "QuickFix adalah platform yang dirancang untuk membantu teknisi "
              "mengelola tugas harian, memantau progres pekerjaan, serta "
              "berkomunikasi langsung dengan pelanggan secara efisien. "
              "Aplikasi ini menyediakan alur kerja yang sederhana namun "
              "cukup kuat untuk memastikan setiap pekerjaan dapat diselesaikan "
              "dengan cepat, tepat, dan profesional. Dengan teknologi yang "
              "terintegrasi, QuickFix mendukung peningkatan produktivitas teknisi "
              "dan menghadirkan pengalaman layanan terbaik bagi pelanggan.",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),

            const SizedBox(height: 20),

            // Dikembangkan oleh
            _buildDivider(),
            const Text(
              "Dikembangkan oleh",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Tim Teknik Rekayasa Perangkat Lunak &\n"
              "Tim Teknik Rekayasa Multimedia\n"
              "Batam, Kepulauan Riau",
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 20),

            // Kontak dukungan
            _buildDivider(),
            const Text(
              "Kontak Dukungan",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Support@quickfix.id\nTelepon: +62 8123456789",
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 20),

            // Privasi
            _buildDivider(),
            const Text(
              "Kebijakan Privasi Syarat & Ketentuan",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Situs Resmi : www.quickfix.id",
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 20),

            // Teknologi yang digunakan
            _buildDivider(),
            const Text(
              "Teknologi yang Digunakan",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Flutter\n"
              "Laravel\n"
              "MySQL\n"
              "Midtrans\n"
              "Ngrok\n"
              "Google Streetview\n"
              "Gmail API",
              style: TextStyle(fontSize: 14, height: 1.4),
            ),

            const SizedBox(height: 40),

            Center(
              child: Text(
                "2025 QuickFix. Semua hak dilindungi",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 1,
      color: Colors.grey.shade300,
    );
  }
}
