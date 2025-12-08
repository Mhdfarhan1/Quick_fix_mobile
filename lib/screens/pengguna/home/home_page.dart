import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../../../widgets/status_popup.dart';
import '../../../services/teknisi_service.dart';
import '../orders/my_order_screen.dart';
import '../categories/housing_category_screen.dart';
import '../categories/electronics_category_screen.dart';
import '../categories/car_category_screen.dart';
import '../categories/motorcycle_category_screen.dart';
import '../../teknisi/profile/prof_tek.dart';
import '../pencarian/search_landing_page.dart';
import '../pemesanan/keranjang_screen.dart';
import '../../../widgets/network_image_with_fallback.dart';
import '../../../widgets/app_dialog.dart';
import '../../../config/base_url.dart';
import '../../notifikasi/notificationPage.dart';
import '../../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../widgets/user_bottom_nav.dart';

extension ResponsiveHeight on BuildContext {
  double adaptiveHeight(double percent, {double min = 120, double max = 200}) {
    final h = MediaQuery.of(this).size.height * percent;
    return h.clamp(min, max);
  }
}

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
  bool isLoadingPesanan = true;
  bool isLoadingTeknisi = true;

  List<dynamic> bannerList = [];
  bool isLoadingBanner = true;

  String? lastStatus;  // simpan
  bool isFirstLoad = true;

  // === Banner controller & auto slide ===
  final PageController _bannerPageController = PageController(
    viewportFraction: 0.9,
  );
  Timer? _bannerTimer;
  int _currentBannerPage = 0;

  @override
  void initState() {
    super.initState();
    loadData();
    _startBannerAutoSlide();
    fetchPesanan();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    super.dispose();
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();

    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || bannerList.isEmpty) return;

      final nextPage = (_currentBannerPage + 1) % bannerList.length;

      _bannerPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      setState(() {
        _currentBannerPage = nextPage;
      });
    });
  }

  Future<void> loadData() async {
    debugPrint('🚀 [Home] Memulai loadData...');
    if (!mounted) return;

    setState(() {
      isLoadingPesanan = true;
      isLoadingTeknisi = true;
      isLoadingBanner = true;
    });

    try {
      await Future.wait([
        fetchBanner(),
        fetchPesanan(),
        fetchTeknisi(),
      ]);
    } catch (e) {
      debugPrint('❌ [Home] Error saat loadData: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        isLoadingPesanan = false;
        isLoadingTeknisi = false;
        // isLoadingBanner di-set di fetchBanner()
      });
      debugPrint('✅ [Home] loadData selesai.');
    }
  }

  Future<void> fetchTeknisi() async {
    debugPrint('🧰 [fetchTeknisi] Mulai memuat data teknisi...');

    try {
      final teknisiData = await teknisiService.getTeknisiList();

      if (!mounted) return;
      setState(() {
        teknisiList = teknisiData..shuffle();
        if (teknisiList.length > 6) {
          teknisiList = teknisiList.sublist(0, 6);
        }
        isLoadingTeknisi = false;
      });

      debugPrint('✅ [fetchTeknisi] Berhasil memuat ${teknisiList.length} teknisi.');
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingTeknisi = false);

      debugPrint('❌ [fetchTeknisi] Error: $e');
      AppDialog.showError(
        context,
        message: "Terjadi kesalahan jaringan. Coba lagi nanti.",
        onRetry: () => loadData(),
      );
    }
  }

  Future<void> fetchPesanan() async {
    debugPrint('📦 [fetchPesanan] Mulai memuat data pesanan...');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? idUser = prefs.getInt('id_user');
      String? role = prefs.getString('role');

      debugPrint('👤 idUser: $idUser, role: $role');

      if (idUser == null || role == null) {
        debugPrint('⚠️ Tidak ada user yang login. Melewati fetchPesanan.');
        if (!mounted) return;
        setState(() {
          pesananList = [];
          isLoadingPesanan = false;
        });
        return;
      }

      String url = "${BaseUrl.server}/api/get_pemesanan?";
      if (role == 'pelanggan') {
        url += "id_pelanggan=$idUser";
      } else if (role == 'teknisi') {
        url += "id_teknisi=$idUser";
      }

      debugPrint('🌐 [fetchPesanan] Memanggil API: $url');

      final response = await http.get(Uri.parse(url));
      debugPrint('📥 [fetchPesanan] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('🧩 [fetchPesanan] Response: $data');

        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> result = (data['data'] as List)
          
              .where((item) => item['status']?.toLowerCase() != 'dibatalkan')
              .take(6)
              .toList();
              debugPrint("📦 Total pesanan sebelum filter: ${data['data'].length}");
              debugPrint("📦 Total pesanan sesudah filter (dibatalkan dihapus): ${result.length}");


          debugPrint('✅ [fetchPesanan] Berhasil memuat ${result.length} pesanan.');

          // ================================
          // 🔥 CEK PERUBAHAN STATUS DI SINI
          // ================================
          if (result.isNotEmpty) {
            final currentStatus = result.first['status'].toString().toLowerCase();

            // --- CEGAH POPUP MUNCUL PERTAMA KALI ---
            if (isFirstLoad) {
              lastStatus = currentStatus;
              isFirstLoad = false;
            } else if (currentStatus != lastStatus) {
              // --- MUNCULKAN POPUP HANYA SAAT STATUS BERUBAH ---
              debugPrint("🔥 STATUS BERUBAH dari $lastStatus → $currentStatus");
              debugPrint("📍 Status dari API: $currentStatus");

              lastStatus = currentStatus;

              StatusPopup.show(context, status: currentStatus);
            }
          }


          // =========================
          // UPDATE STATE SEPERTI BIASA
          // =========================
          if (!mounted) return;
          setState(() {
            pesananList = result;
            isLoadingPesanan = false;
          });
        }else {
          debugPrint('⚠️ [fetchPesanan] Data kosong atau field tidak ditemukan.');
          if (!mounted) return;
          setState(() {
            pesananList = [];
            isLoadingPesanan = false;
          });
        }
      } else {
        debugPrint('❌ [fetchPesanan] Gagal memuat data. HTTP ${response.statusCode}');
        if (!mounted) return;
        setState(() {
          pesananList = [];
          isLoadingPesanan = false;
        });
      }
    } catch (e, stack) {
      debugPrint('💥 [fetchPesanan] Terjadi error: $e');
      debugPrint('📜 Stacktrace: $stack');
      if (!mounted) return;
      setState(() {
        pesananList = [];
        isLoadingPesanan = false;
      });
    }
  }

  Future<void> fetchBanner() async {
    debugPrint('🖼️ [fetchBanner] Mulai memuat banner...');

    try {
      final response = await http.get(
        Uri.parse("${BaseUrl.server}/api/banners"),
      );

      debugPrint('📥 [fetchBanner] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> result = (data['data'] ?? []) as List<dynamic>;

        debugPrint('✅ [fetchBanner] Berhasil memuat ${result.length} banner.');

        if (!mounted) return;
        setState(() {
          bannerList = result;
          isLoadingBanner = false;
        });

        // refresh auto slide ketika data banner berubah
        _startBannerAutoSlide();
      } else {
        debugPrint('⚠️ [fetchBanner] Gagal memuat banner. HTTP ${response.statusCode}');
        if (!mounted) return;
        setState(() {
          bannerList = [];
          isLoadingBanner = false;
        });
      }
    } catch (e, stack) {
      debugPrint('💥 [fetchBanner] Terjadi error: $e');
      debugPrint('📜 Stacktrace: $stack');
      if (!mounted) return;
      setState(() {
        bannerList = [];
        isLoadingBanner = false;
      });
    }
  }


  Widget shimmerBox(double h, double w) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
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
                
                _buildHeader(context),
                const SizedBox(height: 50),

                // Kategori
                _buildCategories(),
                const SizedBox(height: 20),

                // Status pesanan
                _buildPesananSection(),
                const SizedBox(height: 20),
                // 🔹 Banner promosi (di bawah status pesanan)
                _buildBannerSection(),
                const SizedBox(height: 20),

                // Rekomendasi teknisi
                _buildTeknisiSection(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const UserBottomNav(selectedIndex: 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.asset(
          'assets/images/header_bg.png',
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
        Container(
          width: double.infinity,
          height: 180,
          color: Colors.black.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'QUICKFIX',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
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
    );
  }

  Widget _buildCategories() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _CategoryItem(
          icon: Icons.home_repair_service,
          label: 'Renovasi',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HousingCategoryScreen()),
            );
          },
        ),
        _CategoryItem(
          icon: Icons.electrical_services,
          label: 'Elektronik',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ElectronicsCategoryScreen()),
            );
          },
        ),
        _CategoryItem(
          icon: Icons.directions_car,
          label: 'Mobil',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CarCategoryScreen()),
            );
          },
        ),
        _CategoryItem(
          icon: Icons.motorcycle,
          label: 'Motor',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MotorcycleCategoryScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPesananSection() {
    if (isLoadingPesanan) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Memuat status pesanan...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: shimmerBox(120, 220),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (pesananList.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Pesanan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF0C4481),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrderScreen()),
                ),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: Color(0xFF0C4481), // 0xFF di depan untuk opacity 100%
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: context.adaptiveHeight(0.2, min: 140, max: 220),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pesananList.length,
            itemBuilder: (context, index) {
              final pesanan = pesananList[index];
              final status = pesanan['status'] ?? '-';
              final namaKeahlian = pesanan['nama_keahlian'] ?? '-';
              final tanggal = pesanan['tanggal_booking'] ?? '-';
              final jam = pesanan['jam_booking'] ?? '-';
              final alamat = pesanan['alamat_lengkap'] ?? '-';

              Color color;
              switch (status.toLowerCase()) {
                case 'batal':
                  color = const Color.fromARGB(255, 255, 0, 0);
                  break;
                case 'selesai':
                  color = const Color.fromARGB(255, 105, 105, 105);
                  break;
                case 'menuju_lokasi':
                  color = const Color.fromARGB(255, 19, 223, 0);
                  break;
                case 'sedang_bekerja':
                  color = const Color.fromARGB(255, 19, 223, 0);
                  break;
                case 'dijadwalkan':
                  color = Colors.blue;
                  break;
                default:
                  color = Colors.orange;
              }

              return Container(
                width: 240,
                margin: EdgeInsets.only(left: index == 0 ? 16 : 8, right: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  color: const Color(0xFFE7F0FA),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          namaKeahlian,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFF0C4481),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 13,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$tanggal • $jam',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 13,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                alamat,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
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
      ],
    );
  }

  Widget _buildBannerSection() {
    // Dummy banner sementara
    final dummyBannerList = [
      {
        "judul": "Promo Spesial Hari Ini",
        "gambar": "https://picsum.photos/400/160?random=1",
        "link": "https://example.com/promo1",
      },
      {
        "judul": "Diskon Akhir Tahun",
        "gambar": "https://picsum.photos/400/160?random=2",
        "link": "https://example.com/promo2",
      },
      {
        "judul": "Gratis Ongkir Semua Produk",
        "gambar": "https://picsum.photos/400/160?random=3",
        "link": "https://example.com/promo3",
      },
    ];

    final banners = bannerList.isNotEmpty ? bannerList : dummyBannerList;

    if (isLoadingBanner) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: shimmerBox(160, double.infinity),
      );
    }

    if (banners.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Banner Promosi",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0C4481)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _bannerPageController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerPage = index;
              });
            },
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              final judul = banner['judul'] ?? '';
              final gambar = banner['gambar'] ?? '';
              final link = banner['link'];
              final fullUrl = bannerList.isNotEmpty
                  ? '${BaseUrl.server}/storage/$gambar'
                  : gambar; // kalau dummy pakai url langsung

              return GestureDetector(
                onTap: () {
                  if (link != null && link.toString().isNotEmpty) {
                    debugPrint('👉 Klik banner: $link');
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        NetworkImageWithFallback(
                          imageUrl: fullUrl,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black54, Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 10,
                          child: Text(
                            judul,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
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
        const SizedBox(height: 8),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(banners.length, (index) {
              final isActive = index == _currentBannerPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: isActive ? 16 : 6,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF0C4481) : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }


  Widget _buildTeknisiSection() {
    if (isLoadingTeknisi) {
      final screenHeight = MediaQuery.of(context).size.height;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Memuat rekomendasi teknisi...",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: context.adaptiveHeight(0.27, min: 200, max: 260),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: shimmerBox(screenHeight * 0.18, 180),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (teknisiList.isEmpty) {
      return AppDialog.emptyState(
        message: "Belum ada layanan di wilayah Anda.",
        subText: "Coba periksa kembali nanti.",
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Rekomendasi Teknisi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0C4481)),
          ),
        ),
        SizedBox(
          height: context.adaptiveHeight(0.27, min: 200, max: 260),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: teknisiList.length,
            itemBuilder: (context, index) {
              final teknisi = teknisiList[index];
              final user = teknisi['user'];
              final foto = user?['foto_profile'] ?? '';
              final fotoPath = foto.startsWith('foto/foto_teknisi/')
                  ? foto
                  : 'foto/foto_teknisi/$foto';

              final fullUrl = '${BaseUrl.server}/storage/$fotoPath';

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProfileTeknisiPage(teknisiId: teknisi['id_teknisi']),
                  ),
                ),
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
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: NetworkImageWithFallback(
                            imageUrl: fullUrl,
                            height: context.adaptiveHeight(
                              0.12,
                              min: 80,
                              max: 120,
                            ),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?['nama'] ?? 'Tidak diketahui',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '⭐ ${teknisi['rating_avg'] ?? 4.8}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                teknisi['deskripsi'] ?? '-',
                                style: const TextStyle(fontSize: 11),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF0C4481),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
