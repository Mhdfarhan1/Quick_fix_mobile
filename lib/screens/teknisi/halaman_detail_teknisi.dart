import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HalamanDetailTeknisi extends StatelessWidget {
  final String nama;
  final String deskripsi;
  final double rating;
  final String harga;
  final String gambarUtama;
  final List<String> gambarLayanan;

  const HalamanDetailTeknisi({
    super.key,
    required this.nama,
    required this.deskripsi,
    required this.rating,
    required this.harga,
    required this.gambarUtama,
    required this.gambarLayanan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======= Gambar Header =======
            Stack(
              children: [
                Image.asset(
                  gambarUtama,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildIconButton(context, Icons.arrow_back, () {
                          Navigator.pop(context);
                        }),
                        _buildIconButton(context, Icons.shopping_cart_outlined, () {}),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ======= Card Info Service =======
            Container(
              color: Colors.blue[800],
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    deskripsi,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text("| Kota Batam, Tiban Lama",
                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      Text(
                        harga,
                        style: GoogleFonts.poppins(
                          color: Colors.orangeAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ======= Spesifikasi Layanan =======
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Spesifikasi Layanan",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 10),

                  // Gambar Layanan
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: gambarLayanan.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            gambarLayanan[index],
                            width: 220,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 220,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    "Perbaikan segala jenis masalah AC cepat dan hasil rapi.",
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                ],
              ),
            ),

            // ======= Ulasan Pelanggan =======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("4.9 ⭐ Ulasan Pelanggan",
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  _buildReviewCard("Henry Cavill", "Hasil cepat dan memuaskan."),
                  _buildReviewCard("Tom Holland", "Harga sesuai dengan kualitas."),
                  _buildReviewCard("Timothee Chalamet", "Layanan cepat dan sangat detail."),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      // ======= Tombol Pesan Sekarang =======
      bottomNavigationBar: Container(
        color: Colors.amber[600],
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Text(
            "Pesan Sekarang",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // ===== Helper Widgets =====
  Widget _buildIconButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue[800]),
      ),
    );
  }

  Widget _buildReviewCard(String nama, String komentar) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(nama, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text(komentar, style: GoogleFonts.poppins(fontSize: 13)),
      ),
    );
  }
}
