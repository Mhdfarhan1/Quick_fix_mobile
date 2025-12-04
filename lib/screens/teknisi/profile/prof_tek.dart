// lib/screens/teknisi/profile/prof_tek.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_fix/screens/teknisi/lainnya/lainnya_page.dart';
import 'package:quick_fix/screens/teknisi/pesan/pesan_teknisi_page.dart';
import 'package:quick_fix/screens/teknisi/riwayat/riwayat_teknisi_page.dart';
import '../home/Home_page_teknisi.dart';
import 'add_service_modal.dart';

// API imports (sesuaikan path jika berbeda)
import '../../../services/api_service.dart';
import '../../../config/base_url.dart';

class Service {
  int id;
  String name;
  String description;
  int? priceMin;
  int? priceMax;
  String? imageUrl;
  File? imageFile;
  int? idKeahlian;
  String? namaKeahlian;

  Service({
    required this.id,
    required this.name,
    required this.description,
    this.priceMin,
    this.priceMax,
    this.imageUrl,
    this.imageFile,
    this.idKeahlian,
    this.namaKeahlian,
  });

  String getPriceRangeText() {
    if (priceMin == null && priceMax == null) return "Harga belum diatur";
    final min = priceMin != null ? "Rp ${_formatCurrency(priceMin!)}" : "";
    final max = priceMax != null ? "Rp ${_formatCurrency(priceMax!)}" : "";
    if (min.isNotEmpty && max.isNotEmpty) return "$min - $max";
    return (min + max).trim();
  }

  static String _formatCurrency(int value) {
    final s = value.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (Match m) => '.');
  }
}

class TechnicianProfilePage extends StatefulWidget {
  final bool isTechnician;

  const TechnicianProfilePage({Key? key, this.isTechnician = true})
      : super(key: key);

  @override
  State<TechnicianProfilePage> createState() => _TechnicianProfilePageState();
}

