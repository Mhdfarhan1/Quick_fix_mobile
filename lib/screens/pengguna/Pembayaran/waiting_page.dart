import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/api_service.dart';
import '../../../config/base_url.dart';
import 'struk_page.dart';


class WaitingPaymentPage extends StatefulWidget {
  final String kodePemesanan;

  const WaitingPaymentPage({super.key, required this.kodePemesanan});

  @override
  State<WaitingPaymentPage> createState() => _WaitingPaymentPageState();
}

class _WaitingPaymentPageState extends State<WaitingPaymentPage> {
  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 2), (_) {
      checkStatus();
    });
  }

  Future<void> checkStatus() async {
    final res = await http.get(Uri.parse("${BaseUrl.api}/payment/status?kode_pemesanan=${widget.kodePemesanan}"));

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);

      switch (body['payment_status']) {
        case "dibayar":
          timer.cancel();
          openStruk();
          break;
        case "expire":
        case "deny":
        case "cancel":
        case "failure":
          timer.cancel();
          showError(body['payment_status']);
          break;
      }
    }
  }

  Future<void> openStruk() async {
    // show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text("Menyiapkan struk...")
          ],
        ),
      ),
    );

    final res = await ApiService.getDetailPemesanan(widget.kodePemesanan);

    if (!mounted) return;

    Navigator.pop(context); // remove loading

    if (res['status'] == true) {
      final data = res['data'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StrukPage(
            kodePemesanan: widget.kodePemesanan,
            namaLayanan: data['nama_layanan'],
            alamat: data['alamat'],
            tanggal: data['tanggal'],
            namaTeknisi: data['nama_teknisi'] ?? '-',
            harga: data['total_harga'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memuat struk")),
      );
    }
  }

  void showError(String status) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pembayaran Gagal"),
        content: Text("Status: $status"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text("Menunggu konfirmasi Midtrans…"),
          ],
        ),
      ),
    );
  }
}
