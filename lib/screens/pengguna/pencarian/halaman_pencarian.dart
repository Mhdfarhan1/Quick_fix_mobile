import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../../../config/base_url.dart';
import '../../teknisi/halaman_layanan.dart';
import 'package:shimmer/shimmer.dart';

class HalamanPencarian extends StatefulWidget {
  String searchQuery;

  HalamanPencarian({super.key, required this.searchQuery});

  @override
  State<HalamanPencarian> createState() => _HalamanPencarianState();
}

class _HalamanPencarianState extends State<HalamanPencarian> {
  String _selectedCategory = 'Semua';
  String lokasi = "";
  String sortBy = "rating";

  bool _isLoading = false;
  bool _isLoadMore = false;
  int page = 1;
  bool hasMore = true;
  List<dynamic> teknisiList = [];
  Timer? _debounce; // ✅ Debounce

  final List<String> _categories = [
    "Semua",
    "Listrik",
    "Plumbing",
    "AC",
    "Pengecatan",
    "Perbaikan Rumah",
    "Elektronik",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTeknisi();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel(); // ✅ Good practice
    super.dispose();
  }

  Future<void> fetchTeknisi({bool loadMore = false}) async {
    if (_isLoading && !loadMore) return;
    if (loadMore && !hasMore) return;

    if (!loadMore) {
      setState(() {
        _isLoading = true;
      });
    } else {
      setState(() {
        _isLoadMore = true;
      });
    }

    final queryParams = <String, String>{
      if (widget.searchQuery.isNotEmpty) 'search': widget.searchQuery,
      if (_selectedCategory != "Semua") 'kategori': _selectedCategory,
      if (lokasi.isNotEmpty) 'lokasi': lokasi,
      if (sortBy.isNotEmpty) 'sort': sortBy,
      'page': page.toString(),
      'limit': '6',
    };

    final uri = Uri.parse("${BaseUrl.api}/search-teknisi")
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        setState(() {
          if (!loadMore) teknisiList.clear();

          teknisiList.addAll(body["data"] ?? []);
          hasMore = body["has_more"] ?? false;

          if (hasMore) page++;
        });
      }
    } catch (e) {
      debugPrint("$e");
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadMore = false;
      });
    }
  }

  void resetAndFetch() {
    page = 1;
    teknisiList.clear();
    hasMore = true;
    fetchTeknisi();
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
            const SizedBox(height: 10),
            _buildLokasiField(),
            const SizedBox(height: 20),
            _buildHeaderRow(yellow),
            const SizedBox(height: 14),
            _buildCategoryFilters(),
            const SizedBox(height: 24),

            // ✅ Loading Skeleton di posisi benar
            if (_isLoading) _buildSkeletonGrid()
            else _buildResultsList(yellow),

            _buildLoadMoreButton(),
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
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      textInputAction: TextInputAction.search, // ✅ Keyboard berubah
      onChanged: (value) {
        widget.searchQuery = value;
      },
      onSubmitted: (value) {
        resetAndFetch(); // ✅ Hanya saat Enter
      },
      decoration: InputDecoration(
        hintText: "Cari teknisi atau layanan...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildLokasiField() {
    return TextField(
      onChanged: (value) {
        lokasi = value;

        // ✅ Debounce lokasi
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 600), () {
          resetAndFetch();
        });
      },
      decoration: InputDecoration(
        hintText: "Filter lokasi...",
        prefixIcon: const Icon(Icons.location_city),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        filled: true,
        fillColor: Colors.white,
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
        DropdownButton(
          value: sortBy,
          items: const [
            DropdownMenuItem(value: "rating", child: Text("Rating")),
            DropdownMenuItem(value: "harga_min", child: Text("Harga Terendah")),
            DropdownMenuItem(value: "harga_max", child: Text("Harga Tertinggi")),
          ],
          onChanged: (value) {
            sortBy = value!;
            resetAndFetch();
          },
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
          return GestureDetector(
            onTap: () {
              _selectedCategory = category;
              resetAndFetch();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedCategory == category
                    ? const Color(0xFF1976D2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: _selectedCategory == category
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsList(Color yellow) {
    if (teknisiList.isEmpty && !_isLoading) {
      return const Center(child: Text("Tidak ada teknisi ditemukan."));
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72, // ✅ FIX Overflow
      ),
      itemCount: teknisiList.length,
      itemBuilder: (context, index) {
        return _buildTeknisiCard(teknisiList[index], yellow);
      },
    );
  }

  Widget _buildTeknisiCard(dynamic teknisi, Color yellow) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanLayanan(
              idTeknisi: int.parse(teknisi["id_teknisi"].toString()),
              idKeahlian: int.parse(teknisi["id_keahlian"].toString()),
              nama: teknisi["nama"] ?? '',
              deskripsi: teknisi["nama_keahlian"] ?? '',
              rating: double.tryParse(teknisi["rating"].toString()) ?? 0.0,
              harga: int.tryParse(teknisi["harga_min"].toString()) ?? 0,
              gambarUtama: "${BaseUrl.storage}/${teknisi['gambar']}",
              gambarLayanan: ["${BaseUrl.storage}/${teknisi['gambar']}"],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                "${BaseUrl.storage}/${teknisi['gambar']}",
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teknisi["nama_keahlian"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0C4481),
                      ),
                    ),

                    Text("Rp ${teknisi['harga_min']} - ${teknisi['harga_max']}"),

                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Colors.amber),
                        Text("${teknisi['rating']}"),
                      ],
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellow,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Pesan"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreButton() {
    if (!hasMore) return const SizedBox();

    return Center(
      child: ElevatedButton(
        onPressed: () => fetchTeknisi(loadMore: true),
        child: _isLoadMore
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Load More"),
      ),
    );
  }
}
