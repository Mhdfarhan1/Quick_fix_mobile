import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StrukPage extends StatelessWidget {
  final String kodePemesanan;
  final String namaLayanan;
  final String alamat;
  final String tanggal;
  final String namaTeknisi;
  final int harga;

  const StrukPage({
    super.key,
    required this.kodePemesanan,
    required this.namaLayanan,
    required this.alamat,
    required this.tanggal,
    required this.namaTeknisi,
    required this.harga,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Pembayaran'),
        backgroundColor: const Color(0xFF0C4481),
        foregroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(Icons.receipt_long,
                      size: 70, color: Colors.green),
                ),
                const SizedBox(height: 16),
                _infoRow('Kode Pemesanan', kodePemesanan),
                _infoRow('Layanan', namaLayanan),
                _infoRow('Tanggal', tanggal),
                _infoRow('Alamat', alamat),
                _infoRow('Teknisi', namaTeknisi),
                _infoRow('Total Harga', 'Rp ${NumberFormat("#,###").format(harga)}'),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/dashboard', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C4481),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // warna teks putih
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