class _TechnicianProfilePageState extends State<TechnicianProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 3;

  final ImagePicker _picker = ImagePicker();

  List<Service> _services = [];

  int _nextId = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Fetch layanan dari backend jika user adalah teknisi
    if (widget.isTechnician) {
      _fetchLayananFromBackend();
    }
  }

  Future<void> _fetchLayananFromBackend() async {
    print("DEBUG: Fetching services from backend...");
    try {
      final resp = await ApiService.getLayananTeknisi();
      print("DEBUG: Fetch response: $resp");
      if (resp['statusCode'] == 200 && resp['data'] is Map) {
        final data = resp['data'];
        if (data['success'] == true && data['data'] is List) {
          final List list = data['data'];
          print("DEBUG: Found ${list.length} services");
          if (list.isNotEmpty) {
            print("DEBUG: First service raw data: ${list.first}");
          }
          setState(() {
            _services = list.map((e) {
              return Service(
                id: e['id_keahlian_teknisi'] ?? e['id'] ?? 0,
                idKeahlian: e['id_keahlian'],
                name: e['nama'] ?? e['keahlian']?['nama_keahlian'] ?? 'Tidak diketahui',
                description: e['deskripsi'] ?? '',
                priceMin: (e['harga_min'] is int) ? e['harga_min'] : int.tryParse(e['harga_min']?.toString() ?? ''),
                priceMax: (e['harga_max'] is int) ? e['harga_max'] : int.tryParse(e['harga_max']?.toString() ?? ''),
                imageUrl: _constructImageUrl(e['gambar_layanan']),
                namaKeahlian: e['keahlian']?['nama_keahlian'],
              );
            }).toList();
            _nextId = (_services.isEmpty ? 5 : _services.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1);
          });
        } else {
          print("DEBUG: Data format invalid or success false");
        }
      } else {
        print("DEBUG: Status code not 200: ${resp['statusCode']}");
      }
    } catch (e) {
      print("DEBUG: Error fetching services: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memuat layanan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildCustomBottomNav(),
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
              priceMin: (data['harga_min'] is int) ? data['harga_min'] : int.tryParse(data['harga_min']?.toString() ?? ''),
              priceMax: (data['harga_max'] is int) ? data['harga_max'] : int.tryParse(data['harga_max']?.toString() ?? ''),
              imageUrl: fullImgUrl,
              // imageFile is not available here as it was uploaded, but we have the URL now
            );

            setState(() => _services.insert(0, newService));
          },
        );
      },
    );
  }



  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF0C4481),
      padding:
          const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Louis Partridge",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFFFECC32), size: 16),
                    SizedBox(width: 4),
                    Text("4.9",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
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
        const Text("Tentang Saya",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          "Hai! Aku Louis, seorang engineer yang fokus di bidang renovasi rumah. "
          "Sudah beberapa tahun aku bergelut di dunia renovasi dan membantu banyak orang "
          "meujudkan rumah impian mereka.",
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
        ),
        const SizedBox(height: 16),
        const Text("Galeri Teknisi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildGalleryGrid(),
        const SizedBox(height: 20),
        const Text("4.9 ⭐ Ulasan Pelanggan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildReview("Henry Cavill", "Hasil renovasinya rapi dan sesuai harapan."),
        _buildReview("Tom Holland", "Pengerjaan cepat dan detail. Sangat puas."),
        _buildReview("Timothée Chalamet", "Profesional dan bisa dipercaya."),
      ]),
    );
  }

  Widget _buildGalleryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 5,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (_, i) {
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
                image: NetworkImage("https://picsum.photos/400/300?random=$i"),
                fit: BoxFit.cover),
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
              Text(s.getPriceRangeText(), style: const TextStyle(fontSize: 13, color: Color(0xFF0C4481), fontWeight: FontWeight.w600)),
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
    final priceMinCtrl = TextEditingController(text: service.priceMin?.toString() ?? '');
    final priceMaxCtrl = TextEditingController(text: service.priceMax?.toString() ?? '');
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
                  Row(children: [
                    Expanded(child: TextFormField(controller: priceMinCtrl, decoration: const InputDecoration(labelText: "Harga Min (angka)"), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly],)),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(controller: priceMaxCtrl, decoration: const InputDecoration(labelText: "Harga Max (angka)"), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly],)),
                  ]),
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
                          final min = priceMinCtrl.text.trim().isEmpty ? null : int.parse(priceMinCtrl.text.trim());
                          final max = priceMaxCtrl.text.trim().isEmpty ? null : int.parse(priceMaxCtrl.text.trim());
                          if (min != null && max != null && min > max) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harga Min tidak boleh lebih besar dari Harga Max")));
                            return;
                          }

                          showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

                          try {
                            final resp = await ApiService.updateLayananTeknisi(
                              id: service.id,
                              nama: nameCtrl.text.trim(),
                              hargaMin: min,
                              hargaMax: max,
                              deskripsi: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                              gambarFile: pickedImage != null ? File(pickedImage!.path) : null,
                            );

                            Navigator.of(context).pop(); // close loading dialog

                            if ((resp['statusCode'] == 200) || (resp['data'] is Map && (resp['data']['success'] == true || resp['statusCode'] == 200))) {
                              final data = resp['data']['data'] ?? resp['data'];
                              final imgPath = data['gambar_layanan'] as String?;
                              
                              print("DEBUG: Edit success. Updating service at index $index");
                              print("DEBUG: New image path: $imgPath");
                              final fullImgUrl = imgPath != null ? (BaseUrl.api.replaceAll('/api', '') + imgPath) : null;
                              print("DEBUG: Full image URL: $fullImgUrl");

                              setState(() {
                                _services[index] = Service(
                                  id: service.id,
                                  name: nameCtrl.text.trim(),
                                  description: descCtrl.text.trim().isEmpty ? "Tidak ada deskripsi" : descCtrl.text.trim(),
                                  priceMin: min,
                                  priceMax: max,
                                  imageFile: pickedImage != null ? File(pickedImage!.path) : service.imageFile,
                                  imageUrl: pickedImage == null ? (fullImgUrl ?? service.imageUrl) : null,
                                  idKeahlian: service.idKeahlian, // Keep original ID
                                  namaKeahlian: service.namaKeahlian,
                                );
                              });

                              Navigator.of(ctx2).pop(); // close modal
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Layanan berhasil diperbarui")));
                            } else {
                              final msg = (resp['data'] is Map) ? (resp['data']['message'] ?? resp['data'].toString()) : 'Gagal memperbarui layanan';
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $msg')));
                            }
                          } catch (e) {
                            Navigator.of(context).pop(); // close loading
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

  Widget _buildCustomBottomNav() {
    const highlight = Color(0xFFFFCC33);
    final items = [
      _NavItem(icon: Icons.home, label: 'Beranda'),
      _NavItem(icon: Icons.assignment, label: 'Pesanan'),
      _NavItem(icon: Icons.history, label: 'Riwayat'),
      _NavItem(icon: Icons.person, label: 'Profil'),
      _NavItem(icon: Icons.more_horiz, label: 'Lainnya'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF0C4481), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -1))]),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == _currentIndex;
          final item = items[i];
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onNavTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                decoration: BoxDecoration(color: active ? highlight.withOpacity(0.12) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: active ? highlight.withOpacity(0.18) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                    child: Icon(item.icon, color: active ? highlight : Colors.white, size: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(item.label, style: TextStyle(fontSize: 11, color: active ? highlight : Colors.white)),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeTeknisiPage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PesananTeknisiPage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RiwayatTeknisiPage()));
        break;
      case 3:
        // already profile
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LainnyaPage()));
        break;
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
