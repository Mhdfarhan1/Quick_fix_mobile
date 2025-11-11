import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/base_url.dart';
import '../../../widgets/network_image_with_fallback.dart';
import '../tugas/detail_tugas_screen.dart';

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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? idUser = prefs.getInt('id_user');
      String? role = prefs.getString('role');

      if (idUser == null || role == null) {
        debugPrint("⚠️ User belum login, hentikan fetchPesanan()");
        return;
      }

      String url = "${BaseUrl.server}/api/get_pemesanan?";
      if (role == 'pelanggan') {
        url += "id_pelanggan=$idUser";
      } else if (role == 'teknisi') {
        url += "id_teknisi=$idUser";
      }

      debugPrint("🌐 Fetch URL: $url");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        debugPrint("🧩 Response dari API: $body");

        if (body['status'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];

          setState(() {
            ongoingOrders =
                data.where((p) => p['status'] != 'selesai').toList();
            completedOrders =
                data.where((p) => p['status'] == 'selesai').toList();
            isLoading = false;
          });
        } else {
          debugPrint("⚠️ Data tidak ditemukan di response");
          setState(() => isLoading = false);
        }
      } else {
        debugPrint("❌ HTTP Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
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
    final harga = order['harga'] ?? 0;
    final status = order['status'] ?? '-';
    final imageUrl =
        "${BaseUrl.server}/storage/profil/${order['foto_teknisi'] ?? 'default.png'}";

    Color color;
    switch (status.toLowerCase()) {
      case 'selesai':
        color = Colors.green;
        break;
      case 'diproses':
        color = Colors.blue;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(20),
        shadowColor: Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(
                  name: namaTeknisi,
                  service: namaLayanan,
                  estimate: tanggal,
                  price: "Rp $harga",
                  imageUrl: imageUrl,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      Text(
                        namaTeknisi,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        namaLayanan,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF0C4481),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            tanggal,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              alamat,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Rp $harga",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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
    );
  }
}
