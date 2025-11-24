import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// IMPORT HALAMAN LAIN
import 'package:quick_fix/screens/teknisi/riwayat/riwayat_teknisi_page.dart';
import '../home/Home_page_teknisi.dart';
import '../profile/prof_tek.dart';
import '../lainnya/lainnya_page.dart';
import 'terima_pesanan_page.dart';
import 'detail_kerja_page.dart';
import '../kerja/menuju_kerja_page.dart';
import '../kerja/sedang_bekerja_page.dart';

// BASE URL
import 'package:quick_fix/config/base_url.dart';

class PesananTeknisiPage extends StatefulWidget {
  const PesananTeknisiPage({Key? key}) : super(key: key);

  @override
  State<PesananTeknisiPage> createState() => _PesananTeknisiPageState();
}

class _PesananTeknisiPageState extends State<PesananTeknisiPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;

  List<dynamic> pesananBaru = [];
  List<dynamic> pesananJadwal = [];
  List<dynamic> pesananBerjalan = [];

  bool loading = true;
  String token = "";

  String filterStatus = "semua";
  String filterWaktu = "semua_waktu";


  late TabController _tabController;

  Map<String, List<dynamic>> groupByTanggal(List<dynamic> data) {
    Map<String, List<dynamic>> grouped = {};

    for (var item in data) {
      String tanggal = item["tanggal_booking"] ?? "";

      if (tanggal.isEmpty) continue;

      // Format tanggal → 2025-10-23 menjadi "23 Oktober 2025"
      DateTime date = DateTime.parse(tanggal);
      String formatted = formatTanggal(date);

      if (!grouped.containsKey(formatted)) {
        grouped[formatted] = [];
      }

      grouped[formatted]!.add(item);
    }

    return grouped;
  }

  String formatTanggal(DateTime date) {
    const bulan = [
      "",
      "Januari","Februari","Maret","April","Mei","Juni",
      "Juli","Agustus","September","Oktober","November","Desember"
    ];

    return "${date.day} ${bulan[date.month]} ${date.year}";
  }


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadPesanan();
  }

  // ====================================================
  //  AMBIL TOKEN SharedPreferences
  // ====================================================
  Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";
  }

  // ====================================================
  //  LOAD PESANAN
  // ====================================================
  Future<void> loadPesanan() async {
    await loadToken();

    final baru = await fetchPesanan("${BaseUrl.api}/teknisi/pesanan/baru");
    final jadwal = await fetchPesanan("${BaseUrl.api}/teknisi/pesanan/dijadwalkan");
    final berjalan = await fetchPesanan("${BaseUrl.api}/teknisi/pesanan/berjalan");

    setState(() {
      pesananBaru = baru;
      pesananJadwal = jadwal;
      pesananBerjalan = berjalan;
      loading = false;
      
    });
  }

  // ====================================================
  //  FETCH API
  // ====================================================
  Future<List<dynamic>> fetchPesanan(String url) async {
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["data"] ?? [];
      }
    } catch (e) {
      print("Error GET pesanan: $e");
    }
    return [];
  }

  // ====================================================
  //  NAVBAR ACTION
  // ====================================================
  void _onNavTap(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeTeknisiPage()));
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const RiwayatTeknisiPage()));
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
    const blueHeader = Color(0xFF0C4481);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: blueHeader,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            padding: const EdgeInsets.only(top: 50, bottom: 14),
            child: const Center(
              child: Text(
                "Pesanan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // TAB
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: blueHeader,
              unselectedLabelColor: Colors.grey,
              indicatorColor: blueHeader,
              tabs: const [
                Tab(text: "Permintaan"),
                Tab(text: "Dijadwalkan"),
                Tab(text: "Proses")
              ],
            ),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      buildPesananList(pesananBaru, isBaru: true),
                      buildPesananJadwal(),
                      buildPesananBerjalan(),
                    ],
                  ),
          ),
        ],
      ),

      bottomNavigationBar: _buildNavBar(),
    );
  }

  // ====================================================
  //  LIST VIEW PESANAN
  // ====================================================
  Widget buildPesananList(List<dynamic> data, {required bool isBaru}) {
    if (data.isEmpty) {
      return const Center(child: Text("Tidak ada pesanan"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, i) {
        final order = data[i];

        return InkWell(
          onTap: () async {
            if (isBaru) {
              // PESANAN BARU → halaman terima pesanan
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPesananPage(order: order),
                ),
              );

              if (result == true) {
                _tabController.animateTo(1);
                loadPesanan();
              }
            } else {
              // DIJADWALKAN → halaman Mulai Kerja
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailKerjaPage(data: order),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: baseOrderCard(
            order,
            bottomContent: isBaru
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPesananPage(order: order),
                          ),
                        );

                        if (result == true) {
                          _tabController.animateTo(1);
                          loadPesanan();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C4481),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Terima Pesanan",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget buildPesananJadwal() {
    List<dynamic> filtered = filterJadwalByDate(pesananJadwal);

    if (filtered.isEmpty) {
      return const Center(child: Text("Tidak ada pesanan"));
    }

    return Column(
      children: [
        // FILTER CHIP
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              buildFilterWaktuChip("Semua", "semua_waktu"),
              const SizedBox(width: 8),
              buildFilterWaktuChip("Hari Ini", "hari_ini"),
              const SizedBox(width: 8),
              buildFilterWaktuChip("Minggu Ini", "minggu_ini"),
              const SizedBox(width: 8),
              buildFilterWaktuChip("Bulan Ini", "bulan_ini"),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (var entry in groupByTanggal(filtered).entries) ...[
                // HEADER TANGGAL
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, top: 12),
                  child: Text(
                    entry.key, // "12 Oktober 2025"
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C4481),
                    ),
                  ),
                ),

                // LIST CARD BERDASARKAN TANGGAL
                for (var item in entry.value)
                  orderJadwalCard(context,item),
              ]
            ],
          ),
        )
      ],
    );
  }


  Widget buildPesananBerjalan() {
    
    List<dynamic> filteredData = pesananBerjalan.where((item) {
      if (filterStatus == "semua") return true;
      return item["status_pekerjaan"] == filterStatus;
    }).toList();

    return Column(
      children: [
        // CHIP FILTER
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              buildFilterChip("Semua", "semua"),
              const SizedBox(width: 8),
              buildFilterChip("Menuju Lokasi", "menuju_lokasi"),
              const SizedBox(width: 8),
              buildFilterChip("Sedang Bekerja", "sedang_bekerja"),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // LIST
        Expanded(
          child: filteredData.isEmpty
              ? const Center(child: Text("Tidak ada pesanan"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredData.length,
                  itemBuilder: (context, i) {
                    final order = filteredData[i];

                    return InkWell(
                      onTap: () async {
                        final orderData = Map<String, dynamic>.from(order);

                        if (orderData["status_pekerjaan"] == "menuju_lokasi") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MenujuKerjaPage(
                                data: orderData,
                              ),
                            ),
                          );
                        } 
                        else if (orderData["status_pekerjaan"] == "sedang_bekerja") {

                          // jika token diambil dari sharedprefs
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString("token") ?? "";

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SedangBekerjaPage(
                                idPemesanan: int.parse(orderData["id_pemesanan"].toString()),
                                token: token,
                                initialData: orderData, // optional
                              ),
                            ),
                          );
                        }
                      },
                      child: baseOrderCard(
                        order,
                        bottomContent: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: order["status_pekerjaan"] == "menuju_lokasi"
                                ? Colors.orange[100]
                                : Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order["status_pekerjaan"],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        )
      ],
    );
  }

    Widget buildFilterChip(String label, String value) {
      final isActive = filterStatus == value;

      return ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (val) {
          setState(() {
            filterStatus = value;
          });
        },
        selectedColor: const Color(0xFF0C4481),
        labelStyle: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      );
    }

    Widget buildFilterWaktuChip(String label, String value) {
        final isActive = filterWaktu == value;

        return ChoiceChip(
          label: Text(label),
          selected: isActive,
          onSelected: (val) {
            setState(() {
              filterWaktu = value;
            });
          },
          selectedColor: const Color(0xFF0C4481),
          labelStyle: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontSize: 12,
          ),
        );
      }

      List<dynamic> filterJadwalByDate(List<dynamic> data) {
      DateTime now = DateTime.now();

      return data.where((item) {
        String tgl = item["tanggal_booking"] ?? "";
        if (tgl.isEmpty) return false;

        DateTime date;
        try {
          date = DateTime.parse(tgl);
        } catch (e) {
          return false;
        }

        switch (filterWaktu) {
          case "hari_ini":
            return date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;

          case "minggu_ini":
            DateTime startWeek =
                now.subtract(Duration(days: now.weekday - 1));
            DateTime endWeek =
                now.add(Duration(days: 7 - now.weekday));
            return date.isAfter(startWeek.subtract(const Duration(days: 1))) &&
                  date.isBefore(endWeek.add(const Duration(days: 1)));

          case "bulan_ini":
            return date.year == now.year &&
                  date.month == now.month;

          default:
            return true;
        }
      }).toList();
    }



  // ====================================================
  //  BOTTOM NAVBAR
  // ====================================================
  Widget _buildNavBar() {
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
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, -1))
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == _currentIndex;
          final item = items[i];

          return Expanded(
            child: InkWell(
              onTap: () => _onNavTap(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon,
                      color: active ? highlight : const Color.fromARGB(255, 255, 255, 255), size: 22),
                  const SizedBox(height: 4),
                  Text(item.label,
                      style: TextStyle(
                          fontSize: 11,
                          color: active ? highlight : Colors.grey)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget baseOrderCard(
    Map<String, dynamic> order, {
    Widget? bottomContent,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF), // biru muda
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Baris Kiri Garis & Isi ===
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GARIS KIRI
                Container(
                  width: 4,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C4481),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                const SizedBox(width: 12),

                // ISI KONTEN
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // JAM + NAMA LAYANAN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (order["jam_booking"] ?? "00:00").replaceAll(":", "."),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C4481),
                            ),
                          ),
                          Text(
                            order["nama_keahlian"] ?? "",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // NAMA PELANGGAN
                      Text(
                        order["nama_pelanggan"] ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // ALAMAT
                      Text(
                        order["alamat_lengkap"] ?? "",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            if (bottomContent != null) ...[
              const SizedBox(height: 12),
              bottomContent,
            ],
          ],
        ),
      ),
    );
  }

  // ================================
  // CARD KHUSUS PESANAN JADWAL
  // ================================
  Widget orderJadwalCard(BuildContext context, Map<String, dynamic> order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: baseOrderCard(
        order,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailKerjaPage(data: order),
            ),
          );
        },
      ),
    );
  }

}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

