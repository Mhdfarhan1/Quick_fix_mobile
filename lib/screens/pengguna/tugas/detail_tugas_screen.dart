import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../chat/chat_page.dart';
import '../../../services/api_service.dart';
import '../../../config/base_url.dart';

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
  bool _isCancelling = false;

  // STATUS FUNCS
  bool isCancellable(String status) {
    final s = status.trim().toLowerCase();
    return s == 'menunggu_diterima' || s == 'dijadwalkan';
  }


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
      case 'batal':
        return 5;
      default:
        return 0;
    }
  }

  Color getStatusColor() {
    final status = widget.order['status']?.toString() ?? '';
    switch (status) {
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
      case 'batal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'batal':
        return 'Dibatalkan';
      case 'menunggu_diterima':
        return 'Menunggu Diterima';
      case 'dijadwalkan':
        return 'Dijadwalkan';
      case 'menuju_lokasi':
        return 'Menuju Lokasi';
      case 'sedang_bekerja':
        return 'Sedang Bekerja';
      case 'selesai':
        return 'Selesai';
      default:
        return status.toString().replaceAll('_', ' ');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    print("=== ORDER DETAIL DATA ===");
    print(widget.order);
    print("API dipanggil: $BaseUrl/get_pemesanan_by_user");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _cancelOrder() async {
    if (_isCancelling) return;

    print("DEBUG: _cancelOrder DIPANGGIL!");

    setState(() => _isCancelling = true);

    final o = widget.order;
    final idPemesananRaw = o['id_pemesanan'] ?? o['id'];
    final idPemesanan = int.tryParse(idPemesananRaw.toString()) ?? 0;

    if (idPemesanan == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID pesanan tidak valid")),
      );
      setState(() => _isCancelling = false);
      return;
    }

    final currentStatus = o['status']?.toString() ?? '';
    if (!isCancellable(currentStatus)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pesanan tidak dapat dibatalkan (status: $currentStatus)")),
      );
      setState(() => _isCancelling = false);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Pembatalan"),
        content: const Text("Apakah Anda yakin ingin membatalkan pesanan ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Batal")),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Ya, Batalkan")),
        ],
      ),
    );

    if (confirm != true) {
      setState(() => _isCancelling = false);
      return;
    }

    try {
      final endpoint = "/pemesanan/$idPemesanan/batalkan";
      final resp = await ApiService.post(endpoint: endpoint, data: {});
      print("CANCEL RESPONSE: $resp");

      final success = resp?['data']?['status'] == true;

      if (success) {
        print("DEBUG: STATUS UPDATE SELESAI");

        setState(() {
          o['status'] = 'batal';
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text(resp?['data']?['message'] ?? "Pesanan dibatalkan"),
                duration: const Duration(milliseconds: 800),
              ),
            )
            .closed
            .then((_) {
              print("DEBUG: NAVIGATOR POP AKAN DIJALANKAN");
              if (mounted) Navigator.pop(context, true);
            });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp?['data']?['message'] ?? "Gagal membatalkan pesanan")),
        );
      }


    } catch (e) {
      print("ERROR CANCEL: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan, coba lagi")),
      );
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }


  Widget buildStepItem(String label, int index) {
    final status = widget.order['status']?.toString() ?? '';
    bool active = index <= _getStep(status);
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
      data: {"id_teknisi": idTeknisi},
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
    final o = widget.order;
    final status = o['status']?.toString() ?? '';
    print("STATUS PEKERJAAN: $status");
    print("DEBUG STATUS RAW: '${o['status']}'");
    print("DEBUG NORMALIZED: '${o['status'].toString().trim().toLowerCase()}'");
    print("CANCELLABLE? ${isCancellable(o['status'].toString())}");


    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pesanan"),
        backgroundColor: const Color(0xFF0A4CA7),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isCancellable(o['status']?.toString() ?? '') && !_isCancelling
                    ? _cancelOrder
                    : null,

                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: isCancellable(o['status']?.toString() ?? '')
                      ? Colors.red
                      : Colors.grey.shade300,
                  side: BorderSide(
                    color: isCancellable(o['status']?.toString() ?? '')
                        ? Colors.red
                        : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isCancelling ? "Memproses..." : "Batalkan",
                  style: TextStyle(
                    color: _isCancelling
                        ? Colors.white70
                        : isCancellable(o['status']?.toString() ?? '')
                            ? Colors.white
                            : Colors.black38,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () async {
                final idTeknisiRaw = o['id_teknisi'];
                if (idTeknisiRaw == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Teknisi belum ditentukan")),
                  );
                  return;
                }

                final idTeknisi = int.tryParse(idTeknisiRaw.toString()) ?? 0;
                if (idTeknisi == 0) return;

                final idChat = o['id_chat'] == null
                    ? null
                    : int.tryParse(o['id_chat'].toString());

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
                        builder: (_) =>
                            ChatPage(chatId: newChatId, idTeknisi: idTeknisi)),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ChatPage(chatId: idChat, idTeknisi: idTeknisi)),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top animation
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
                        angle: _controller.value * 2 * math.pi, child: child);
                  },
                  child: Image.asset('assets/images/cog.png',
                      height: 140, width: 140),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getStatusColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  statusLabel(status),
                  style: TextStyle(
                      color: getStatusColor(),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Progress step
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

            // Teknisi card
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(
                      "${BaseUrl.server}/storage/foto/foto_teknisi/${o['foto_teknisi'] ?? 'default.png'}"),
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
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
