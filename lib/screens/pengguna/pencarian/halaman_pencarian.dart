import 'package:flutter/material.dart';
import '../../teknisi/halaman_detail_teknisi.dart';

class HalamanPencarian extends StatefulWidget {
  final String searchQuery;

  const HalamanPencarian({super.key, required this.searchQuery});

  @override
  State<HalamanPencarian> createState() => _HalamanPencarianState();
}

class _HalamanPencarianState extends State<HalamanPencarian> {
  String _selectedCategory = 'Semua';
  List<Map<String, String>> _filteredTeknisi = [];

  final List<String> _categories = [
    "Semua",
    "AC",
    "TV",
    "Kulkas",
    "Mesin Cuci"
  ];

  final List<Map<String, String>> teknisiList = [
    {
      "nama": "Budi Teknik",
      "keahlian": "Service AC",
      "rating": "4.8",
      "harga": "Rp 150.000",
      "image": "assets/images/AC-rusak.jpg"
    },
    {
      "nama": "Rafi Elektronik",
      "keahlian": "Service TV & Kulkas",
      "rating": "4.6",
      "harga": "Rp 200.000",
      "image": "assets/images/elektronik.jpeg"
    },
    {
      "nama": "Andi Service",
      "keahlian": "Mesin Cuci & Kulkas",
      "rating": "4.9",
      "harga": "Rp 180.000",
      "image": "assets/images/mesin_cuci.png"
    },
    {
      "nama": "Jaya AC",
      "keahlian": "Pasang & Service AC",
      "rating": "4.7",
      "harga": "Rp 120.000",
      "image": "assets/images/pasangAC.jpeg"
    },
  ];

  @override
  void initState() {
    super.initState();
    _filterTeknisi();
  }

  void _filterTeknisi() {
    setState(() {
      if (_selectedCategory == 'Semua') {
        _filteredTeknisi = List.from(teknisiList);
      } else {
        _filteredTeknisi = teknisiList.where((teknisi) {
          final keahlian = teknisi['keahlian']!.toLowerCase();
          return keahlian.contains(_selectedCategory.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFCC33);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildHeaderRow(yellow),
            const SizedBox(height: 14),
            _buildCategoryFilters(),
            const SizedBox(height: 24),
            _buildResultsList(yellow),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0C4481),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 14),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 20),
              SizedBox(width: 2),
              Text(
                "Kota Batam",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16, right: 24),
            child: IconButton(
              icon: const Icon(Icons.message_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Cari teknisi atau layanan...",
          prefixIcon: Icon(Icons.search, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(Color yellow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Hasil Pencarian",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF0C4481),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.sort, size: 18, color: Colors.white),
          label: const Text("Sort by", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: yellow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryChip(category, _selectedCategory == category);
        },
      ),
    );
  }

  Widget _buildCategoryChip(String title, bool selected) {
    return GestureDetector(
      onTap: () {
        _selectedCategory = title;
        _filterTeknisi();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1976D2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF1976D2) : Colors.grey.shade400,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(Color yellow) {
    if (_filteredTeknisi.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50),
          child: Text(
            "Tidak ada teknisi yang cocok.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _filteredTeknisi.length,
      itemBuilder: (context, index) {
        final teknisi = _filteredTeknisi[index];
        return _buildTeknisiCard(teknisi, yellow);
      },
    );
  }

  Widget _buildTeknisiCard(Map<String, String> teknisi, Color yellow) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanDetailTeknisi(
              nama: teknisi["nama"]!,
              deskripsi: teknisi["keahlian"]!,
              rating: double.parse(teknisi["rating"]!),
              harga: teknisi["harga"]!,
              gambarUtama: teknisi["image"]!,
              gambarLayanan: [teknisi["image"]!],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  teknisi["image"]!,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teknisi["nama"]!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0C4481),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teknisi["keahlian"]!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          teknisi["rating"]!,
                          style:
                              const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          teknisi["harga"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HalamanDetailTeknisi(
                                  nama: teknisi["nama"]!,
                                  deskripsi: teknisi["keahlian"]!,
                                  rating: double.parse(teknisi["rating"]!),
                                  harga: teknisi["harga"]!,
                                  gambarUtama: teknisi["image"]!,
                                  gambarLayanan: [teknisi["image"]!],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 0,
                          ),
                          child: const Text(
                            "BOOK",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
