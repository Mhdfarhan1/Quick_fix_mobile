import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../config/base_url.dart';
import '../kerja/menuju_kerja_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailKerjaPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailKerjaPage({super.key, required this.data});

  final Color primary = const Color(0xFF0C4481);
  final Color secondary = const Color(0xFFFFCC33);

  String formatRupiah(dynamic harga) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    );
    return formatCurrency.format(double.tryParse(harga.toString()) ?? 0);
  }

  Future<void> mulaiKerja(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final url = Uri.parse(
      '${BaseUrl.api}/teknisi/pemesanan/${data['id_pemesanan']}/mulai'
    );

    final res = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(res.body);

    if (res.statusCode == 200 && body['status'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MenujuKerjaPage(data: body['data']),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Gagal memulai pekerjaan!")),
    );
  }

  Future<void> hubungiPelanggan(String phone) async {
    final url = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Detail Pekerjaan",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['nama_keahlian'],
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    /// FOTO KELUHAN
                    Container(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (data['foto_keluhan'] as List?)?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: NetworkImage(data['foto_keluhan'][index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// INFO CARD
                    _infoCard(context),

                    const SizedBox(height: 16),

                    /// JARAK & WAKTU
                    _distanceCard(),

                  ],
                ),
              ),
            ),

            /// BUTTON AREA
            _bottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowInfo("Nama", data['nama_pelanggan']),
          _rowInfo("Tanggal", data['tanggal_booking']),
          _rowInfo("Jam", data['jam_booking']),
          _rowInfo("Alamat", "${data['alamat_lengkap']}, ${data['kota']}"),
          _rowInfo("Keluhan", data['keluhan']),
          _rowInfo("Harga", formatRupiah(data['harga'])),
        ],
      ),
    );
  }

  Widget _distanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Jarak: ${data['jarak'] ?? '-'} km"),
              Text("Estimasi: ${data['estimasi_waktu'] ?? '-'} menit"),
            ],
          )
        ],
      ),
    );
  }

  Widget _bottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [

          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
              ),
              child: const Text("Batalkan"),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: ElevatedButton(
              onPressed: () => mulaiKerja(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
              ),
              child: const Text("Mulai"),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: ElevatedButton(
              onPressed: () {
                hubungiPelanggan(data['no_hp']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: secondary,
                foregroundColor: Colors.black,
              ),
              child: const Text("Hubungi"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
