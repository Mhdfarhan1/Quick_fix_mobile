import 'package:flutter/material.dart';
import 'package:quick_fix/screens/teknisi/lainnya/lainnya_page.dart';
import 'package:quick_fix/screens/teknisi/pesan/pesan_teknisi_page.dart';
import 'package:quick_fix/screens/teknisi/profile/profile_teknisi_page.dart';
import '../home/Home_page_teknisi.dart';
import 'detail_riwayat_teknisi_page.dart';
import '../profile/prof_tek.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api_service.dart';

import '../../../config/base_url.dart';

import '../profile/prof_tek.dart';
import '../lainnya/lainnya_page.dart';

class RiwayatTeknisiPage extends StatefulWidget {
  const RiwayatTeknisiPage({Key? key}) : super(key: key);

  @override
  State<RiwayatTeknisiPage> createState() => _RiwayatTeknisiPageState();
}

class _RiwayatTeknisiPageState extends State<RiwayatTeknisiPage> {
  int _currentIndex = 2;
  String _filter = "Semua";

  final storage = FlutterSecureStorage();

  

  List<Map<String, dynamic>> _riwayat = [];

  @override
  void initState() {
    super.initState();
    loadRiwayat();
  }

  // ================================================================
  // 🔥 LOAD API RIWAYAT DARI BACKEND LARAVEL
  // ================================================================
  Future<void> loadRiwayat() async {
    try {
      final token = await ApiService.storage.read(key: 'token');
      print("TOKEN = $token"); 

      if (token == null) {
        print("⚠️ TOKEN NULL -> API tidak akan terpanggil");
        return;
      }

      final url = "${BaseUrl.server}/api/teknisi/riwayat";
      print("CALLING API => $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final body = jsonDecode(response.body);

      if (body["status"] == true) {
        setState(() {
          _riwayat = List<Map<String, dynamic>>.from(body["data"]);
        });
      } else {
        print("API status false");
      }
    } catch (e) {
      print("Error load riwayat => $e");
    }
  }

  // navbar action
  void _onNavTap(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeTeknisiPage()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const PesananTeknisiPage()));
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const TechnicianProfilePage()));
        break;
      case 4:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LainnyaPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ================================================================
    // 🔥 FILTER DATA
    // ================================================================
    String mapStatus(String txt) {
      if (txt == "Selesai") return "selesai";
      if (txt == "Dibatalkan") return "batal";
      return "";
    }

    List<Map<String, dynamic>> filteredData = _filter == "Semua"
        ? _riwayat
        : _riwayat.where((e) => e["status_pekerjaan"] == mapStatus(_filter)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ================================================================
            // 🔷 HEADER
            // ================================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Text(
                  "Riwayat Pesanan",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // ================================================================
            // 🔶 FILTER TAB
            // ================================================================
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["Semua", "Selesai", "Dibatalkan"]
                    .map((tab) => GestureDetector(
                          onTap: () => setState(() => _filter = tab),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            decoration: BoxDecoration(
                              color: _filter == tab
                                  ? const Color(0xFFD2F4F9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _filter == tab
                                      ? const Color(0xFFD2F4F9)
                                      : Colors.grey.shade400),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                  fontWeight: _filter == tab
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _filter == tab
                                      ? Colors.black
                                      : Colors.grey[700]),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),

            // ================================================================
            // 🔥 LIST RIWAYAT (HASIL API)
            // ================================================================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final item = filteredData[index];
                  final isSelesai = item["status_pekerjaan"] == "selesai";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================================================================
                        // 🔹 BAGIAN ATAS CARD
                        // ================================================================
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item["nama_pelanggan"] ?? "-",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text(item["nama_keahlian"] ?? "-",
                                        style: const TextStyle(fontSize: 14)),
                                    const SizedBox(height: 6),
                                    Text(
                                      "${item["tanggal_booking"]} | ${item["jam_booking"]}",
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isSelesai
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color:
                                            isSelesai ? Colors.green : Colors.red,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isSelesai ? "Selesai" : "Dibatalkan",
                                        style: TextStyle(
                                          color: isSelesai
                                              ? Colors.green[800]
                                              : Colors.red[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Durasi tidak tersedia",
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.black54),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // ================================================================
                        // 🔹 BAGIAN BAWAH CARD
                        // ================================================================
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Rp ${item["harga"]}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetailRiwayatTeknisiPage(data: item),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Detail Riwayat",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // ================================================================
  // 🔻 CUSTOM BOTTOM NAVBAR
  // ================================================================
  Widget _buildCustomBottomNav() {
    const highlight = Color(0xFFFFCC33);
    final items = [
      _NavItem(icon: Icons.home, label: 'Beranda'),
      _NavItem(icon: Icons.assignment, label: 'Pesanan'),
      _NavItem(icon: Icons.history, label: 'Riwayat'),
      _NavItem(icon: Icons.person, label: 'Profil'),
      _NavItem(icon: Icons.more_horiz, label: 'Lainnya'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0C4481),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: const Offset(0, -1))
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == _currentIndex;
          final item = items[i];
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onNavTap(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                decoration: BoxDecoration(
                  color:
                      active ? highlight.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: active
                            ? highlight.withOpacity(0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon,
                          color: active
                              ? highlight
                              : const Color.fromARGB(255, 255, 255, 255),
                          size: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(item.label,
                        style: TextStyle(
                            fontSize: 11,
                            color: active
                                ? highlight
                                : const Color.fromARGB(255, 255, 255, 255))),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}


class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
