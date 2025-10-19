import 'dart:convert';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';
=======
import 'profile_edit_pengguna_page.dart';
>>>>>>> e459a035ac7639a3e57865078296c8129c442ae7

class ProfilePenggunaPage extends StatefulWidget {
  const ProfilePenggunaPage({super.key});

  @override
  State<ProfilePenggunaPage> createState() => _ProfilePenggunaPageState();
}

class _ProfilePenggunaPageState extends State<ProfilePenggunaPage> {
<<<<<<< HEAD
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Ambil data user dari SharedPreferences
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      setState(() {
        user = jsonDecode(userString);
      });
    }
  }

  // Tampilkan dialog konfirmasi logout
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Konfirmasi Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Apakah kamu yakin ingin keluar dari akun?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Batal",
              style: TextStyle(
                  color: Color(0xFF0C4481), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C4481),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx); // tutup dialog
              _logout(); // lakukan logout
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

  // Logout: hapus token & user dari SharedPreferences
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    // Navigasi ke halaman login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

=======
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

>>>>>>> e459a035ac7639a3e57865078296c8129c442ae7
  @override
  Widget build(BuildContext context) {
    final userName = user != null ? user!['nama'] ?? '' : '';
    final userEmail = user != null ? user!['email'] ?? '' : '';
    final userRole = user != null ? user!['role'] ?? '' : '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profilku", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
<<<<<<< HEAD
                      color: Colors.black.withOpacity(0.2),
=======
                      color: Colors.black.withOpacity(0.1),
>>>>>>> e459a035ac7639a3e57865078296c8129c442ae7
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
<<<<<<< HEAD
                    // Foto Profil (ambil inisial nama)
=======
                    // FOTO PROFIL DINAMIS
>>>>>>> e459a035ac7639a3e57865078296c8129c442ae7
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFFFFCC33),
                      child: Text(
<<<<<<< HEAD
                        userName.isNotEmpty
                            ? userName
                            .split(' ')
                            .map((e) => e[0])
                            .take(2)
                            .join()
                            : '',
=======
                        getInisial(currentName),
>>>>>>> e459a035ac7639a3e57865078296c8129c442ae7
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
<<<<<<< HEAD
                            userName,
=======
                            currentName,
>>>>>>> e459a035ac7639a3e57865078296c8129c442ae7
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
<<<<<<< HEAD
                            userEmail,
=======
                            currentEmail,
>>>>>>> e459a035ac7639a3e57865078296c8129c442ae7
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
<<<<<<< HEAD
                            "Role: $userRole",
=======
                            currentPhone,
>>>>>>> e459a035ac7639a3e57865078296c8129c442ae7
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    // TOMBOL EDIT PROFIL
                    IconButton(
<<<<<<< HEAD
                      icon:
                      const Icon(Icons.edit, color: Color(0xFF0C4381)),
                      onPressed: () {
                        // edit profil
=======
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
>>>>>>> e459a035ac7639a3e57865078296c8129c442ae7
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
                onPressed: _confirmLogout,
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
<<<<<<< HEAD
=======

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
>>>>>>> e459a035ac7639a3e57865078296c8129c442ae7
}
