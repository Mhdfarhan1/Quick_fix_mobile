import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/base_url.dart';
import '../../../widgets/network_image_with_fallback.dart';
import '../tugas/detail_tugas_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../tugas/detail_selesai_tugas_screen.dart';
import '../../../widgets/user_bottom_nav.dart';


class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<dynamic> ongoingOrders = [];
  List<dynamic> completedOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchPesanan();
  }

  Future<void> fetchPesanan() async {
    debugPrint("📦 [MyOrderScreen] Mulai ambil pesanan...");

    try {
      final storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

      final token = await storage.read(key: 'token');

      if (token == null) {
        debugPrint("❌ TOKEN NULL di FlutterSecureStorage");
        setState(() => isLoading = false);
        return;
      }

      debugPrint("🔐 TOKEN TERBACA: $token");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? idUser = prefs.getInt('id_user');
      String? role = prefs.getString('role');

      if (idUser == null || role == null) {
        debugPrint("⚠️ User belum login, hentikan fetchPesanan()");
        return;
      }

      final response = await http.get(
        Uri.parse("${BaseUrl.server}/api/get_pemesanan_by_user"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("📥 STATUS CODE: ${response.statusCode}");
      debugPrint("📥 BODY: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          ongoingOrders = data.where((p) => p['status'] != 'selesai').toList();
          completedOrders = data.where((p) => p['status'] == 'selesai').toList();
          isLoading = false;
        });

        return;
      }


      setState(() => isLoading = false);
    } catch (e) {
      debugPrint("💥 Error fetchPesanan: $e");
      setState(() => isLoading = false);
    }
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget orderCard(Map<String, dynamic> order) {
    final namaTeknisi = order['nama_teknisi'] ?? 'Tidak diketahui';
    final namaLayanan = order['nama_keahlian'] ?? '-';
    final tanggal = order['tanggal_booking'] ?? '-';
    final alamat = order['alamat_lengkap'] ?? '-';
    final harga = (order['harga'] is num) ? order['harga'] as num : num.tryParse('${order['harga']}') ?? 0;
    final status = (order['status'] ?? '-').toString();
    final imageUrl = order['foto_teknisi'] != null 
        ? "${BaseUrl.server}/storage/foto/foto_teknisi/${order['foto_teknisi']}"
        : "${BaseUrl.server}/storage/default.png";


    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final hargaFormatted = formatter.format(harga);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (order['status'] == 'selesai') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailSelesaiScreen(order: Map<String, dynamic>.from(order)),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(order: Map<String, dynamic>.from(order)),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // FOTO BULAT
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: NetworkImageWithFallback(
                    imageUrl: imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama teknisi
                      Text(
                        namaTeknisi,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Nama layanan
                      Text(
                        namaLayanan,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0A4CA7),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Status kecil warna hijau
                      Text(
                        status.replaceAll("_", " "),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // harga
                      Text(
                        hargaFormatted,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // Tombol status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFCB00),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Lihat Status",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget buildTab(String title, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderList(List<dynamic> list, String emptyText) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/lottie/empty.json", width: 180, height: 180),
            const SizedBox(height: 20),
            Text(
              emptyText,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchPesanan,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) => orderCard(list[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0A4CA7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    "Pesanan Saya",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 TABBAR
            Container(
              margin: const EdgeInsets.only(top: 12),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF0A4CA7),
                indicatorWeight: 3,
                tabs: [
                  buildTab("Berlangsung", ongoingOrders.length),
                  buildTab("Selesai", completedOrders.length),
                ],
              ),
            ),

            // 🔹 TABBAR VIEW
            Expanded(
              child: isLoading
                  ? Center(
                      child: Lottie.asset("assets/lottie/loading.json",
                          width: 320),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        buildOrderList(
                            ongoingOrders, "Belum ada pesanan berlangsung"),
                        buildOrderList(
                            completedOrders, "Belum ada pesanan selesai"),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNav(
        selectedIndex: 1,
      ),
    );
  }
}
