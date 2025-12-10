import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../config/base_url.dart';
import '../../teknisi/halaman_layanan.dart';
import '../pemesanan/form_pemesanan.dart';
import 'package:shimmer/shimmer.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final formatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // jika kosong
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // ambil angka saja
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // jika angka kosong
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // format angka jadi rupiah
    final number = int.parse(digits);
    final newText = formatter.format(number);

    // posisi cursor
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

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

  String? selectedProvinsi;
  String? selectedKota;
  double minRating = 0.0;

  final ScrollController _scrollController = ScrollController();


  // Dummy data provinsi → kota
  final List<Map<String, dynamic>> provinsiList = [
    {"nama": "Jawa Barat", "id": 1},
    {"nama": "DKI Jakarta", "id": 2},
  ];

  final Map<int, List<Map<String, dynamic>>> kotaByProvinsi = {
    1: [
      {"nama": "Bandung", "id": 101},
      {"nama": "Bekasi", "id": 102},
    ],
    2: [
      {"nama": "Jakarta Selatan", "id": 201},
      {"nama": "Jakarta Barat", "id": 202},
    ]
  };


  int? selectedKategoriId;
  int? selectedSubKategoriId;

  TextEditingController minHargaController = TextEditingController();
  TextEditingController maxHargaController = TextEditingController();

  late TextEditingController searchController;


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
    searchController = TextEditingController(text: widget.searchQuery);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        fetchTeknisi(loadMore: true);   // ⬅️ auto load
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchKategori();
      fetchTeknisi();
    });
  }



  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  int parseRupiah(String value) {
    if (value.isEmpty) return 0;

    // Hapus semua karakter selain angka
    String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    return int.tryParse(digits) ?? 0;
  }

  void _trimListMemory() {
    if (teknisiList.length > 40) {        // simpan 40 item terakhir saja
      teknisiList.removeRange(0, teknisiList.length - 40);
    }
  }



  Future<void> fetchTeknisi({bool loadMore = false}) async {
    if (_isLoading && !loadMore) return;
    if (loadMore && !hasMore) return;

    if (!loadMore) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isLoadMore = true);
    }

    final minHarga = parseRupiah(minHargaController.text);
    final maxHarga = parseRupiah(maxHargaController.text);

    final Map<String, String> queryParams = {};

    if (searchController.text.isNotEmpty) {
      queryParams['search'] = searchController.text;
    }
    if (_selectedCategory != "Semua") queryParams['kategori'] = _selectedCategory;
    if (lokasi.isNotEmpty) queryParams['lokasi'] = lokasi;
    if (sortBy.isNotEmpty) queryParams['sort'] = sortBy;

    if (selectedKategoriId != null) queryParams['id_kategori'] = selectedKategoriId.toString();
    if (selectedSubKategoriId != null) queryParams['id_keahlian'] = selectedSubKategoriId.toString();
    if (minHarga > 0) queryParams['min_harga'] = minHarga.toString();
    if (maxHarga > 0) queryParams['max_harga'] = maxHarga.toString();

    if (selectedProvinsi != null) queryParams['provinsi'] = selectedProvinsi!;
    if (selectedKota != null) queryParams['kota'] = selectedKota!;
    if (minRating > 0) queryParams['min_rating'] = minRating.toString();

    queryParams['page'] = page.toString();
    queryParams['limit'] = '6';

    final uri = Uri.parse("${BaseUrl.api}/search-teknisi")
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List data = body["data"] ?? [];

        setState(() {
          if (!loadMore) teknisiList.clear();

          teknisiList.addAll(data);

          // ★ Cegah duplikasi
          final ids = <String>{};
          teknisiList = teknisiList.where((item) {
            final id = item["id_teknisi"].toString();
            if (ids.contains(id)) return false;
            ids.add(id);
            return true;
          }).toList();

          _trimListMemory();

          // ★ Perbaikan pagination
          if (data.length < 6) {
            hasMore = false;
          } else {
            page++;
          }
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
          kategoriList = body['data']; // isinya: id_kategori, nama_kategori
        });
      }
    } catch (e) {
      debugPrint("Error kategori: $e");
    }
  }


  Future<List<dynamic>> fetchSubKategoriRaw(int kategoriId) async {
    try {
      final response = await http.get(
        Uri.parse("${BaseUrl.api}/keahlian?kategori_id=$kategoriId"),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['data'];
      }
    } catch (e) {
      debugPrint("Error sub kategori: $e");
    }

    return [];
  }




  void resetAndFetch() {
    page = 1;
    teknisiList.clear();
    hasMore = true;

    // ❌ jangan kosongkan search!
    // if (selectedKategoriId != null || selectedSubKategoriId != null) {
    //   widget.searchQuery = '';
    // }

    fetchTeknisi();
  }



  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFCC33);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: _buildAppBar(),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildSearchBarWithFilter()),
          SliverToBoxAdapter(child: _buildHeaderRow(const Color(0xFFFFCC33))),
          
          if (_isLoading)
            SliverToBoxAdapter(child: _buildSkeletonGrid())
          else
            _buildResultsGrid(),

          // ⬅️ Loader infinite scroll
          SliverToBoxAdapter(
            child: _isLoadMore
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : SizedBox.shrink(),
          ),
        ],
      )
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
            controller: searchController,
            onChanged: (value) {
              widget.searchQuery = value;
              searchController.text = value;

              if (_debounce?.isActive ?? false) _debounce!.cancel();

              _debounce = Timer(const Duration(milliseconds: 500), () {
                resetAndFetch();
              });
            },
            onSubmitted: (value) {
              widget.searchQuery = value;

              // 🔄 Reset filter kecuali harga
              selectedKategoriId = null;
              selectedSubKategoriId = null;
              onlyOnline = false;

              resetAndFetch();
            },
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
              child: SingleChildScrollView(
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
                              selectedProvinsi = null;
                              selectedKota = null;
                              minRating = 0;
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
                        bool selected = selectedKategoriId == e['id_kategori'];
                        return ChoiceChip(
                          label: Text(e['nama_kategori']),
                          selected: selected,
                          onSelected: (_) async {
                            setModalState(() {
                              selectedKategoriId = e['id_kategori'];
                              selectedSubKategoriId = null;
                              subKategoriList = [];

                              // ⬅️ Hapus keyword pencarian
                              searchController.clear();
                              widget.searchQuery = "";
                            });

                            final data = await fetchSubKategoriRaw(e['id_kategori']);
                            setModalState(() {
                              subKategoriList = data;
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
                        bool selected = selectedSubKategoriId == e['id_keahlian'];
                        return ChoiceChip(
                          label: Text(e['nama_keahlian']),
                          selected: selected,
                          onSelected: (_) {
                            setModalState(() {
                              selectedSubKategoriId = e['id_keahlian'];

                              // ⬅️ Hapus keyword pencarian
                              searchController.clear();
                              widget.searchQuery = "";
                            });
                          },
                          selectedColor: const Color(0xFF0C4481),
                          labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    /// PROVINSI & KOTA
                    const Text("Provinsi", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedProvinsi,
                      hint: const Text("Pilih Provinsi"),
                      items: provinsiList.map<DropdownMenuItem<String>>((e) {
                        return DropdownMenuItem<String>(
                          value: e['nama'],
                          child: Text(e['nama']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          selectedProvinsi = val;
                          selectedKota = null;
                        });
                      },
                    ),

                    const SizedBox(height: 10),
                    const Text("Kota/Kabupaten", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedKota,
                      hint: const Text("Pilih Kota/Kabupaten"),
                      items: (selectedProvinsi != null
                          ? kotaByProvinsi[provinsiList.firstWhere((p) => p['nama'] == selectedProvinsi)['id']] ?? []
                          : [])
                          .map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                                value: e['nama'],
                                child: Text(e['nama']),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setModalState(() => selectedKota = val);
                      },
                    ),

                    const SizedBox(height: 16),
                    const Text("Rating Minimum", style: TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      min: 0,
                      max: 5,
                      divisions: 5,
                      value: minRating,
                      label: minRating.toString(),
                      onChanged: (val) => setModalState(() => minRating = val),
                    ),

                    const SizedBox(height: 16),

                    /// HARGA
                    const Text("Jangkauan Harga", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minHargaController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
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
                            inputFormatters: [CurrencyInputFormatter()],
                            decoration: const InputDecoration(
                              hintText: "Rp100.000",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
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

                    const SizedBox(height: 20),

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

                          // ⬅️ Pastikan keyword hilang sebelum fetch
                          searchController.clear();
                          widget.searchQuery = "";

                          resetAndFetch();
                        },
                        child: const Text("Terapkan", style: TextStyle(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
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
      ],
    );
  }

  SliverGrid _buildResultsGrid() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _buildTeknisiCard(teknisiList[index], const Color(0xFFFFCC33));
        },
        childCount: teknisiList.length,
      ),
    );
  }

  Widget _buildTeknisiCard(dynamic teknisi, Color yellow) {
    String path = teknisi['gambar']?.toString() ?? '';

    String gambarUrl;

    // Jika API sudah memberi path lengkap seperti "/storage/xxx.jpg"
    if (path.startsWith("/storage")) {
      gambarUrl = "${BaseUrl.server}$path"; 
    }
    // Jika API hanya kirim nama file: "default_layanan.jpg"
    else {
      gambarUrl = "${BaseUrl.storage}/foto/$path";
    }

    print("FINAL URL: $gambarUrl");

    print(BaseUrl.storage);
    print(gambarUrl);


    // API cuma punya 1 harga → pakai harga yang sama untuk min dan max
    int harga = parseHarga(teknisi['harga']);

    double rating = double.tryParse(teknisi["rating"].toString()) ?? 0.0;

    

    return GestureDetector(
      onTap: () async {

      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getInt("id_user");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HalamanLayanan(
            idTeknisi: int.parse(teknisi["id_teknisi"].toString()),
            idKeahlian: int.parse(teknisi["id_keahlian"].toString()),
            nama: teknisi["nama"] ?? '',
            deskripsi: teknisi["nama_keahlian"] ?? '',
            rating: rating,
            harga: harga,
            gambarUtama: gambarUrl,
            gambarLayanan: [gambarUrl],
            fotoProfile: teknisi["foto_profile"] ?? "",
            data: teknisi, // ⬅️ perbaikan penting
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
                      formatRupiah(harga),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
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

}
