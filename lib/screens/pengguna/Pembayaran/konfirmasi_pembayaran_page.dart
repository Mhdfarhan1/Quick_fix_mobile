import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../config/base_url.dart';
import 'payment_webview.dart';

class KonfirmasiPembayaranPage extends StatefulWidget {
  final String kodePemesanan;
  final String metodePembayaran;
  final int totalPembayaran;
  final String namaTeknisi;
  final String namaKeahlian;
  final String keluhan;
  final String tanggalBooking;
  final String jamBooking;
  final String? alamat; // ✅ alamat dari form

  const KonfirmasiPembayaranPage({
    super.key,
    required this.kodePemesanan,
    required this.metodePembayaran,
    required this.totalPembayaran,
    required this.namaTeknisi,
    required this.namaKeahlian,
    required this.keluhan,
    required this.tanggalBooking,
    required this.jamBooking,
    this.alamat,
  });

  @override
  State<KonfirmasiPembayaranPage> createState() =>
      _KonfirmasiPembayaranPageState();
}

class _KonfirmasiPembayaranPageState extends State<KonfirmasiPembayaranPage> {
  bool sending = false;

  Future<void> _bayarSekarang() async {
    try {
      setState(() => sending = true);

      final res = await http.post(
        Uri.parse("${BaseUrl.api}/payment/create"),
        body: {'kode_pemesanan': widget.kodePemesanan},
      );

      setState(() => sending = false);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == true && data['payment_url'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentWebView(
                paymentUrl: data['payment_url'],
                kodePemesanan: widget.kodePemesanan,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Link pembayaran tidak ditemukan.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal membuat pembayaran (${res.statusCode})")),
        );
      }
    } catch (e) {
      setState(() => sending = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        title: const Text("Konfirmasi Pemesanan",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const SizedBox(height: 40),
          Center(
            child: Image.asset(
              'assets/images/Logo_quickfix.png', // sesuaikan
              height: 250,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Apakah kamu yakin ingin memesan layanan ini?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 30),
          _buildDetailCard(),
        ]),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== TEKNISI =====
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.namaTeknisi,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      widget.namaKeahlian,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Text(
                "Rp ${widget.totalPembayaran}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(widget.keluhan,
              style: const TextStyle(color: Colors.black87, fontSize: 13)),

          const SizedBox(height: 16),
          const Divider(),

          // ===== ALAMAT =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.alamat ?? "Alamat belum diatur",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),

          // ===== DETAIL LAINNYA =====
          const SizedBox(height: 8),
          _infoRow("Tanggal", widget.tanggalBooking),
          _infoRow("Waktu", widget.jamBooking),
          _infoRow(
              "Metode Pembayaran", widget.metodePembayaran.toUpperCase()),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFFDC500)),
                    backgroundColor: const Color(0xFFFDC500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Batalkan",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: sending ? null : _bayarSekarang,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDC500),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: sending
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("Pesan Sekarang",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style:
                    const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
}
