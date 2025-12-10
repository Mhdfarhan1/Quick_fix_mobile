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
      _version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0C4481);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            // ============================
            // HEADER LOGO + VERSION
            // ============================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: Color(0xFF0C4481), // Biru QuickFix
                    shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      "assets/images/Logo_quickfix.png",
                      width: 85,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "QUICKFIX",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Aplikasi Teknisi Profesional\nVersi $_version",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ============================
            // SECTION DESKRIPSI
            // ============================
            _buildSectionCard(
              title: "Tentang QuickFix",
              icon: Icons.info_outline,
              content:
                  "QuickFix adalah platform yang dirancang untuk membantu teknisi mengelola tugas harian, memantau progres pekerjaan, serta berkomunikasi langsung dengan pelanggan secara efisien."
                  "\n\nAplikasi ini menyediakan alur kerja yang sederhana namun kuat untuk memastikan setiap pekerjaan dapat diselesaikan dengan cepat, tepat, dan profesional."
                  "\n\nDengan teknologi yang terintegrasi, QuickFix mendukung peningkatan produktivitas teknisi dan menghadirkan pengalaman layanan terbaik bagi pelanggan.",
            ),

            const SizedBox(height: 14),

            // ============================
            // SECTION DEVELOPER
            // ============================
            _buildSectionCard(
              title: "Dikembangkan Oleh",
              icon: Icons.engineering,
              content:
                  "Tim Teknik Rekayasa Perangkat Lunak &\nTim Teknik Rekayasa Multimedia\nBatam, Kepulauan Riau",
            ),

            const SizedBox(height: 14),

            // ============================
            // SECTION KONTAK
            // ============================
            _buildSectionCard(
              title: "Kontak Dukungan",
              icon: Icons.support_agent,
              content:
                  "Email: Support@quickfix.id\nTelepon: +62 8123456789",
            ),

            const SizedBox(height: 14),

            // ============================
            // SECTION PRIVACY / TERMS
            // ============================
            _buildSectionCard(
              title: "Privasi & Kebijakan",
              icon: Icons.privacy_tip_outlined,
              content: "Situs Resmi : www.quickfix.id\nKebijakan Privasi & Syarat Ketentuan.",
            ),

            const SizedBox(height: 14),

            // ============================
            // SECTION TECHNOLOGY
            // ============================
            _buildSectionCard(
              title: "Teknologi yang Digunakan",
              icon: Icons.code,
              content: "Flutter\nLaravel\nMySQL\nMidtrans\nNgrok\nGoogle Streetview\nGmail API",
            ),

            const SizedBox(height: 30),

            // FOOTER
            Center(
              child: Text(
                "© 2025 QuickFix. Semua hak dilindungi.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ============================
  // CUSTOM CARD SECTION
  // ============================
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0C4481), size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
