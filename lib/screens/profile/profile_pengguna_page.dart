import 'package:flutter/material.dart';
import 'profile_edit_pengguna_page.dart';

class ProfilePenggunaPage extends StatefulWidget {
  const ProfilePenggunaPage({super.key});

  @override
  State<ProfilePenggunaPage> createState() => _ProfilePenggunaPageState();
}

class _ProfilePenggunaPageState extends State<ProfilePenggunaPage> {
  String currentName = "Muhammad Syifa";
  String currentEmail = "muhammadsyi@gmail.com";
  String currentPhone = "+62 1234 5673";

  // Fungsi untuk ambil inisial dari nama
  String getInisial(String nama) {
    List<String> namaSplit = nama.trim().split(' ');
    if (namaSplit.length == 1) {
      return namaSplit[0][0].toUpperCase();
    } else {
      return (namaSplit[0][0] + namaSplit[1][0]).toUpperCase();
    }
  }

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
            // ===================== HEADER PROFIL =====================
            Container(
              color: const Color(0xFF0C4381),
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // FOTO PROFIL DINAMIS
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFFFFCC33),
                      child: Text(
                        getInisial(currentName),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // INFO USER
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentEmail,
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentPhone,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    // TOMBOL EDIT PROFIL
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF0C4381)),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileEditPelangganScreen(
                              currentName: currentName,
                              currentEmail: currentEmail,
                              currentPhone: currentPhone,
                            ),
                          ),
                        );

                        // Tangkap hasil perubahan dari halaman edit
                        if (result != null && result is Map<String, String>) {
                          setState(() {
                            currentName = result['name']!;
                            currentEmail = result['email']!;
                            currentPhone = result['phone']!;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===================== SECTION PREFERENSI =====================
            sectionTitle("Preferensi"),
            profileMenu("Keamanan akun", Icons.lock_outline),
            profileMenu("Alamat tersimpan", Icons.bookmark_outline),

            const SizedBox(height: 20),

            // ===================== SECTION AKTIVITAS =====================
            sectionTitle("Aktivitas di QuickFix"),
            profileMenu("Aktivitas", Icons.history),

            const SizedBox(height: 20),

            // ===================== SECTION LAINNYA =====================
            sectionTitle("Lainnya"),
            profileMenu("Bantuan & laporan", Icons.help_outline),
            profileMenu("Kebijakan Privasi", Icons.privacy_tip_outlined),
            profileMenu("Atur akun", Icons.settings),

            const SizedBox(height: 20),

            // ===================== LOGOUT BUTTON =====================
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

  // ===================== FUNGSI TAMBAHAN =====================

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

  Widget profileMenu(String title, IconData icon, {String? trailing}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0C4381)),
        title: Text(title),
        trailing: trailing != null
            ? Text(trailing, style: const TextStyle(color: Color(0xFF0C4381)))
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

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
                color: Color(0xFF0C4481),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C4481),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              "Keluar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
