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
            // Header hijau
            Container(
              color: const Color(0xFF0C4381), 
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Foto Profil
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFFFCC33),
                      child: Text(
                        "MS",
                        style: TextStyle(
                          fontSize: 18,
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
                              fontSize: 16,
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
                            "+6212345673",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // Tombol Edit
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            

            const SizedBox(height: 20),

            // Section Preferensi
            sectionTitle("Preferensi"),
            profileMenu("Keamanan akun", Icons.shield),
            profileMenu("Alamat tersimpan", Icons.bookmark),

            const SizedBox(height: 20),

            // Section Aktivitas
            sectionTitle("Aktivitas di QuickFix"),
            profileMenu("Aktivitas", Icons.list),

            const SizedBox(height: 20),


            // Section Aktivitas
            sectionTitle("Lainnya"),
            profileMenu("Bantuan & laporan", Icons.help),
            profileMenu("Kebijakan Privasi", Icons.shield),
            profileMenu("Atur akun", Icons.theater_comedy_sharp),


            const SizedBox(height: 20),

            
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
        leading: Icon(icon, color: Colors.grey[700]),
        title: Text(title),
        trailing: trailing != null
            ? Text(trailing, style: const TextStyle(color: Color(0xFF0C4381)))
            : const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
