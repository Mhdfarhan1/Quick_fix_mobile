import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../services/teknisi_service.dart';
import '../orders/my_order_screen.dart';
import '../categories/housing_category_screen.dart';
import '../categories/electronics_category_screen.dart';
import '../categories/car_category_screen.dart';
import '../categories/motorcycle_category_screen.dart';
import '../profile/profile_page.dart';
import '../../teknisi/profile/profile_teknisi_page.dart';
import '../pencarian/search_landing_page.dart';
import '../../chat/chat_page.dart';
import '../notifikasi/notif.dart';
import '../../../widgets/network_image_with_fallback.dart';
import '../../../widgets/app_dialog.dart';
import '../../../config/base_url.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final teknisiService = TeknisiService();

  List<dynamic> teknisiList = [];
  List<dynamic> pesananList = [];
  bool isLoading = true;

  

  @override
  void initState() {
    super.initState();
    loadData();
  }


  Future<void> loadData() async {
    try {
      await Future.wait([fetchPesanan(), fetchTeknisi()]);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchTeknisi() async {
    try {
      final teknisiData = await teknisiService.getTeknisiList();
      setState(() => teknisiList = teknisiData);
    } catch (e) {
      AppDialog.showError(
        context,
        message: "Terjadi kesalahan jaringan. Coba lagi nanti.",
        onRetry: () => loadData(),
      );
    }
  }


  Future<void> fetchPesanan() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      int? idUser = prefs.getInt('id_user');
      String? role = prefs.getString('role');

      String url = "${BaseUrl.server}/api/get_pemesanan?";
      if (role == 'pelanggan') {
        url += "id_pelanggan=$idUser";
      } else if (role == 'teknisi') {
        url += "id_teknisi=$idUser";
      }

      final response = await http.get(Uri.parse(url));
      print("🔹 URL GET: $url");
      print("🔹 Status Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          pesananList = data['data'] ?? [];
        });

        print("✅ Jumlah pesanan: ${pesananList.length}");
      } else {
        print("❌ Gagal fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetch pesanan: $e");
    }
    print(pesananList);

  }


  void _onItemTapped(int index) {
    if (index < 0 || index > 4) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrderScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListPage()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiPage()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePenggunaPage()));
        break;
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Header
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(1),
                        bottomRight: Radius.circular(1),
                      ),
                      child: Image.asset(
                        'assets/images/header_bg.png',
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(1),
                          bottomRight: Radius.circular(1),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'QUICKFIX',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.shopping_cart, color: Colors.white),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Selamat datang kembali!',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: -25,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SearchLandingPage()),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: const Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey),
                              SizedBox(width: 10),
                              Text(
                                'Mau perbaiki apa hari ini?',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // 🔹 Kategori
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _CategoryItem(
                      icon: Icons.home_repair_service,
                      label: 'Renovasi',
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const HousingCategoryScreen())),
                    ),
                    _CategoryItem(
                      icon: Icons.electrical_services,
                      label: 'Elektronik',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ElectronicsCategoryScreen())),
                    ),
                    _CategoryItem(
                      icon: Icons.directions_car,
                      label: 'Mobil',
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const CarCategoryScreen())),
                    ),
                    _CategoryItem(
                      icon: Icons.motorcycle,
                      label: 'Motor',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MotorcycleCategoryScreen())),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                

                // 🔹 Status Pesanan (hanya tampil jika ada)
                  if (pesananList.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF0C4481),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MyOrderScreen()),
                            );
                          },
                          child: const Text(
                            'Lihat semua',
                            style: TextStyle(
                              color: Color(0xFF007AFF),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pesananList.length,
                      itemBuilder: (context, index) {
                        final pesanan = pesananList[index];

                        final namaLayanan = pesanan['nama_keahlian'] ?? '-';
                        final lokasi = pesanan['alamat_lengkap'] ?? '-';
                        final tanggal = pesanan['tanggal_booking'] ?? '-';
                        final status = pesanan['status'] ?? 'Menunggu';


                        // 🎨 Warna otomatis berdasarkan status
                        Color statusColor;
                        switch (status.toLowerCase()) {
                          case 'menunggu':
                            statusColor = Colors.orange;
                            break;
                          case 'diproses':
                            statusColor = Colors.blue;
                            break;
                          case 'selesai':
                            statusColor = Colors.green;
                            break;
                          case 'dibatalkan':
                            statusColor = Colors.red;
                            break;
                          default:
                            statusColor = Colors.grey;
                        }

                        return Container(
                          width: 220,
                          margin: EdgeInsets.only(left: index == 0 ? 16 : 8, right: 8),
                          child: Card(
                            elevation: 3,
                            color: const Color(0xFFE7F0FA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 🔖 STATUS
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // 🧰 NAMA LAYANAN
                                  Text(
                                    namaLayanan,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF0C4481),
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // 📍 LOKASI
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          lokasi,
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.black87),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // 📅 TANGGAL
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 13, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        tanggal,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                  // 🔹 Baru-baru ini (gambar layanan)
                  if (pesananList.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Baru-baru ini',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF0C4481),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pesananList.length,
                        itemBuilder: (context, index) {
                          final pesanan = pesananList[index];

                          // Ambil data bukti pekerjaan & teknisi

                          final fotoBukti = pesanan['foto_bukti'] ?? '';
                          final fullGambarUrl = '${BaseUrl.server}/storage/bukti/$fotoBukti';
                          final namaTeknisi = pesanan['teknisi']?['nama'] ?? 'Tidak diketahui';

                          return Container(
                            width: 260,
                            margin: EdgeInsets.only(left: index == 0 ? 16 : 8, right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Stack(
                                children: [
                                  // Gambar bukti pekerjaan
                                  NetworkImageWithFallback(
                                    imageUrl: fullGambarUrl,
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    width: double.infinity,
                                  ),

                                  // Gradasi hitam transparan di bawah
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.6),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Nama teknisi di bawah gambar
                                  Positioned(
                                    left: 10,
                                    bottom: 8,
                                    child: Text(
                                      namaTeknisi,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 5,
                                            color: Colors.black45,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],


                // 🔹 Rekomendasi Teknisi
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Rekomendasi teknisi',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 10),

                if (isLoading)
                  AppDialog.loadingState()
                else if (teknisiList.isEmpty)
                  AppDialog.emptyState(
                    message: "Belum ada layanan yang tersedia di wilayah Anda.",
                    subText: "Coba periksa kembali nanti.",)
                else
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: teknisiList.length,
                      itemBuilder: (context, index) {
                        final teknisi = teknisiList[index];
                        final user = teknisi['user'];
                        final foto = user?['foto_profile'] ?? '';

                        // ✅ Pastikan path benar
                        final fotoPath = foto.startsWith('foto_teknisi/')
                            ? foto
                            : 'foto_teknisi/$foto';
                        final fullFotoUrl = '${BaseUrl.server}/storage/$fotoPath';

                        print('🔹 Foto profil teknisi ${user?['nama']}: $fullFotoUrl');

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileTeknisiPage(teknisiId: teknisi['id_teknisi']),
                              ),
                            );
                          },
                          child: Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 10),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        const BorderRadius.vertical(top: Radius.circular(15)),
                                    child: NetworkImageWithFallback(
                                      imageUrl: fullFotoUrl,
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
                                        Text(user?['nama'] ?? 'Tidak diketahui',
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text('⭐ ${teknisi['rating_avg'] ?? 4.8}',
                                            style: const TextStyle(fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Text(teknisi['deskripsi'] ?? '-',
                                            style: const TextStyle(fontSize: 11),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0C4481),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFFFC918),
        unselectedItemColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Aktivitas'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[50],
            child: Icon(icon, color: const Color(0xFF0C4481)),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
