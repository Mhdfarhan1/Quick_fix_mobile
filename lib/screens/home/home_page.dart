import 'package:flutter/material.dart';
import '../orders/my_order_screen.dart';
import '../categories/housing_category_screen.dart';
import '../categories/electronics_category_screen.dart';
import '../categories/car_category_screen.dart';
import '../categories/motorcycle_category_screen.dart';
import '../profile/profile_page.dart';
import '../teknisi/teknisi_screen.dart';
import '../pencarian/search_landing_page.dart';
import '../profile/profile_teknisi_page.dart';
import '../chat/chat_page.dart';
import '../notifikasi/notif.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0;
  int _carouselIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  final List<Map<String, dynamic>> kategori = [
    {"nama": "Renovasi", "icon": Icons.home_repair_service_outlined},
    {"nama": "Elektronik", "icon": Icons.electrical_services_outlined},
    {"nama": "Montir Mobil", "icon": Icons.car_repair_outlined},
    {"nama": "Montir Motor", "icon": Icons.two_wheeler_outlined},
  ];

  final List<String> carouselImages = [
    "https://images.unsplash.com/photo-1581578731548-c64695cc6952?q=80&w=2070&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1600585152220-90363fe7e115?q=80&w=2070&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=2070&auto=format&fit=crop"
  ];

  final List<Map<String, String>> teknisi = [
    {
      "nama": "AHMAD SAROPI",
      "jarak": "5.0 km",
      "rating": "4.6",
      "bidang": "Elektronik",
      "deskripsi": "Perbaikan atap rumah, teralis, dan kebocoran pipa",
      "gambar":
          "https://images.unsplash.com/photo-1558611848-73f7eb4001a1?q=80&w=2071&auto=format&fit=crop"
    },
    {
      "nama": "BUDI HARTONO",
      "jarak": "3.2 km",
      "rating": "4.8",
      "bidang": "Elektronik",
      "deskripsi": "Servis AC, kulkas, dan mesin cuci",
      "gambar":
          "https://images.unsplash.com/photo-1603386329225-868f9b1ee5a9?q=80&w=2070&auto=format&fit=crop"
    },
    {
      "nama": "JOKO PRANOTO",
      "jarak": "6.5 km",
      "rating": "4.5",
      "bidang": "Elektronik",
      "deskripsi": "Montir motor dan mobil berpengalaman",
      "gambar":
          "https://images.unsplash.com/photo-1581093804226-ffa7c4a6a77d?q=80&w=2070&auto=format&fit=crop"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: _buildCustomBottomNavBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderAndSearch(),
            const SizedBox(height: 50),
            _buildSectionTitle("KATEGORI"),
            _buildCategories(),
            _buildSectionTitle("BARU-BARU INI"),
            _buildCarousel(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "REKOMENDASI TEKNISI",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0C4481),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TeknisiScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerRight,
                    ),
                    child: const Text(
                      "Lihat Lainnya",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildTechnicianRecommendations(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ------------------- Bottom Navigation -------------------
  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0C4481),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, Icons.home_outlined, "Beranda", 0),
          _buildNavItem(Icons.show_chart, Icons.show_chart_outlined, "Aktivitas", 1),
          _buildNavItem(Icons.receipt_long, Icons.receipt_long_outlined, "Pesanan", 2),
          _buildNavItem(Icons.notifications, Icons.notifications_outlined, "Notifikasi", 3),
          _buildNavItem(Icons.person, Icons.person_outline, "Profil", 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    bool isActive = _bottomNavIndex == index;
    final Color activeColor = Colors.amber;
    final Color inactiveColor = Colors.white;

    return GestureDetector(
      onTap: () {
        setState(() {
          _bottomNavIndex = index;
        });

        // Navigasi berdasarkan tab yang diklik
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyOrderScreen()),
          );
        } else if (index == 3) {
          // ✅ Tambahkan ini untuk membuka notif.dart
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotifikasiPage()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePenggunaPage()),
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : inactiveIcon,
            color: isActive ? activeColor : inactiveColor,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- Header & Search -------------------
  Widget _buildHeaderAndSearch() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF0C4481)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/Logo_quickfix.png', height: 60),
                      const SizedBox(width: 8),
                      const Text(
                        "QUICKFIX",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // 💬 Tombol Chat
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatListPage()),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.amber,
                      child: Icon(
                        Icons.chat_bubble,
                        color: Color(0xFF0C4481),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -28,
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: TextField(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchLandingPage(initialQuery: ""),
                    ),
                  );
                },
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Mau perbaiki apa hari ini?",
                  hintStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.amber,
                  prefixIcon: const Icon(Icons.search, color: Colors.black, size: 26),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------- Section Title -------------------
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 18, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFF0C4481),
        ),
      ),
    );
  }

  // ------------------- Categories -------------------
  Widget _buildCategories() {
    return SizedBox(
      height: 120,
      child: Center(
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          itemCount: kategori.length,
          itemBuilder: (context, index) {
            final name = kategori[index]["nama"]?.toString() ?? '<null>';
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (name == "Renovasi") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HousingCategoryScreen()),
                    );
                  } else if (name == "Elektronik") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ElectronicsCategoryScreen()),
                    );
                  } else if (name == "Montir Mobil") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CarCategoryScreen()),
                    );
                  } else if (name == "Montir Motor") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MotorcycleCategoryScreen()),
                    );
                  }
                },
                child: SizedBox(
                  width: 85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(
                          kategori[index]["icon"],
                          color: const Color(0xFF0C4481),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kategori[index]["nama"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ------------------- Carousel -------------------
  Widget _buildCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: carouselImages.length,
            onPageChanged: (index) {
              setState(() {
                _carouselIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(carouselImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(carouselImages.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _carouselIndex == index ? 10 : 8,
              height: _carouselIndex == index ? 10 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _carouselIndex == index
                    ? const Color(0xFF0C4481)
                    : Colors.grey.shade300,
              ),
            );
          }),
        ),
      ],
    );
  }

  // ------------------- Technician Recommendations -------------------
  Widget _buildTechnicianRecommendations() {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: teknisi.length,
        itemBuilder: (context, index) {
          final data = teknisi[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileTeknisiPage(
                  nama: data["nama"] ?? "Tidak diketahui",
                  jarak: data["jarak"] ?? "-",
                  rating: data["rating"] ?? "0",
                  bidang: data["bidang"] ?? "Umum",
                  harga: double.tryParse(data["harga"] ?? "0") ?? 0,
                  deskripsi: data["deskripsi"] ?? "Belum ada deskripsi",
                  gambar: data["gambar"] ?? "assets/images/default.png",
                ),

                ),
              );
            },
            child: Container(
              width: 170,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      data["gambar"]!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data["nama"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(data["jarak"]!, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 8),
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 2),
                              Text(data["rating"]!, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data["deskripsi"]!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(fontSize: 12, color: Colors.grey[700]),
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
    );
  }
}
