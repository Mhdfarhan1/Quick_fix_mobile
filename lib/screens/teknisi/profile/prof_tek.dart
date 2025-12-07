// lib/screens/teknisi/profile/prof_tek.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'list_ulasan_page.dart';
import 'add_service_modal.dart';
import '../../../models/review_model.dart';
// API imports (sesuaikan path jika berbeda)
import '../../../services/api_service.dart';
import '../../../config/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/teknisi_bottom_nav.dart';
import '../../../widgets/user_bottom_nav.dart';


class Service {
  int id;
  String name;
  String description;
  int? price;
  String? imageUrl;
  File? imageFile;
  int? idKeahlian;
  String? namaKeahlian;

  Service({
    required this.id,
    required this.name,
    required this.description,
    this.price,
    this.imageUrl,
    this.imageFile,
    this.idKeahlian,
    this.namaKeahlian,
  });

  String getPriceText(int? price) {
    if (price == null || price == 0) return "Harga belum diatur";
    return "Rp ${_formatCurrency(price)}";
  }


  static String _formatCurrency(int value) {
    final s = value.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (Match m) => '.');
  }
}

class ProfileTeknisiPage extends StatefulWidget {
  final bool isTechnician;
  final int? teknisiId;

  // Constructor untuk pelanggan → WAJIB ID
  const ProfileTeknisiPage({
    Key? key,
    required this.teknisiId,
    this.isTechnician = false,
  }) : super(key: key);

  // Constructor untuk teknisi → TANPA ID
  const ProfileTeknisiPage.self({
    Key? key,
  })  : teknisiId = null,
        isTechnician = true,
        super(key: key);

  @override
  State<ProfileTeknisiPage> createState() => _ProfileTeknisiPageState();
}


class _ProfileTeknisiPageState extends State<ProfileTeknisiPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 3;

  int? _idTeknisi;

  String? _tentangSaya;
  String? userRole;


  String? namaTeknisi;
  String? fotoTeknisi;
  double? ratingTeknisi;
  bool headerLoading = true;

  String? tentangSaya; // isi dari backend
