import '../../../config/base_url.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/api_service.dart';
import '../../chat/chat_page.dart';
import 'package:url_launcher/url_launcher.dart';


class DetailRiwayatTeknisiPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailRiwayatTeknisiPage({Key? key, required this.data})
      : super(key: key);

  Future<void> callCustomer(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Tidak bisa membuka aplikasi telepon';
    }
  }

  Future<int?> createOrGetChat(int idTeknisi) async {
    try {
      final token = await ApiService.storage.read(key: 'token');

      final response = await http.post(
        Uri.parse("${BaseUrl.server}/api/chat/start"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "id_teknisi": idTeknisi.toString(),
        },
      );

      final body = jsonDecode(response.body);
      if (body["status"] == true) {
        return body["chat"]["id_chat"];
      }
    } catch (e) {
      print("Error start chat => $e");
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    final bool isSelesai = data["status_pekerjaan"] == "selesai";

    const highlight = Color(0xFFFFCC33);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Detail Riwayat",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
            ),

            // Konten utama
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
                      // Bagian atas (nama + status)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data["nama_pelanggan"] ?? "-",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(data["nama_keahlian"] ?? "-",
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                isSelesai ? Icons.check_circle : Icons.cancel,
                                color:
                                    isSelesai ? Colors.green : Colors.redAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                data["status_pekerjaan"] ?? "-",
                                style: TextStyle(
                                    color: isSelesai
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Detail item (tanggal, durasi, biaya, status)
                      _buildDetailItem("Tanggal", data["tanggal_booking"]),
                      _buildDetailItem("Biaya", "Rp ${data["harga"] ?? '-'}"),
                      _buildDetailItem("Status", data["status_pekerjaan"]),

                      const SizedBox(height: 18),

                      // Catatan Pekerjaan
                      const Text(
                        "Catatan Pekerjaan",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data["catatan"] ??
                            "Pekerjaan telah diselesaikan dengan baik. Pelanggan telah memverifikasi hasil servis dan menyatakan puas.",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87, height: 1.4),
                      ),
                      const SizedBox(height: 30),

                      // Tombol aksi
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan[600],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.phone, color: Colors.white),
                              label: const Text(
                                "Hubungi Pelanggan",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                final chatId = data["id_chat"];
                                final idTeknisi = data["id_teknisi"];

                                int? finalChatId = chatId;

                                // Jika chat belum ada → buat otomatis
                                if (chatId == null) {
                                  finalChatId = await createOrGetChat(idTeknisi);

                                  if (finalChatId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Gagal membuat chat baru.")),
                                    );
                                    return;
                                  }
                                }

                                // Navigasi ke halaman chat
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
                          const SizedBox(height: 12),
                          
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
          Text(value,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}
