import 'package:flutter/material.dart';
import '../teknisi/profile/profile_teknisi_page.dart';

class TeknisiScreen extends StatefulWidget {
  const TeknisiScreen({super.key});

  @override
  State<TeknisiScreen> createState() => _TeknisiScreenState();
}

class _TeknisiScreenState extends State<TeknisiScreen> {
  String selectedKategori = "Semua";

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.dashboard, "label": "Semua"},
    {"icon": Icons.build, "label": "Bangunan"},
    {"icon": Icons.opacity, "label": "Pipa"},
    {"icon": Icons.electrical_services, "label": "Listrik"},
    {"icon": Icons.chair, "label": "Furniture"},
    {"icon": Icons.ac_unit, "label": "Service AC"},
  ];

  final List<Map<String, dynamic>> teknisiList = [
    {
      "nama": "Budi Santoso",
      "foto": "https://randomuser.me/api/portraits/men/32.jpg",
      "kategori": "Bangunan",
      "jarak": "3.2 km",
      "rating": 4.8,
      "desc": "Spesialis renovasi rumah & perbaikan dinding."
    },
    {
      "nama": "Rudi Hartono",
      "foto": "https://randomuser.me/api/portraits/men/45.jpg",
      "kategori": "Listrik",
      "jarak": "5.0 km",
      "rating": 4.6,
      "desc": "Teknisi listrik rumah & kantor berpengalaman."
    },
    {
      "nama": "Agus Setiawan",
      "foto": "https://randomuser.me/api/portraits/men/50.jpg",
      "kategori": "Pipa",
      "jarak": "2.5 km",
      "rating": 4.7,
      "desc": "Ahli perbaikan pipa bocor & instalasi baru."
    },
    {
      "nama": "Dedi Firmansyah",
      "foto": "https://randomuser.me/api/portraits/men/60.jpg",
      "kategori": "Furniture",
      "jarak": "6.1 km",
      "rating": 4.9,
      "desc": "Custom furniture kayu & perbaikan perabot."
    },
    {
      "nama": "Yudi Kurniawan",
      "foto": "https://randomuser.me/api/portraits/men/70.jpg",
      "kategori": "Service AC",
      "jarak": "4.0 km",
      "rating": 4.5,
      "desc": "Service & cuci AC, garansi pekerjaan rapi."
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTeknisi = selectedKategori == "Semua"
        ? teknisiList
        : teknisiList
        .where((t) => t["kategori"] == selectedKategori)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF0C4481),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Daftar Teknisi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Pilihan Kategori (Horizontal)
          Container(
            height: 100,
            margin: const EdgeInsets.only(top: 12),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedKategori == cat["label"];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedKategori = cat["label"];
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0C4481)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          cat["icon"] as IconData,
                          size: 28,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF0C4481),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat["label"] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF0C4481)
                              : Colors.black87,
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),

          // List Teknisi
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: filteredTeknisi.length,
              itemBuilder: (context, index) {
                final t = filteredTeknisi[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileTeknisiPage(
                          nama: t["nama"],
                          jarak: t["jarak"],
                          rating: t["rating"].toString(),
                          bidang: t["bidang"]!,
                          harga: double.parse(t["harga"]!),
                          deskripsi: t["desc"],
                          gambar: t["foto"],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            t["foto"],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Teks bagian kanan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama + Rating
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      t["nama"],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 18),
                                  const SizedBox(width: 2),
                                  Text(t["rating"].toString()),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Jarak
                              Text(
                                t["jarak"],
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 4),

                              // Deskripsi
                              Text(
                                t["desc"],
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
