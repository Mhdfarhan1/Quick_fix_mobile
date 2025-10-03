import 'package:flutter/material.dart';

class ProfilePenggunaPage extends StatelessWidget {
  const ProfilePenggunaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profilku", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              color: const Color(0xFF0C4381),
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Foto Profil
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(0xFFFFCC33),
                      child: Text(
                        "MS",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info User
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Muhammad Syifa",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "muhammadsyi@gmail.com",
                            style: TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            "+62 1234 5673",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // Tombol Edit
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF0C4381)),
                      onPressed: () {
                        // edit profil
                      },
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section Preferensi
            sectionTitle("Preferensi"),
            profileMenu("Keamanan akun", Icons.lock_outline),
            profileMenu("Alamat tersimpan", Icons.bookmark_outline),

            const SizedBox(height: 20),

            // Section Aktivitas
            sectionTitle("Aktivitas di QuickFix"),
            profileMenu("Aktivitas", Icons.history),

            const SizedBox(height: 20),

            // Section Lainnya
            sectionTitle("Lainnya"),
            profileMenu("Bantuan & laporan", Icons.help_outline),
            profileMenu("Kebijakan Privasi", Icons.privacy_tip_outlined),
            profileMenu("Atur akun", Icons.settings),

            const SizedBox(height: 20),

            // Tombol Logout
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Keluar",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget judul section
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }

  // Widget item menu profil
  Widget profileMenu(String title, IconData icon, {String? trailing}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFFFFFF)),
        title: Text(title),
        trailing: trailing != null
            ? Text(trailing, style: const TextStyle(color: Color(0xFF0C4381)))
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  // Alert konfirmasi keluar
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          "Konfirmasi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: const Text(
          "Apakah kamu yakin ingin keluar dari akun?",
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Batal",
              style: TextStyle(
                color: Color(0xFF0C4481), // biru tua untuk teks Batal
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C4481), // warna #0C4481
              foregroundColor: Colors.white, // teks putih
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx); // tutup dialog
              Navigator.pop(context); // keluar halaman
              // bisa tambahkan logika logout (hapus session / pindah ke login page)
            },
            child: const Text(
              "Keluar",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
