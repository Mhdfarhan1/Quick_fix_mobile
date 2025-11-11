import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../config/base_url.dart';
import '../pengguna/pemesanan/form_pemesanan.dart';
import '../../services/keranjang_service.dart';

class HalamanLayanan extends StatefulWidget {
  final int idTeknisi;
  final int idKeahlian;
  final String nama;
  final String deskripsi;
  final double rating;
  final int harga;
  final String gambarUtama;
  final List<String> gambarLayanan;

  const HalamanLayanan({
    super.key,
    required this.idTeknisi,
    required this.idKeahlian,
    required this.nama,
    required this.deskripsi,
    required this.rating,
    required this.harga,
    required this.gambarUtama,
    required this.gambarLayanan,
  });

  @override
  State<HalamanLayanan> createState() => _HalamanLayananState();
}

class _HalamanLayananState extends State<HalamanLayanan> {
  int? idUser;

  bool loading = true;

  int? hargaMin;
  int? hargaMax;
  List<String> gambar = [];
  List<dynamic> ulasan = [];
  int garansi = 0 ;
  String lokasi = "";
  int totalPesanan = 0;

  @override
  void initState() {
    super.initState();
    loadUserSession();
    fetchDetail();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadUserSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  idUser = prefs.getInt("id_user");
  print("🔎 Loaded id_user from prefs: $idUser");
  setState(() {}); // ✅ penting
}

  Future<void> fetchDetail() async {
    final url = Uri.parse(
        "${BaseUrl.api}/layanan-detail?id_teknisi=${widget.idTeknisi}&id_keahlian=${widget.idKeahlian}");
        print("🔎 URL dipanggil: $url");

        print("🖼️ Data gambar dari API: $gambar");


    try {
      final res = await http.get(url).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        if (!mounted) return;

        setState(() {
          hargaMin = int.tryParse(body["harga_min"].toString()) ?? 0;
          hargaMax = int.tryParse(body["harga_max"].toString()) ?? 0;
          gambar = List<String>.from(body["gambar"]);
          ulasan = body["ulasan"];
          garansi = body["garansi"] ?? 0;
          lokasi = body["lokasi"];
          totalPesanan = body["total_pesanan"];
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      print("Fetch Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      bottomNavigationBar: _bottomButton(),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER GAMBAR
                  Stack(
                    children: [
                      Image.network(
                        "${BaseUrl.storage}/${(gambar.isNotEmpty ? gambar.first : 'gambar_layanan/default_layanan.jpg')}",
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          height: 240,
                          child: const Center(child: Icon(Icons.broken_image)),
                        ),
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

                  // CARD INFO
                  _headerInfo(),

                  // SPESIFIKASI
                  _spesifikasiSection(),

                  // ✅ Ulasan
                  _ulasanHeader(),
                  _ulasanList(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _bottomButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          // 🛒 Tombol Keranjang
          Expanded(
            flex: 1,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (idUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("⚠️ Anda belum login")),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Menambahkan ke keranjang...")),
                );

                bool success = await KeranjangService().tambahKeranjang(
                  idTeknisi: widget.idTeknisi,
                  idKeahlian: widget.idKeahlian,
                  harga: hargaMin ?? 0,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? "✅ Berhasil ditambahkan ke keranjang"
                        : "❌ Gagal menambahkan ke keranjang"),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              label: const Text(''),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 🟡 Tombol Pesan Sekarang
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () {
                if (idUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("⚠️ Anda belum login")),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormPemesanan(
                      idPelanggan: idUser!,
                      idTeknisi: widget.idTeknisi,
                      idKeahlian: widget.idKeahlian,
                      namaTeknisi: widget.nama,
                      namaKeahlian: widget.deskripsi,
                      harga: hargaMin ?? 0,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Pesan Sekarang",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[800],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.deskripsi,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 6),
          Text(widget.nama,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              Text(widget.rating.toString(),
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 6),
              Text("$totalPesanan+ Pesanan",
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Rp ${hargaMin} - ${hargaMax}",
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text("Garansi $garansi hari",
              style: const TextStyle(color: Colors.white70)),
          Text(lokasi,
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _spesifikasiSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Spesifikasi Layanan",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: gambar.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "${BaseUrl.storage}/${gambar[index]}",
                    width: 220,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
        ],
      ),
    );
  }

  Widget _ulasanHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber),
          Text(" • Ulasan Pelanggan",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _ulasanList() {
    if (ulasan.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Belum ada ulasan."),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ulasan.length,
      itemBuilder: (context, index) {
        final u = ulasan[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(u["nama"]),
          subtitle: Text(u["komentar"]),
        );
      },
    );
  }

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
}
