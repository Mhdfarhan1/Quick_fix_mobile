import 'package:flutter/material.dart';
import '../../pengguna/pemesanan/form_pemesanan.dart';
import '../../chat/chat_page.dart'; // pastikan path ini benar

class ProfileTeknisiPage extends StatelessWidget {
  final String nama;
  final String jarak;
  final String rating;
  final String bidang;
  final double harga;
  final String deskripsi;
  final String gambar;

  const ProfileTeknisiPage({
    super.key,
    required this.nama,
    required this.jarak,
    required this.rating,
    required this.bidang,
    required this.harga,
    required this.deskripsi,
    required this.gambar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// =============================
            /// Banner + Foto Profil + Tombol
            /// =============================
            SizedBox(
              height: 360, // beri ruang agar elemen dalam Stack bisa diklik
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  /// Banner
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(gambar),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Tombol kembali
                  Positioned(
                    top: 20,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  /// Foto Profil + Status + Tombol chat & call
                  Positioned(
                    bottom: 0, // ubah dari -150 ke 0 agar area klik valid
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            const CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(
                                "https://i.pinimg.com/736x/36/42/f6/3642f64179d8be4b9ef4b9a89cf29010.jpg",
                              ),
                            ),
                            Positioned(
                              right: 6,
                              bottom: 10,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          nama,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0C4381),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text("Tersedia Sekarang",
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 12),

                        /// Tombol chat dan call
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            actionButton(context, Icons.chat, nama),
                            const SizedBox(width: 16),
                            actionButton(context, Icons.call, nama),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// =============================
            /// Detail Info Teknisi
            /// =============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Jarak + Rating
                  Row(
                    children: [
                      Text(jarak, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 12),
                      const Icon(Icons.star,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// Tentang Teknisi
                  Text(
                    "Tentang Teknisi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deskripsi,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  /// Sertifikasi
                  Text(
                    "Sertifikasi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        sertifikatCard("Sertifikat Kualitas Tukang", "BNSP, 2023"),
                        sertifikatCard("Sertifikat Manajemen Proyek", "LPJK, 2022"),
                        sertifikatCard("Sertifikat Keselamatan Kerja", "Kemenaker, 2021"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// Ulasan
                  Text(
                    "Ulasan Pelanggan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  reviewTile("Henry Cavill",
                      "Hasil renovasinya rapi dan sesuai harapan. Komunikasi enak dari awal sampai akhir."),
                  reviewTile("Tom Holland",
                      "Pengerjaan cepat dan detail. Sangat puas dengan hasil akhirnya."),
                  reviewTile("Timothée Chalamet",
                      "Profesional dan bisa dipercaya. Rumah lama kami jadi terlihat baru!"),
                  const SizedBox(height: 30),

                  /// Tombol Book Now
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC33),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                     onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: const Text(
                            "Konfirmasi Booking",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: const Text("Apakah kamu yakin ingin booking teknisi ini?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0C4381),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);

                                // Pindah ke halaman BookingPage
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormPemesananPage(
                                      namaTeknisi: nama,
                                      fotoTeknisi:gambar,
                                      bidang: bidang,
                                      harga: harga,
                                    ),
                                  ),
                                );
                              },
                              child: const Text("Ya, Booking"),
                            ),
                          ],
                        ),
                      );
                    },

                      child: const Text(
                        "Book Now",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ======================================
  /// Tombol Chat & Call (sudah bisa diklik)
  /// ======================================
  static Widget actionButton(
      BuildContext context, IconData icon, String namaTeknisi) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (icon == Icons.chat) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  namaTeknisi: namaTeknisi,
                  fotoTeknisi:
                      "https://i.pinimg.com/736x/36/42/f6/3642f64179d8be4b9ef4b9a89cf29010.jpg",
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Memanggil $namaTeknisi...")),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC33),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.black),
        ),
      ),
    );
  }

  /// Sertifikat
  static Widget sertifikatCard(String title, String subtitle) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF0C4381).withOpacity(0.05),
        border: Border.all(color: const Color(0xFF0C4381)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.workspace_premium,
              color: Color(0xFF0C4381), size: 40),
          const SizedBox(height: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /// Ulasan
  static Widget reviewTile(String nama, String ulasan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF0C4381),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(ulasan,
                    style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