List<String> _gallery = []; // berisi urls
String? _authToken;

  final ImagePicker _picker = ImagePicker();

  List<Service> _services = [];

  List<TechnicianReview> _reviews = [];
  double _ratingAvg = 0.0;

  int _nextId = 5;

  void goToMyProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final teknisiId = prefs.getInt('id_teknisi');

    if (teknisiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID teknisi tidak ditemukan!")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileTeknisiPage(
          teknisiId: teknisiId,
          isTechnician: true,
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _initData(); // ini sudah include _fetchUlasan(id)
    _tabController = TabController(length: 2, vsync: this);
    _fetchLayananFromBackend();
    if (widget.isTechnician) {
      ;
    }
  }


  Future<int?> getTeknisiIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("id_teknisi");
  }

  Future<void> _initData() async {
    print("🚀 [INIT] Mulai initData()");
    final idTeknisi = await getTeknisiIdFromPrefs();
    print("🔑 [INIT] ID Teknisi dari prefs = $idTeknisi");

    if (idTeknisi == null) {
      print("❌ ID teknisi tidak ditemukan di SharedPreferences!");
      
      return;
    }

    print("✅ ID TEKNISI TERDETEKSI: $idTeknisi");

    fetchTeknisiHeader(idTeknisi);
    _fetchUlasan(idTeknisi);
    fetchGaleri();
    _fetchLayananFromBackend(); // ini biasanya ambil id sendiri dari token
  }



  Future<void> fetchTeknisiHeader(int idTeknisi) async {
    print("📢 [HEADER] Fetch header teknisi id=$idTeknisi");

    try {
      final res = await ApiService.get("/get_teknisi?id=$idTeknisi");
      print("📥 [HEADER] Response header: $res");

      final data = res["data"];  // <-- FIX PENTING

      setState(() {
        namaTeknisi  = data["nama"];
        fotoTeknisi  = data["foto_profile"];
        ratingTeknisi = double.tryParse(data["rating_avg"].toString()) ?? 0.0;
        tentangSaya = data["deskripsi"] ?? "";
        _gallery = (data["galeri"] is List) ? List<String>.from(data["galeri"]) : [];
        headerLoading = false;

        headerLoading = false;
      });
    } catch (e) {
      print("❌ [HEADER] ERROR: $e");
      setState(() {
        headerLoading = false;
      });
    }
  }


  Future<void> _fetchUlasan(int idTeknisi) async {
    print("📢 Fetch ulasan teknisi id=$idTeknisi");

    try {
      final resp = await ApiService.getUlasanTeknisi(idTeknisi);

      if (resp['statusCode'] == 200 && resp['data']['status'] == true) {
        final data = resp['data'];

        setState(() {
          _ratingAvg = double.tryParse(data['rating_avg'].toString()) ?? 0.0;

          _reviews = (data['ulasan'] as List)
              .map((e) => TechnicianReview.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      print("❌ ERROR FETCH ULASAN: $e");
    }
  }


  Future<void> _fetchLayananFromBackend() async {
    print("DEBUG: Fetching services from backend...");

    // Ambil ID dari widget → jika null, ambil dari prefs
    final int? teknisiId = widget.teknisiId ?? await getTeknisiIdFromPrefs();

    if (teknisiId == null) {
      print("DEBUG: Tidak ada teknisiId. Tidak bisa fetch layanan.");
      return;
    }

    try {
      final resp = await ApiService.getLayananTeknisi(teknisiId);
      print("DEBUG: Fetch response: $resp");

      if (resp['statusCode'] == 200 && resp['data'] is Map) {
        final data = resp['data'];

        if (data['success'] == true && data['data'] is List) {
          final List list = data['data'];

          print("DEBUG: Found ${list.length} services");

          setState(() {
            _services = list.map((e) {
              return Service(
                id: e['id_keahlian_teknisi'] ?? e['id'] ?? 0,
                idKeahlian: e['id_keahlian'],
                name: e['nama'] ?? e['keahlian']?['nama_keahlian'] ?? 'Tidak diketahui',
                description: e['deskripsi'] ?? '',
                price: (e['harga'] is int) ? e['harga'] : int.tryParse(e['harga']?.toString() ?? '0'), // ← hanya ini
                imageUrl: _constructImageUrl(e['gambar_layanan']),
                namaKeahlian: e['keahlian']?['nama_keahlian'],
              );
            }).toList();
          });
        }
      }
    } catch (e) {
      print("DEBUG: Error fetching services: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: widget.isTechnician
      ? const TeknisiBottomNav(currentIndex: 3)
      : const UserBottomNav(selectedIndex: 0),

      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildServiceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editTentangSaya() {
    TextEditingController controller = TextEditingController(text: _tentangSaya);

    showDialog(
      context: context,
      builder: (ctxDialog) {   // SIMPAN context dialog real
        return AlertDialog(
          title: const Text("Edit Deskripsi"),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Masukkan deskripsi teknisi",
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctxDialog), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Deskripsi tidak boleh kosong")),
                  );
                  return;
                }

                Navigator.pop(ctxDialog); // Tutup dialog Edit

                // Tampilkan dialog loading, dan simpan context-nya
                late BuildContext loadingContext;

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctxLoading) {
                    loadingContext = ctxLoading;
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                final res = await ApiService.updateProfilTeknisi(
                  deskripsi: controller.text.trim(),
                );

                // Tutup loading pakai context yang BENAR
                if (mounted) Navigator.pop(loadingContext);

                if (res['statusCode'] == 200 && res['data']['status'] == true) {
                  if (mounted) {
                    setState(() {
                      _tentangSaya = controller.text.trim(); // update instan
                      headerLoading = true; // optional kalau ada loading indicator
                    });
                    if (_idTeknisi != null) await fetchTeknisiHeader(_idTeknisi!); // reload header
                  }
                }else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gagal memperbarui")),
                    );
                  }
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

    Future<void> fetchGaleri() async {
    print("--------------------------------------------------------");
    print("🎨 [GALLERY] MULAI MENGAMBIL GALERI TEKNISI...");
    print("--------------------------------------------------------");

    int? teknisiId = widget.teknisiId;

    print("📌 teknisiId dari widget = ${widget.teknisiId}");

    // Jika teknisi membuka profil sendiri, ambil id_teknisi dari prefs
    if (teknisiId == null) {
      final prefs = await SharedPreferences.getInstance();
      teknisiId = prefs.getInt("id_teknisi");
      print("🔄 teknisiId dari SharedPreferences = $teknisiId");
    }

    if (teknisiId == null) {
      print("❌ [GALLERY] GAGAL → ID teknisi tetap NULL. Tidak bisa ambil galeri.");
      return;
    }

    print("✅ [GALLERY] FINAL teknisiId = $teknisiId");
    print("🌐 Mengirim request ke API getGaleri($teknisiId)");

    final res = await ApiService.getGaleri(teknisiId);

    print("📥 Status Code = ${res['statusCode']}");
    print("📦 Response Data = ${res['data']}");

    if (res['statusCode'] == 200 && res['data']['status'] == true) {

      final List<dynamic> rawData = res['data']['data'];

      print("📸 Jumlah gambar galeri ditemukan = ${rawData.length}");

      setState(() {
        _gallery = List<String>.from(
          rawData.map((item) {
            print("🖼️ Foto galeri: ${item['gambar_galeri']}");
            return item['gambar_galeri'];
          }),
        );
      });

      print("🎉 [GALLERY] SUCCESS → Galeri berhasil dimuat.");
    } else {
      print("⚠️ [GALLERY] API mengembalikan error:");
      print("📝 Pesan: ${res['data']['message']}");
    }

    print("--------------------------------------------------------");
    print("🎨 [GALLERY] SELESAI MEMPROSES GALERI");
    print("--------------------------------------------------------");
  }








  void _editGaleriTeknisi() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    final file = File(picked.path);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final res = await ApiService.uploadGaleri(file);

    Navigator.pop(context);

    if (res['statusCode'] == 200 || res['statusCode'] == 201) {
      final data = res['data']['data'];   // <--- ambil dari 'data'

      if (data != null && data['gambar_galeri'] != null) {
        setState(() => _gallery.insert(0, data['gambar_galeri']));
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Berhasil upload galeri")));
      }
    } else {
      final err = res['data']?['message'] ?? 'Gagal upload';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    }
  }


  void _confirmDeleteGallery(int index) {
    final url = _gallery[index];
    // Jika Anda menyimpan id_galeri juga, pakai id untuk delete. Untuk contoh di atas,
    // ApiService.deleteGaleri membutuhkan id_galeri. Jadi idealnya simpan list objek {id, url}.
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text("Hapus Foto"),
        content: const Text("Yakin ingin menghapus foto ini?"),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            // contoh: jika Anda punya id, panggil delete id:
            // final idGaleri = _galleryIds[index];
            // final res = await ApiService.deleteGaleri(token!, idGaleri);
            // For demo, kita remove dari UI if success...
            // if (res['statusCode'] == 200) {
            //   setState(()=> _gallery.removeAt(index));
            //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terhapus')));
            // }
            // Jika belum menyimpan id di client, Anda perlu mengubah API response untuk mengirim id_galeri ketika fetch.
            setState(()=> _gallery.removeAt(index));
          }, child: const Text("Hapus")),
        ],
      );
    });
  }





  void _onAddServicePressed() {
    print('DEBUG: + Tambah Layanan pressed');
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka modal tambah layanan...')));
    } catch (_) {}
    _showAddServiceModal();
  }

  void _showAddServiceModal() {
    print("DEBUG: _showAddServiceModal called");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        print("DEBUG: Building AddServiceModal");
        return AddServiceModal(
          onServiceAdded: (data) {
            print("DEBUG: onServiceAdded callback triggered with data: $data");
            final imgPath = data['gambar_layanan'] as String?;
            final fullImgUrl = imgPath != null ? (BaseUrl.api.replaceAll('/api', '') + imgPath) : null;

            final newService = Service(
              id: data['id'] ?? _nextId++,
              name: data['nama'] ?? data['keahlian']?['nama_keahlian'] ?? 'Layanan Baru',
              description: data['deskripsi'] ?? "Tidak ada deskripsi",
              price: (data['harga'] is int) ? data['harga'] : int.tryParse(data['harga']?.toString() ?? '0'), // ← satu
              imageUrl: fullImgUrl,
            );


            setState(() => _services.insert(0, newService));
          },
        );
      },
    );
  }



  Widget _buildHeader() {
    if (headerLoading) {
      return Container(
        color: Color(0xFF0C4481),
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C4481),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(fotoTeknisi ??
                "https://ui-avatars.com/api/?name=${namaTeknisi ?? 'T'}"),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaTeknisi ?? "-",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: Color(0xFFFECC32), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      (ratingTeknisi ?? 0).toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF0C4481),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'Profil'),
          Tab(text: 'Layanan'),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          "Tentang Saya",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _editTentangSaya,
                child: Text(
                  tentangSaya == null || tentangSaya!.trim().isEmpty
                      ? "Tambah deskripsi..."
                      : tentangSaya!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                    fontStyle: (tentangSaya == null || tentangSaya!.trim().isEmpty)
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ),
            ),
              if (widget.isTechnician)
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: _editTentangSaya,
                ),


          ],
        ),

        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Galeri Teknisi",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (widget.isTechnician)
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: _editGaleriTeknisi,
                ),

          ],
        ),

        const SizedBox(height: 8),
        _buildGalleryGrid(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_ratingAvg.toStringAsFixed(1)} ⭐ Ulasan Pelanggan",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            // 🔗 tombol menuju halaman list ulasan
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListUlasanPage(
                    reviews: _reviews,
                    isLoading: false,
                  ),
                ),
              );
              },
            ),
          ],
        ),
          const SizedBox(height: 10),

          _reviews.isEmpty
          ? const Text("Belum ada ulasan.")
          : Column(
              children: _reviews
                  .take(3) // ⬅ hanya ambil 3 ulasan
                  .map((r) => _buildReview(r.namaPelanggan, r.komentar))
                  .toList(),
            ),
      ]),
    );
  }

  Widget _buildGalleryGrid() {
    final items = _gallery.isNotEmpty ? _gallery : List.generate(5, (i) => "https://picsum.photos/400/300?random=$i");
    return GridView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (_, i) {
        final url = items[i];
        return GestureDetector(
          onLongPress: widget.isTechnician ? () => _confirmDeleteGallery(i) : null,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildReview(String name, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CircleAvatar(radius: 20, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3")),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(text, style: const TextStyle(fontSize: 13)),
          ]),
        )
      ]),
    );
  }

  Widget _buildServiceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Daftar Layanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7),
          itemBuilder: (_, i) => _buildServiceCard(i),
        ),
        const SizedBox(height: 12),
        if (widget.isTechnician)
          Center(
            child: ElevatedButton(
              onPressed: _onAddServicePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0C4481),
                side: const BorderSide(color: Color(0xFF0C4481), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "+ Tambah Layanan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
      ]),
    );
  }

  String? _constructImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    // If path starts with /, assume it's relative to domain root
    if (path.startsWith('/')) {
      return BaseUrl.api.replaceAll('/api', '') + path;
    }
    // If just filename, assume it's in the default storage folder
    return BaseUrl.api.replaceAll('/api', '') + '/storage/keahlian_teknisi/' + path;
  }

  Widget _buildServiceCard(int index) {
    final s = _services[index];
    // print("DEBUG: Building card for ${s.name}. isTechnician: ${widget.isTechnician}");
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: s.imageFile != null
                ? Image.file(s.imageFile!, height: 90, width: double.infinity, fit: BoxFit.cover)
                : Image.network(s.imageUrl ?? "https://picsum.photos/400/300?service", height: 90, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                    return Container(height: 90, color: Colors.grey[200], child: const Icon(Icons.image_not_supported));
                  }),
          ),
          if (widget.isTechnician) ...[
            // print("DEBUG: Rendering edit/delete buttons for ${s.name}"), // Uncomment if needed, but using ...[] trick to insert log is hard.
            Positioned(
              right: 6,
              top: 6,
              child: Builder(builder: (context) {
                // print("DEBUG: Rendering buttons for ${s.name}");
                return Row(mainAxisSize: MainAxisSize.min, children: [
                Container(decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)), child: IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.white), onPressed: () => _showEditServiceModal(index))),
                const SizedBox(width: 6),
                Container(decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)), child: IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.white), onPressed: () => _confirmDeleteService(index))),
              ]);
              }),
            ),
          ],
        ]),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  s.description,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.getPriceText(s.price),
                style: const TextStyle(fontSize: 13, color: Color(0xFF0C4481), fontWeight: FontWeight.w600),
              ),
            ]),
          ),
        ),
      ]),
    );
  }



  void _showEditServiceModal(int index) {
    final service = _services[index];
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: service.name);
    final descCtrl = TextEditingController(text: service.description);
    final priceCtrl = TextEditingController(text: service.price?.toString() ?? '');
    XFile? pickedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom, left: 16, right: 16, top: 16),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 12),
                  const Text("Edit Layanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl, 
                    decoration: const InputDecoration(labelText: "Nama Layanan"), 
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Nama wajib diisi" : null
                  ),
                  const SizedBox(height: 8),
                  TextFormField(controller: descCtrl, decoration: const InputDecoration(labelText: "Deskripsi"), maxLines: 2),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: "Harga (angka)"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Harga wajib diisi";
                      if (int.tryParse(v) == null) return "Harga tidak valid";
                      if (int.parse(v) <= 0) return "Harga harus lebih dari 0";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerLeft, child: Text("Gambar Layanan", style: TextStyle(fontSize: 13, color: Colors.grey[800]))),
                  const SizedBox(height: 6),
                  Row(children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                          if (img != null) setModalState(() => pickedImage = img);
                        } on PlatformException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal akses gallery: ${e.message}")));
                        }
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Ganti Gambar"),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C4481), foregroundColor: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(pickedImage?.name ?? (service.imageFile != null ? "Gambar lokal terpasang" : (service.imageUrl ?? "Belum ada gambar")), overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 12),
                  if (pickedImage != null)
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(pickedImage!.path), height: 120, width: double.infinity, fit: BoxFit.cover))
                  else if (service.imageFile != null)
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(service.imageFile!, height: 120, width: double.infinity, fit: BoxFit.cover))
                  else if (service.imageUrl != null)
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(service.imageUrl!, height: 120, width: double.infinity, fit: BoxFit.cover)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );

                          try {
                            final resp = await ApiService.updateLayananTeknisi(
                              id: service.id,
                              nama: nameCtrl.text.trim(),
                              harga: int.parse(priceCtrl.text.trim()),
                              deskripsi: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                              gambarFile: pickedImage != null ? File(pickedImage!.path) : null,
                            );

                            Navigator.of(context).pop(); // close loading

                            if ((resp['statusCode'] == 200) ||
                                (resp['data'] is Map && (resp['data']['success'] == true || resp['statusCode'] == 200))) {
                              
                              final data = resp['data']['data'] ?? resp['data'];
                              final imgPath = data['gambar_layanan'] as String?;
                              final fullImgUrl = imgPath != null
                                  ? (BaseUrl.api.replaceAll('/api', '') + imgPath)
                                  : null;

                              setState(() {
                                _services[index] = Service(
                                  id: service.id,
                                  name: nameCtrl.text.trim(),
                                  description: descCtrl.text.trim().isEmpty ? "Tidak ada deskripsi" : descCtrl.text.trim(),
                                  price: int.parse(priceCtrl.text.trim()),
                                  imageFile: pickedImage != null ? File(pickedImage!.path) : service.imageFile,
                                  imageUrl: pickedImage == null ? (fullImgUrl ?? service.imageUrl) : null,
                                  idKeahlian: service.idKeahlian,
                                  namaKeahlian: service.namaKeahlian,
                                );
                              });

                              Navigator.of(ctx2).pop();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Layanan berhasil diperbarui")));
                            } else {
                              final msg = (resp['data'] is Map)
                                  ? (resp['data']['message'] ?? resp['data'].toString())
                                  : 'Gagal memperbarui layanan';
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $msg')));
                            }
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal update: $e')));
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C4481), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 44)),
                        child: const Text("Simpan Perubahan"),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          );
        });
      },
    );
  }

  void _confirmDeleteService(int index) {
    print("DEBUG: _confirmDeleteService called for index $index");
    final s = _services[index];
    print("DEBUG: Deleting service: ${s.name} (ID: ${s.id})");
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus layanan?"),
        content: Text('Yakin ingin menghapus "${s.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              print("DEBUG: Delete confirmed");
              Navigator.of(ctx).pop(); // tutup dialog
              showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

              try {
                final resp = await ApiService.deleteLayananTeknisi(
                  id: s.id,
                );
                print("DEBUG: Delete response: $resp");

                Navigator.of(context).pop(); // close loading

                if ((resp['statusCode'] == 200) || (resp['data'] is Map && (resp['data']['success'] == true || resp['statusCode'] == 200))) {
                  setState(() => _services.removeAt(index));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Layanan "${s.name}" berhasil dihapus')));
                } else {
                  final msg = (resp['data'] is Map) ? (resp['data']['message'] ?? resp['data'].toString()) : 'Gagal menghapus layanan';
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $msg')));
                }
              } catch (e) {
                print("DEBUG: Delete exception: $e");
                Navigator.of(context).pop(); // close loading
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
