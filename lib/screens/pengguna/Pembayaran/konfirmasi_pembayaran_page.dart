import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../config/base_url.dart';
import 'halaman_bayar_sekarang.dart';

class KonfirmasiPembayaranPage extends StatefulWidget {
  final String kodePemesanan;
  final String metodePembayaran;
  final int totalPembayaran;

  const KonfirmasiPembayaranPage({
    super.key,
    required this.kodePemesanan,
    required this.metodePembayaran,
    required this.totalPembayaran,
  });

  @override
  State<KonfirmasiPembayaranPage> createState() => _KonfirmasiPembayaranPageState();
}

class _KonfirmasiPembayaranPageState extends State<KonfirmasiPembayaranPage> {
  bool sending = false;

  Future<void> submitKonfirmasi() async {
    setState(() => sending = true);

    final res = await http.post(
      Uri.parse("${BaseUrl.api}/konfirmasi_pemesanan"),
      body: {
        'kode_pemesanan': widget.kodePemesanan,
      },
    );

    setState(() => sending = false);

    if (res.statusCode == 200) {
      final data = json.decode(res.body); // ✅ tambahkan ini

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi Berhasil")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HalamanBayarSekarang(
            idPemesanan: data['id_pemesanan'], // ✅ ambil dari JSON
            kodePemesanan: widget.kodePemesanan,
            total: widget.totalPembayaran,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi gagal")),
      );
    }
  }

  Future<void> bayarSekarang() async {
    final res = await http.post(
      Uri.parse("${BaseUrl.api}/midtrans/pay"),
      body: {
        'kode_pemesanan': widget.kodePemesanan,
        'total': widget.totalPembayaran.toString(),
      },
    );

    final data = json.decode(res.body);

    if (data['payment_url'] != null) {
      final uri = Uri.parse(data['payment_url']);

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka halaman pembayaran")),
        );
      }
    }
  }

  Widget _paymentInstruction() {
    if (widget.metodePembayaran == "transfer") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("💳 Transfer Bank", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 6),
          Text("Bank BCA - 1234567890"),
          Text("a.n. PT QuickFix Indonesia"),
          SizedBox(height: 6),
          Text("Pastikan transfer sesuai nominal total."),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("📱 E-Wallet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 6),
          Text("QRIS / DANA / OVO / GoPay"),
          Text("Nomor: 0812-3456-7890 a.n. QuickFix"),
          SizedBox(height: 6),
          Text("Gunakan nominal sesuai total pembayaran."),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konfirmasi Pembayaran"),
        backgroundColor: const Color(0xFF0C4481),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("✅ Pemesanan Berhasil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Kode Pesanan: ${widget.kodePemesanan}"),
                  const SizedBox(height: 6),
                  Text("Total Pembayaran: Rp ${widget.totalPembayaran}",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // INSTRUKSI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: _paymentInstruction(),
            ),

            const SizedBox(height: 24),

            // TOMBOL KONFIRMASI
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sending ? null : submitKonfirmasi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC33),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: sending
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black))
                    : const Text("KONFIRMASI PESANAN", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 12),

            // TOMBOL BAYAR SEKARANG
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: bayarSekarang,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("🔐 BAYAR SEKARANG (MIDTRANS)", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
