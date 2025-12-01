import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../config/base_url.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  List keranjang = [];
  int totalItem = 0;
  int totalHarga = 0;
  bool isLoading = true;
  


  String formatRupiah(int number) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(number);
  }


  Future<void> fetchKeranjang() async {
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idPelanggan = prefs.getInt('id_user');

    if (idPelanggan == null) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse("${BaseUrl.server}/api/keranjang?id_pelanggan=$idPelanggan");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final items = json.decode(response.body) as List<dynamic>;

        int total = 0;
        for (var item in items) {
          total += (item['harga'] as num?)?.toInt() ?? 0;
        }

        setState(() {
          keranjang = items;
          totalItem = items.length;
          totalHarga = total;
        });
      } else {
        debugPrint("Gagal memuat keranjang: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchKeranjang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Keranjang",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                totalItem.toString(),
                style: const TextStyle(
                  color: Color(0xFF004AAD),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : keranjang.isEmpty
              ? const Center(child: Text("Keranjang kosong"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: keranjang.length,
                        itemBuilder: (context, index) {
                          var item = keranjang[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.blue[900],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              title: Text(
                                item['judul'] ?? 'Layanan',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                    formatRupiah(item['harga']),
                                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                  ),
                              trailing:
                                  const Icon(Icons.chevron_right, size: 28),
                            ),
                          );
                        },
                      ),
                    ),

                    // 🔹 Bagian bawah
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF004AAD),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.radio_button_off,
                                      color: Colors.white),
                                  SizedBox(width: 6),
                                  Text("Semua",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ],
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.5),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut,
                                    )),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  formatRupiah(totalHarga),
                                  key: ValueKey<int>(totalHarga), // penting agar animasi terpicu saat berubah
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: totalHarga == 0
                                  ? null
                                  : () {
                                      // Aksi Checkout
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: totalHarga == 0
                                    ? Colors.grey
                                    : const Color(0xFFFFC107),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                "Checkout",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
