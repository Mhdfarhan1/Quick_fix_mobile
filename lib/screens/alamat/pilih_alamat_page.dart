import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../config/base_url.dart';
import 'tambah_alamat_map.dart';
import '../../services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PilihAlamatPage extends StatefulWidget {
  const PilihAlamatPage({super.key});

  @override
  State<PilihAlamatPage> createState() => _PilihAlamatPageState();
}

class _PilihAlamatPageState extends State<PilihAlamatPage> {
  bool loading = true;
  List<Map<String, dynamic>> alamat = [];

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();


  @override
  void initState() {
    super.initState();
    _loadAlamat();
  }

  Future<void> _loadAlamat() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = await ApiService.storage.read(key: 'token');


    print("TOKEN: $token");


    try {
      final res = await http.get(
        Uri.parse("${BaseUrl.api}/alamat"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map && body.containsKey('data')) {
          setState(() {
            alamat = List<Map<String, dynamic>>.from(body['data']);
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Gagal ambil alamat: $e");
    }

    setState(() => loading = false);
  }

  void _pilihAlamat(Map<String, dynamic> a) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alamat_default', a['alamat_lengkap'] ?? '');
    await prefs.setInt('id_alamat_default', a['id_alamat'] ?? 0);
    Navigator.pop(context, a);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        title: const Text("Pilih Alamat"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAlamat,
              child: alamat.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 120),

                      const Icon(
                        Icons.location_off,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),

                      const Center(
                        child: Text(
                          "Belum ada alamat tersimpan",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),

                      const SizedBox(height: 30),

                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TambahAlamatMap(),
                            ),
                          );
                          _loadAlamat();
                        },
                        icon: const Icon(Icons.add_location_alt),
                        label: const Text("Tambah Alamat Baru"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: alamat.length + 1,
                      itemBuilder: (context, index) {
                        if (index == alamat.length) {
                          return ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TambahAlamatMap(),
                                ),
                              );
                              _loadAlamat();
                            },
                            icon: const Icon(Icons.add_location_alt),
                            label: const Text("Tambah Alamat Baru"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }

                        final a = alamat[index];
                        return InkWell(
                          onTap: () => _pilihAlamat(a),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: a["is_default"] == 1
                                    ? Colors.blueAccent
                                    : Colors.grey[300]!,
                                width: a["is_default"] == 1 ? 2.0 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        a["alamat_lengkap"] ?? "-",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (a["is_default"] == 1)
                                      const Icon(Icons.star,
                                          color: Colors.blueAccent),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  a["label"] ?? "Tanpa Label",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
