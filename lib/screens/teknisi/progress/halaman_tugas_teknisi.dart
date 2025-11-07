import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/base_url.dart';

class HalamanTugasTeknisi extends StatefulWidget {
  final String token; // token dari login

  const HalamanTugasTeknisi({super.key, required this.token});

  @override
  State<HalamanTugasTeknisi> createState() => _HalamanTugasTeknisiState();
}

class _HalamanTugasTeknisiState extends State<HalamanTugasTeknisi> {
  final int idPemesanan = 9; // dummy
  final int idTeknisi = 2; // dummy
  final int idKeahlian = 2; // dummy

  List<String> buktiGambarNetwork = [];
  File? selectedImage;
  final TextEditingController deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBukti();
  }

  // ───────────── Ambil bukti pekerjaan dari API ─────────────
  Future<void> fetchBukti() async {
    try {
      final uri = Uri.parse("${BaseUrl.api}/bukti/$idTeknisi");
      final response = await http.get(uri, headers: {
        "Authorization": "Bearer ${widget.token}",
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Pastikan data adalah list
        if (data is List) {
          setState(() {
            buktiGambarNetwork =
                data.map((item) => item['url']?.toString() ?? '').where((e) => e.isNotEmpty).toList();
          });
        } else {
          // Kalau API balik object / pesan kosong
          setState(() {
            buktiGambarNetwork = [];
          });
        }
      } else {
        setState(() {
          buktiGambarNetwork = [];
        });
        print("Error fetch bukti: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Exception fetchBukti: $e");
      setState(() {
        buktiGambarNetwork = [];
      });
    }
  }

  // ───────────── Pilih gambar dari galeri ─────────────
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      setState(() {
        selectedImage = File(imagePicked.path);
      });
    }
  }

  // ───────────── Upload bukti ke API ─────────────
  Future<void> uploadBukti() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih gambar dulu")),
      );
      return;
    }

    final uri = Uri.parse("${BaseUrl.api}/bukti");
    var request = http.MultipartRequest('POST', uri);
    request.fields['id_pemesanan'] = idPemesanan.toString();
    request.fields['id_teknisi'] = idTeknisi.toString();
    request.fields['id_keahlian'] = idKeahlian.toString();
    request.fields['deskripsi'] = deskripsiController.text;
    request.headers['Authorization'] = 'Bearer ${widget.token}';

    request.files
        .add(await http.MultipartFile.fromPath('foto_bukti', selectedImage!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Upload bukti berhasil!")));
      setState(() {
        buktiGambarNetwork.add(selectedImage!.path);
        selectedImage = null;
        deskripsiController.clear();
      });
      fetchBukti();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal upload (${response.statusCode})")));
    }
  }

  // ───────────── Kirim status tugas selesai ─────────────
  Future<void> kirimSelesai() async {
    final uri = Uri.parse("${BaseUrl.api}/selesai");
    final response = await http.post(uri,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "id_pemesanan": idPemesanan.toString(),
          "status": "completed"
        });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Tugas diselesaikan ✅")));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal submit: ${response.body}")));
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        leading: BackButton(),
        backgroundColor: const Color(0xFF004AAD),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(FontAwesomeIcons.gear, size: 70, color: Color(0xFF004AAD)),
                  const SizedBox(height: 8),
                  Text("19 Sep 25 17:00", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Informasi QuickFix',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            _buildInfoRow("Masalah", "Perbaikan Lampu & AC"),
            _buildInfoRow("Waktu", "19 Sep 2025 17:00 WIB"),
            _buildInfoRow("Lokasi", "Batu Aji - 0102"),
            _buildInfoRow("Deskripsi", "Lampu & AC gedung mati total."),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: buktiGambarNetwork.map((url) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    // Tambahkan errorBuilder untuk handle 403/404
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, color: Colors.red),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                  ),
                );
              }).toList(),
            ),

            if (selectedImage != null) ...[
              const SizedBox(height: 10),
              const Text("Preview Gambar", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(selectedImage!, width: double.infinity, height: 200, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Bukti',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol Pilih Gambar
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final XFile? imagePicked = await picker.pickImage(source: ImageSource.gallery);
                    if (imagePicked != null) {
                      setState(() {
                        selectedImage = File(imagePicked.path);
                      });
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Pilih Gambar"),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AAD)),
                ),

                // Tombol Unggah & Tandai Selesai
                ElevatedButton.icon(
                  onPressed: selectedImage == null ? null : () async {
                    // Upload gambar
                    final uri = Uri.parse("${BaseUrl.api}/bukti");
                    var request = http.MultipartRequest('POST', uri);
                    request.fields['id_pemesanan'] = idPemesanan.toString();
                    request.fields['id_teknisi'] = idTeknisi.toString();
                    request.fields['id_keahlian'] = idKeahlian.toString();
                    request.fields['deskripsi'] = deskripsiController.text;
                    request.headers['Authorization'] = 'Bearer ${widget.token}';
                    request.files.add(await http.MultipartFile.fromPath('foto_bukti', selectedImage!.path));

                    var response = await request.send();

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Bukti berhasil diunggah!")),
                      );

                      // Tandai tugas selesai
                      final selesaiUri = Uri.parse("${BaseUrl.api}/selesai");
                      final selesaiResp = await http.post(selesaiUri, headers: {
                        "Authorization": "Bearer ${widget.token}",
                        "Content-Type": "application/x-www-form-urlencoded",
                      }, body: {
                        "id_pemesanan": idPemesanan.toString(),
                        "status": "completed"
                      });

                      if (selesaiResp.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Tugas berhasil diselesaikan ✅")),
                        );
                        setState(() {
                          selectedImage = null;
                          deskripsiController.clear();
                        });
                        fetchBukti(); // refresh list bukti
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gagal menandai selesai: ${selesaiResp.body}")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal upload (${response.statusCode})")),
                      );
                    }
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text("Unggah & Selesai"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),


              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => kirimSelesai(),
                child: const Text("Tandai Selesai"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
