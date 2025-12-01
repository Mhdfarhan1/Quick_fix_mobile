// sedang_bekerja_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../config/base_url.dart';

class SedangBekerjaPage extends StatefulWidget {
  final int idPemesanan;
  final String token;
  // optional: initial data like kode_pemesanan, nama_pelanggan, keluhan, dll
  final Map<String, dynamic>? initialData;

  

  const SedangBekerjaPage({
    Key? key,
    required this.idPemesanan,
    required this.token,
    this.initialData,
  }) : super(key: key);

  @override
  _SedangBekerjaPageState createState() => _SedangBekerjaPageState();
}

class _SedangBekerjaPageState extends State<SedangBekerjaPage> {
  // ganti BaseUrl sesuai IP LAN mu
  // warna sesuai permintaan
  final Color primary = const Color(0xFF0C4481);
  final Color secondary = const Color(0xFFFFCC33);

  List<File> localImages = [];
  List<String> buktiUrls = [];
  bool loading = false;
  bool uploading = false;
  bool finishing = false;
  

  Map<String, dynamic>? detail;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchDetail();
    fetchBukti();
  }

  Future fetchDetail() async {
    final url = Uri.parse("${BaseUrl.api}/pemesanan/${widget.idPemesanan}");
    final res = await http.get(url, headers: {
      "Authorization": "Bearer ${widget.token}",
      "Accept": "application/json",
    });

    print("DETAIL STATUS: ${res.statusCode}");
    print("DETAIL BODY: ${res.body}");

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      setState(() {
        detail = body["data"];
      });
    }
  }

  Future fetchBukti() async {
    setState(() { loading = true; });

    final url = Uri.parse("${BaseUrl.api}/pemesanan/${widget.idPemesanan}/bukti");
    final res = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
      'Accept': 'application/json',
    });

    print("FETCH BUKTI STATUS: ${res.statusCode}");
    print("FETCH BUKTI BODY: ${res.body}");

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);

      final List data = body['data'] ?? [];

      print("DATA BUKTI COUNT: ${data.length}");

      setState(() {
        buktiUrls = data
            .where((e) => e['url'] != null)
            .map<String>((e) => e['url'].toString())
            .toList();
      });
    }

    setState(() { loading = false; });
  }

  // pick multiple from gallery
  Future pickMultipleFromGallery() async {
    final List<XFile>? picks = await _picker.pickMultiImage(imageQuality: 80);
    if (picks == null) return;
    _addPickedFiles(picks.map((e) => File(e.path)).toList());
  }

  // pick single from camera
  Future pickFromCamera() async {
    final XFile? pick = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (pick == null) return;
    _addPickedFiles([File(pick.path)]);
  }

  void _addPickedFiles(List<File> files) {
    // validate size and type
    List<File> accepted = [];
    for (var f in files) {
      final ext = f.path.split('.').last.toLowerCase();
      final length = f.lengthSync();
      if (!(ext == 'jpg' || ext == 'jpeg' || ext == 'png')) {
        _showMessage("Format harus JPG atau PNG: ${f.path.split('/').last}");
        continue;
      }
      if (length > 5 * 1024 * 1024) {
        _showMessage("File lebih besar dari 5MB: ${f.path.split('/').last}");
        continue;
      }
      accepted.add(f);
    }

    if (accepted.isEmpty) return;

    setState(() {
      localImages.addAll(accepted);
    });
  }

  Future uploadBukti() async {
    if (localImages.isEmpty) {
      _showMessage("Pilih minimal 1 foto untuk diupload.");
      return;
    }

    final uri = Uri.parse("${BaseUrl.api}/pemesanan/${widget.idPemesanan}/upload-bukti");

    print("URL Upload => $uri");

    setState(() { uploading = true; });

    try {
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      });


      for (var f in localImages) {
        final fname = f.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto[]', // atau ganti ke 'foto' kalau backend kamu single upload
            f.path,
            filename: fname,
          )
        );
      }

      final streamedResponse = await request.send();
      final resp = await http.Response.fromStream(streamedResponse);

      print("UPLOAD RESPONSE: ${resp.statusCode}");
      print("UPLOAD BODY: ${resp.body}");

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        await fetchBukti();
        setState(() {
          localImages.clear();
        });
        _showMessage("Upload berhasil");
      } else {
        _showMessage("Upload gagal: ${resp.statusCode} - ${resp.body}");
      }
    } catch (e) {
      _showMessage("Terjadi error saat upload: $e");
    }

    setState(() { uploading = false; });
  }

  Future selesaikanPekerjaan() async {
    if (buktiUrls.isEmpty) {
      _showMessage("Upload minimal 1 foto bukti terlebih dahulu.");
      return;
    }

    setState(() { finishing = true; });

    final url = Uri.parse("${BaseUrl.api}/pemesanan/${widget.idPemesanan}/selesaikan");
    final res = await http.post(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
      'Accept': 'application/json',
    });

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['status'] == true) {
        _showMessage("Pekerjaan selesai");
        // mungkin pop atau refresh halaman sebelumnya
        Navigator.of(context).pop(true); // kembalikan true menandakan selesai
      } else {
        _showMessage(body['message'] ?? 'Gagal menyelesaikan pekerjaan');
      }
    } else {
      _showMessage("Gagal menyelesaikan pekerjaan: ${res.statusCode}");
    }

    setState(() { finishing = false; });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildHeaderCard() {
    final data = widget.initialData ?? {};
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['kode_pemesanan'] ?? "KODE - ${widget.idPemesanan}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("SEDANG BEKERJA", style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(data['nama_pelanggan'] ?? "-", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text(data['keluhan'] ?? "-", style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_month, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text("${data['tanggal_booking'] ?? '-'} ${data['jam_booking'] ?? ''}", style: TextStyle(color: Colors.grey[700])),
                const Spacer(),
                Text("Rp ${data['harga'] ?? '-'}", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    // Contoh sederhana progress; kamu bisa hitung dari step atau waktu
    double progressValue = 0.7; // contoh, bisa dinamis
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: progressValue,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(primary),
          ),
          const SizedBox(height: 8),
          Text("Teknisi sedang mengerjakan...", style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLocalPreview() {
    if (localImages.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Preview sebelum upload", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: localImages.map((f) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(f, width: 100, height: 100, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() { localImages.remove(f); });
                      },
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.close, size: 18, color: Colors.white),
                      ),
                    ),
                  )
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: uploading ? null : uploadBukti,
                icon: uploading ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2,)) : const Icon(Icons.cloud_upload),
                label: Text(uploading ? "Mengupload..." : "Upload Bukti"),
                style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () { setState(() { localImages.clear(); }); },
                child: const Text("Batal"),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildServerPreview() {
    if (loading) return const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
    if (buktiUrls.isEmpty) return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text("Belum ada foto bukti yang diupload.", style: TextStyle(color: Colors.grey[700])),
    );

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Foto bukti (server)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: buktiUrls.map((url) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canFinish = buktiUrls.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("Sedang Bekerja"),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderCard(),
            _buildProgressBar(),
            const SizedBox(height: 8),

            // Pilihan ambil foto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await pickFromCamera();
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Kamera"),
                      style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: const Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await pickMultipleFromGallery();
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Galeri"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                    ),
                  ),
                ],
              ),
            ),

            _buildLocalPreview(),
            const Divider(),
            _buildServerPreview(),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canFinish && !finishing ? selesaikanPekerjaan : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canFinish ? Color(0xFFFFCC33) : Colors.grey,
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: finishing ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text("Selesaikan Pekerjaan"),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
