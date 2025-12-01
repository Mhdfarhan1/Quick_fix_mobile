import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/base_url.dart';
import 'dart:convert';
import '../../../services/api_service.dart';


class DetailPesananPage extends StatefulWidget {
  final Map<String, dynamic> order;
  const DetailPesananPage({super.key, required this.order});

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  String? selectedReason;
  bool _loadingAccept = false;
  final TextEditingController otherReasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        title: const Text("Detail Pekerjaan", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildDetail("Judul Pesanan", widget.order["nama_keahlian"]),
            _buildDetail("Nama Pelanggan", widget.order["nama_pelanggan"]),
            _buildDetail("Alamat", widget.order["alamat_lengkap"]),
            _buildDetail("Jam Booking", widget.order["jam_booking"]),
            _buildDetail("Tanggal", widget.order["tanggal_booking"]),
            _buildDetail("Deskripsi", widget.order["keluhan"]),
            _buildDetail("Harga", widget.order["harga"].toString()),
            _buildDetail("Nomor HP", widget.order["no_hp"] ?? "-"),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showRejectDialog(),
                    child: const Text("Tolak Pesanan", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC33),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _loadingAccept ? null : () => _acceptOrder(),
                    child: _loadingAccept
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text("Terima Pesanan", style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ===============================
  //   FUNGSI TERIMA PESANAN
  // ===============================
  Future<void> _acceptOrder() async {
    setState(() => _loadingAccept = true);

    final orderId = widget.order["id_pemesanan"];

    print("=== MENERIMA PESANAN ===");
    print("ID Pesanan: $orderId");

    try {
      String? token = await ApiService.storage.read(key: "token");

      final response = await http.post(
        Uri.parse("${BaseUrl.api}/pemesanan/$orderId/terima"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        // LOG STATUS
        print("=== PESANAN DITERIMA BERHASIL ===");
        print("Status pekerjaan terbaru: ${result['data']['status_pekerjaan']}");

        if (!mounted) return;
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pesanan berhasil diterima!")),
        );
      } else {
        print("=== GAGAL MENERIMA PESANAN ===");
        print("Response Body: ${response.body}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menerima pesanan: ${response.body}")),
        );
      }
    } catch (e) {
      print("=== ERROR TERIMA PESANAN ===");
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    if (mounted) setState(() => _loadingAccept = false);
  }

  Widget _buildDetail(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 3),
          Text(value?.toString() ?? "-", style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // ===============================
  //   DIALOG TOLAK PESANAN
  // ===============================
  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Alasan Menolak Pesanan"),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile(
                        title: const Text("Terlalu jauh"),
                        value: "Terlalu jauh",
                        groupValue: selectedReason,
                        onChanged: (v) => setStateDialog(() => selectedReason = v),
                      ),
                      RadioListTile(
                        title: const Text("Tidak sesuai keahlian"),
                        value: "Tidak sesuai keahlian",
                        groupValue: selectedReason,
                        onChanged: (v) => setStateDialog(() => selectedReason = v),
                      ),
                      RadioListTile(
                        title: const Text("Sudah ada jadwal lain"),
                        value: "Sudah ada jadwal lain",
                        groupValue: selectedReason,
                        onChanged: (v) => setStateDialog(() => selectedReason = v),
                      ),
                      RadioListTile(
                        title: const Text("Lainnya"),
                        value: "Lainnya",
                        groupValue: selectedReason,
                        onChanged: (v) => setStateDialog(() => selectedReason = v),
                      ),

                      if (selectedReason == "Lainnya")
                        TextField(
                          controller: otherReasonController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Masukkan alasan lainnya...",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Batal"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    Navigator.pop(context); // tutup dialog
                    Navigator.pop(context); // balik ke halaman pesanan

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pesanan telah ditolak.")),
                    );
                  },
                  child: const Text("Tolak", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
