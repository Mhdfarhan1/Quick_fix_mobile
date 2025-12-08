import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../chat/chat_page.dart';
import '../../../services/api_service.dart';
import '../../../config/base_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int get step => _getStep(widget.order['status']);

  int _getStep(String status) {
    switch (status) {
      case 'menunggu_diterima':
        return 0;
      case 'dijadwalkan':
        return 1;
      case 'menuju_lokasi':
        return 2;
      case 'sedang_bekerja':
        return 3;
      case 'selesai':
        return 4;
      case 'dibatalkan':
        return 5;
      default:
        return 0;
    }
  }

  Color getStatusColor() {
    switch (widget.order['status']) {
      case 'menunggu_diterima':
        return Colors.orange;
      case 'dijadwalkan':
        return Colors.blue;
      case 'menuju_lokasi':
        return Colors.blueAccent;
      case 'sedang_bekerja':
        return Colors.green;
      case 'selesai':
        return Colors.black;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
      print("=== ORDER DETAIL DATA ===");
      print(widget.order);
      print("API dipanggil: $BaseUrl/get_pemesanan_by_user");

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildStepItem(String label, int index) {
    bool active = index <= step;
    return Column(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: active ? getStatusColor() : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: active ? Colors.black : Colors.black54,
          ),
        ),
      ],
    );
  }

  Future<int?> startChat(int idTeknisi) async {
    final response = await ApiService.post(
      endpoint: "chat/start",
      data: {
        "id_teknisi": idTeknisi,
      },
    );

    print("CHAT START RESPONSE: $response");

    final statusCode = response['statusCode'];
    final data = response['data'];

    if (statusCode == 200 && data != null) {
      if (data['chat'] != null && data['chat']['id_chat'] != null) {
        return data['chat']['id_chat'];
      }

      if (data['id_chat'] != null) {
        return data['id_chat'];
      }
    }

    return null;
  }



  @override
  Widget build(BuildContext context) {
    var o = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Pesanan"),
        backgroundColor: const Color(0xFF0A4CA7),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: Colors.red,        // 🔴 Warna tombol
                  side: const BorderSide(color: Colors.red), // Border merah
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Batalkan",
                  style: TextStyle(
                    color: Colors.white,              // ⚪ Teks putih
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.chat),
              onPressed: () async {
                // ambil idTeknisi
                final idTeknisiRaw = o['id_teknisi'];

                // jika null → TOLAK
                if (idTeknisiRaw == null) {
                  print("ERROR: id_teknisi NULL");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Teknisi belum ditentukan")),
                  );
                  return;
                }

                final int idTeknisi = int.tryParse(idTeknisiRaw.toString()) ?? 0;

                if (idTeknisi == 0) {
                  print("ERROR: id_teknisi bukan angka");
                  return;
                }

                // cek chat id
                final idChat = o['id_chat'] == null
                    ? null
                    : int.tryParse(o['id_chat'].toString());


                // jika chat belum ada → buat
                if (idChat == null) {
                  final newChatId = await startChat(idTeknisi);

                  if (newChatId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gagal membuat chat")),
                    );
                    return;
                  }

                  setState(() {
                    o['id_chat'] = newChatId;
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatId: newChatId,
                        idTeknisi: idTeknisi,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatId: idChat,
                        idTeknisi: idTeknisi,
                      ),
                    ),
                  );
                }
              },
            )

          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // **************** TOP ANIMATION ****************
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/images/gearsbg.jpg',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * math.pi,
                        child: child,
                      );
                    },
                    child: Image.asset('assets/images/cog.png',
                        height: 140, width: 140))
              ],
            ),

            const SizedBox(height: 20),

            // **************** STATUS ****************
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getStatusColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  o['status'].toString().replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: getStatusColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // **************** PROGRESS STEP ****************
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildStepItem("Diterima", 0),
                buildStepItem("Dijadwalkan", 1),
                buildStepItem("Menuju", 2),
                buildStepItem("Bekerja", 3),
                buildStepItem("Selesai", 4),
              ],
            ),

            const SizedBox(height: 30),

            // **************** TEKNISI CARD ****************
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(
                    "${BaseUrl.server}/storage/foto/foto_teknisi/${o['foto_teknisi'] ?? 'default.png'}"
                  ),

                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o['nama_teknisi'],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(o['nama_keahlian'],
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            buildInfoCard(
              "Informasi Pesanan",
              [
                rowItem("Kode", o['kode_pemesanan']?.toString() ?? "-"),
                rowItem("Tanggal", o['tanggal_booking']?.toString() ?? "-"),
                rowItem("Jam", o['jam_booking']?.toString() ?? "-"),
                rowItem("Harga", "Rp ${o['harga']?.toString() ?? '0'}"),
                rowItem("Keluhan", o['keluhan']?.toString() ?? "-"),

              ],
            ),

            const SizedBox(height: 20),

            buildInfoCard(
              "Alamat",
              [
                rowItem("Alamat", o['alamat_lengkap']),
                rowItem("Kota", o['kota']),
                rowItem("Provinsi", o['provinsi']),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600)),
          Flexible(
              child:
                  Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
