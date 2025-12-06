import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../config/base_url.dart';
import '../../teknisi/halaman_layanan.dart';
import '../pemesanan/form_pemesanan.dart';
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
  double minHarga = 0;
  double maxHarga = 2000000;

  List kategoriList = [];
  List subKategoriList = [];

  int? selectedKategoriId;
  int? selectedSubKategoriId;

  TextEditingController minHargaController = TextEditingController();
  TextEditingController maxHargaController = TextEditingController();

  bool onlyOnline = false;


  bool _isLoading = false;
  bool _isLoadMore = false;
  int page = 1;
  bool hasMore = true;
  List<dynamic> teknisiList = [];
  Timer? _debounce;

  final List<String> _categories = [
    "Semua",
    "Listrik",
    "Plumbing",
    "AC",
    "Pengecatan",
    "Perbaikan Rumah",
    "Elektronik",
  ];

  String formatRupiah(int number) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(number);
  }

  int parseHarga(dynamic harga) {
    if (harga == null) return 0;

    String str = harga.toString();
    str = str.replaceAll('.', '').replaceAll(',', ''); // hapus titik/koma
    return int.tryParse(str) ?? 0;
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTeknisi();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchTeknisi({bool loadMore = false}) async {
    if (_isLoading && !loadMore) return;
    if (loadMore && !hasMore) return;

    if (!loadMore) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isLoadMore = true);
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

  Future<void> fetchKategori() async {
    try {
      final response = await http.get(Uri.parse("${BaseUrl.api}/kategori"));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        setState(() {
          kategoriList = body['data'];
        });
      }
    } catch (e) {
      debugPrint("Error kategori: $e");
    }
  }

  Future<void> fetchSubKategori(int kategoriId) async {
    try {
      final response = await http.get(Uri.parse(
          "${BaseUrl.api}/sub-kategori?kategori_id=$kategoriId"));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        setState(() {
          subKategoriList = body['data'];
        });
      }
    } catch (e) {
      debugPrint("Error sub kategori: $e");
    }
  }


  void resetAndFetch() {
    page = 1;
    teknisiList.clear();
    hasMore = true;
    fetchTeknisi();
    fetchKategori();
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
            _buildSearchBarWithFilter(),
            const SizedBox(height: 10),
            _buildHeaderRow(yellow),
            const SizedBox(height: 14),

            // hasil pencarian
            if (_isLoading)
              _buildSkeletonGrid()
            else
              _buildResultsList(yellow),

            _buildLoadMoreButton(),
          ],
        ),
      ),
    );
  }

    PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0C4481),
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Pencarian",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
    );
  }

  Widget _buildSearchBarWithFilter() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        // 🔍 Kotak pencarian
        Expanded(
          child: TextField(
            controller: TextEditingController(text: widget.searchQuery),
            onChanged: (value) => widget.searchQuery = value,
            onSubmitted: (value) => resetAndFetch(),
            decoration: InputDecoration(
              hintText: "Cari teknisi atau layanan...",
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // ⚙️ Tombol filter
        InkWell(
          onTap: () {
            _showFilterSheet(); // nanti kamu bisa isi modal filter di sini
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.filter_list, color: Colors.black87),
          ),
        ),
      ],
    ),
  );
}


  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Semua Filter",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            selectedKategoriId = null;
                            selectedSubKategoriId = null;
                            minHargaController.clear();
                            maxHargaController.clear();
                            onlyOnline = false;
                          });
                        },
                        child: const Text("Hapus Semua"),
                      )
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// KATEGORI
                  const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kategoriList.map((e) {
                      bool selected = selectedKategoriId == e['id'];

                      return ChoiceChip(
                        label: Text(e['nama']),
                        selected: selected,
                        onSelected: (_) {
                          setModalState(() {
                            selectedKategoriId = e['id'];
                            selectedSubKategoriId = null;
                            fetchSubKategori(e['id']);
                          });
                        },
                        selectedColor: const Color(0xFF0C4481),
                        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  /// SUB KATEGORI
                  const Text("Sub Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: subKategoriList.map((e) {
                      bool selected = selectedSubKategoriId == e['id'];

                      return ChoiceChip(
                        label: Text(e['nama']),
                        selected: selected,
                        onSelected: (_) {
                          setModalState(() => selectedSubKategoriId = e['id']);
                        },
                        selectedColor: const Color(0xFF0C4481),
                        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  /// HARGA
                  const Text("Jangkauan Harga", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minHargaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Rp50.000",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("-"),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: maxHargaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Rp100.000",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ONLINE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Penjual sedang online",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Switch(
                        value: onlyOnline,
                        activeColor: const Color(0xFF0C4481),
                        onChanged: (val) {
                          setModalState(() => onlyOnline = val);
                        },
                      )
                    ],
                  ),

                  const Spacer(),

                  /// BUTTON TERAPKAN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C4481),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        resetAndFetch();
                      },
                      child: const Text("Terapkan", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
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
        childAspectRatio: 0.8,
      ),
      itemCount: teknisiList.length,
      itemBuilder: (context, index) {
        return _buildTeknisiCard(teknisiList[index], yellow);
      },
    );
  }

  Widget _buildTeknisiCard(dynamic teknisi, Color yellow) {
    String gambarFile = teknisi['gambar']?.toString() ?? '';

    if (!gambarFile.contains("foto/")) {
      gambarFile = "foto/$gambarFile";
    }

    String gambarUrl = "${BaseUrl.storage}/$gambarFile";
    print(BaseUrl.storage);
    print(gambarUrl);


    int hargaMin = parseHarga(teknisi['harga_min']);
    int hargaMax = parseHarga(teknisi['harga_max']);
    double rating = double.tryParse(teknisi["rating"].toString()) ?? 0.0;

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
              rating: rating,
              harga: hargaMin,
              gambarUtama: gambarUrl,
              gambarLayanan: [gambarUrl],
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
                gambarUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, size: 40, color: Colors.white),
                  );
                },
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teknisi["nama_keahlian"] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0C4481),
                      ),
                    ),
                    // Tampilkan harga dalam format rupiah
                    Text(
                      "${formatRupiah(hargaMin)} - ${formatRupiah(hargaMax)}",
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        Text("$rating"),
                      ],
                    ),
                    const Spacer(),
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
        childAspectRatio: 0.8,
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
