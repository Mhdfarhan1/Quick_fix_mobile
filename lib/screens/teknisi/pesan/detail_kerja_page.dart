import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../config/base_url.dart';
import '../kerja/menuju_kerja_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'dart:convert';

class DetailKerjaPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailKerjaPage({super.key, required this.data});

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

    print("STATUS CODE: ${res.statusCode}");
    print("RESPONSE BODY: ${res.body}");

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);

      if (body['status'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MenujuKerjaPage(data: body['data']),
          ),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal memulai pekerjaan!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Pekerjaan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama: ${data['nama_pelanggan']}"),
            Text("Tanggal: ${data['tanggal_booking']}"),
            Text("Jam: ${data['jam_booking']}"),
            Text("Alamat: ${data['alamat_lengkap'] ?? '-'} , ${data['kota'] ?? '-'}"),
            Text("Keluhan: ${data['keluhan']}"),
            Text("Keahlian: ${data['nama_keahlian']}"),
            Text("Harga: ${data['harga']}"),

            const Spacer(),

            ElevatedButton(
              onPressed: () => mulaiKerja(context),
              child: const Text("Mulai"),
            )
          ],
        ),
      ),
    );
  }
}
