import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../config/base_url.dart';
import '../pengguna/pemesanan/form_pemesanan.dart';
import '../teknisi/profile/list_ulasan_page.dart';
import '../../models/review_model.dart';
import '../../services/api_service.dart';
import '../../../services/chat_service.dart';
import '../teknisi/profile/prof_tek.dart';

import '../chat/chat_page.dart';

class HalamanLayanan extends StatefulWidget {
  final int idTeknisi;
  final int idKeahlian;
  final String nama;
  final String deskripsi;
  final double rating;
  final int harga;
  final String gambarUtama;
  final String? fotoProfile;
  final List<String> gambarLayanan;
  final Map<String, dynamic> data;

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
    required this.fotoProfile,
    required this.data
  });



  @override
  State<HalamanLayanan> createState() => _HalamanLayananState();
}

class _HalamanLayananState extends State<HalamanLayanan> {
  int? idUser;

  bool loading = true;

  int? harga;
  List<String> gambar = [];
  List<dynamic> ulasan = [];
  String lokasi = "";
  String deskripsiLayanan = "";

  String formatRupiah(num number) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(number);
  }


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

    try {
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      print("📥 STATUS CODE: ${res.statusCode}");
      print("📥 RAW BODY: ${res.body}");

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        print("📌 DESKRIPSI DARI API: ${body["deskripsi"]}");
        print("📌 GAMBAR DARI API: ${body["gambar"]}");

        if (!mounted) return;

        setState(() {
          harga = int.tryParse(body["harga"].toString()) ?? 0;
          gambar = List<String>.from(body["gambar"]);
          ulasan = body["ulasan"];
          lokasi = body["lokasi"];

          deskripsiLayanan = body["deskripsi"] ?? "";
          print("📌 DESKRIPSI MASUK STATE: $deskripsiLayanan");

          loading = false;
        });
      } else {
        print("❌ ERROR DETAIL: ${res.body}");
        setState(() => loading = false);
      }
    } catch (e) {
      print("🚨 EXCEPTION DETAIL: $e");
      if (!mounted) return;
      setState(() => loading = false);
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

          // 🔵 Tombol Chat
          // 🔵 Tombol Chat
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF0C4481),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.chat, color: Colors.white),
              onPressed: () async {
                if (idUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("⚠️ Anda belum login")),
                  );
                  return;
                }

                final role = await ApiService.storage.read(key: 'role');

                final chatId = widget.data["id_chat"];
                final idTeknisi = widget.data["id_teknisi"];
                final idUserLocal = idUser; // <-- dari SharedPreferences

                int? finalChatId = chatId;

                if (finalChatId == null) {
                  finalChatId = await ChatService.createOrGetChat(
                    idTeknisi,
                    idUserLocal!,
                  );

                  if (finalChatId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gagal membuat chat baru.")),
                    );
                    return;
                  }
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(
                      chatId: finalChatId!,
                      idTeknisi: idTeknisi,
                    ),
                  ),
                );
              },
            ),
          ),


          const SizedBox(width: 12),

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
                      namaKeahlian: widget.nama,
                      harga: harga ?? 0,
                      fotoProfile: widget.fotoProfile ?? "",
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
      color: const Color(0xFF0C4481),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.deskripsi,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.nama,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              Text(
                widget.rating.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 6),
            ],
          ),
          const SizedBox(height: 6),
          // Row untuk harga dan tombol nama teknisi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatRupiah(harga ?? 0),
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () =>Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileTeknisiPage(
                      teknisiId: widget.idTeknisi,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 172, 245, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // sudut melengkung
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8), // ukuran tombol
                ),
                child: Text(
                  widget.nama,
                  style: const TextStyle(color: Color(0xFF0C4481)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
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

          // JUDUL
          Text(
            "Spesifikasi Layanan",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // ⬅️ DESKRIPSI LAYANAN DARI API
          Text(
            deskripsiLayanan,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          // GAMBAR SHORIZONTAL SCROLL
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
          const SizedBox(width: 6),

          Text(
            "Ulasan Pelanggan",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const Spacer(),

          // 👉 PANAH KE HALAMAN LIST ULASAN
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListUlasanPage(
                    reviews: ulasan.map<TechnicianReview>((u) {
                      return TechnicianReview(
                        id: u["id"] ?? 0,
                        idPemesanan: u["id_pemesanan"] ?? 0,
                        idPelanggan: u["id_pelanggan"] ?? 0,
                        idTeknisi: u["id_teknisi"] ?? 0,
                        namaPelanggan: u["nama"] ?? "-",
                        komentar: u["komentar"] ?? "",
                        rating: (u["rating"] is int)
                            ? u["rating"]
                            : int.tryParse("${u["rating"]}") ?? 0,
                        createdAt: DateTime.tryParse(u["created_at"] ?? "") ?? DateTime.now(),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            child: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.blue[800],
            ),
          ),
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

    // Ambil hanya 3 ulasan pertama
    final limitedUlasan = ulasan.take(3).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: limitedUlasan.length,
      itemBuilder: (context, index) {
        final u = limitedUlasan[index];

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
