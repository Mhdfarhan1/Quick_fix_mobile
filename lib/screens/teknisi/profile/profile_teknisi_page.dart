import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import '../../../widgets/network_image_with_fallback.dart';
import '../../../config/base_url.dart';

class ProfileTeknisiPage extends StatefulWidget {
  final int teknisiId;
  const ProfileTeknisiPage({super.key, required this.teknisiId});

  @override
  State<ProfileTeknisiPage> createState() => _ProfileTeknisiPageState();
}

class _ProfileTeknisiPageState extends State<ProfileTeknisiPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? teknisi;
  List<dynamic> layananList = [];
  List<dynamic> buktiList = [];
  bool isLoading = true;
  late TabController tabController;


  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    fetchTeknisiData();
  }


  /// 🔹 Cek apakah dijalankan di Web, Emulator, atau HP Fisik (via WiFi)
  

  /// 🧩 Utility untuk memperbaiki URL agar tidak dobel
  String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.contains('storage/')) {
      return "${BaseUrl.storage}/$url";

    }
    return "${BaseUrl.storage}/$url";
  }

  Future<void> fetchTeknisiData() async {
    try {
      final teknisiRes = await http
          .get(Uri.parse('${BaseUrl.api}/get_teknisi?id=${widget.teknisiId}'));
      final layananRes = await http.get(
          Uri.parse('${BaseUrl.api}/teknisi/layanan?id_teknisi=${widget.teknisiId}'));
      final buktiRes =
          await http.get(Uri.parse('${BaseUrl.api}/bukti_pekerjaan/${widget.teknisiId}'));

      if (teknisiRes.statusCode == 200 &&
          layananRes.statusCode == 200 &&
          buktiRes.statusCode == 200) {
        setState(() {
          teknisi = jsonDecode(teknisiRes.body);
          layananList = jsonDecode(layananRes.body);
          final buktiData = jsonDecode(buktiRes.body);
          buktiList = buktiData['data'] ?? [];
          isLoading = false;
        });

        debugPrint('🖼 Foto profil: ${teknisi!['foto_profile']}');
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Error fetchTeknisiData: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (teknisi == null) {
      return const Scaffold(body: Center(child: Text('Data teknisi tidak ditemukan')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(teknisi!['nama'] ?? 'Profil Teknisi'),
        backgroundColor: Colors.blueAccent,
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Profil'),
            Tab(text: 'Layanan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          buildProfileTab(),
          buildLayananTab(),
        ],
      ),
    );
  }

  // ========================== PROFIL TAB ==========================
  Widget buildProfileTab() {
    final foto = fixImageUrl(teknisi?['foto_profile']);

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              NetworkImageWithFallback(
                imageUrl: foto,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Text(
                  teknisi!['nama'] ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(teknisi!['deskripsi'] ?? '-',
                    style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    Text(' ${teknisi!['rata_rating'] ?? 0.0}'),
                    const SizedBox(width: 16),
                    const Icon(Icons.work_outline, color: Colors.grey),
                    Text(' ${teknisi!['pengalaman']} thn pengalaman'),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Status: ${teknisi!['status']}',
                    style: TextStyle(
                        color: teknisi!['status'] == 'aktif'
                            ? Colors.green
                            : Colors.red)),
                const SizedBox(height: 16),
                Text('Keahlian: ${teknisi!['daftar_keahlian'] ?? '-'}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Galeri Teknisi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (buktiList.isEmpty)
            const Text('Belum ada bukti pekerjaan.')
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: buktiList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final bukti = buktiList[index];
                  final fullUrl = fixImageUrl(bukti['url']);

                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.black.withOpacity(0.8),
                          insetPadding: const EdgeInsets.all(10),
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.8,
                            maxScale: 4.0,
                            child: Image.network(
                              fullUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: NetworkImageWithFallback(
                        imageUrl: fullUrl,
                        fit: BoxFit.cover,
                        height: 120,
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ========================== LAYANAN TAB ==========================
  Widget buildLayananTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: layananList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 240,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final layanan = layananList[index];
            final gambarUrl = fixImageUrl(layanan['gambar']);

            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: NetworkImageWithFallback(
                      imageUrl: gambarUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(layanan['nama_keahlian'] ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(layanan['nama_kategori'] ?? '-',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            Text(' ${layanan['rating'] ?? 0}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${layanan['harga_min'] ?? 0} - ${layanan['harga_max'] ?? 0}',
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
