import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quick_fix/screens/teknisi/lainnya/lainnya_page.dart';
import 'package:quick_fix/screens/teknisi/pesan/pesan_teknisi_page.dart';
import 'package:quick_fix/screens/teknisi/riwayat/riwayat_teknisi_page.dart';
import '../home/Home_page_teknisi.dart';

class TechnicianProfilePage extends StatefulWidget {
  final bool isTechnician; // true = teknisi, false = pelanggan

  const TechnicianProfilePage({Key? key, this.isTechnician = true})
      : super(key: key);

  @override
  State<TechnicianProfilePage> createState() => _TechnicianProfilePageState();
}

class _TechnicianProfilePageState extends State<TechnicianProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 3; // posisi "Profil" di nav bar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeTeknisiPage()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const PesananTeknisiPage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const RiwayatTeknisiPage()));
        break;
      case 3:
        // Sudah di halaman Profil
        break;
      case 4:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LainnyaPage()));
        break;
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

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF0C4481),
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              "https://i.pravatar.cc/300",
            ),
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

  // === PROFIL TAB ===
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tentang Saya",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            "Hai! Aku Louis, seorang engineer yang fokus di bidang renovasi rumah. "
            "Sudah beberapa tahun aku bergelut di dunia renovasi dan membantu banyak orang "
            "meujudkan rumah impian mereka.",
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 10),
          if (widget.isTechnician)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFECC32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Edit", style: TextStyle(color: Colors.black)),
            ),
          const SizedBox(height: 20),
          const Text("Galeri Teknisi",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildGalleryGrid(),
          if (widget.isTechnician)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFECC32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child:
                    const Text("Edit", style: TextStyle(color: Colors.black)),
              ),
            ),
          const SizedBox(height: 20),
          const Text("4.9 ⭐ Ulasan Pelanggan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildReview("Henry Cavill",
              "Hasil renovasinya rapi dan sesuai harapan. Komunikasi juga enak dari awal sampai akhir."),
          _buildReview("Tom Holland",
              "Pengerjaan cepat dan detail. Sangat puas dengan hasil akhir rumah kami."),
          _buildReview("Timothée Chalamet",
              "Profesional dan bisa dipercaya. Rumah lama kami jadi terlihat baru!"),
        ],
      ),
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
              image: NetworkImage(
                "https://picsum.photos/400/300?random=$i",
              ),
              fit: BoxFit.cover,
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
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              "https://i.pravatar.cc/150?img=3",
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // === LAYANAN TAB ===
  Widget _buildServiceTab() {
    final sortButtons = ["Top Rated", "By Price", "Delivery Time"];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Sort by",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: sortButtons
              .map((b) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: b == "Top Rated"
                            ? const Color(0xFF0C4481)
                            : Colors.grey[200],
                        foregroundColor:
                            b == "Top Rated" ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(b, style: const TextStyle(fontSize: 13)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8),
          itemBuilder: (_, i) => _buildServiceCard(),
        ),
        if (widget.isTechnician)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: TextButton(
                onPressed: () {},
                child: const Text("+ Tambah Layanan",
                    style: TextStyle(
                        color: Color(0xFF0C4481),
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _buildServiceCard() {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              "https://picsum.photos/400/300?service",
              height: 90,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Cuci AC",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Spesialis cuci AC segala jenis",
                    style: TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 6),
                const Text("Rp 50.000 - 250.000",
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0C4481),
                        fontWeight: FontWeight.w600)),
                if (!widget.isTechnician)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFECC32),
                        minimumSize: const Size(double.infinity, 32),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("BOOK",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === CUSTOM NAVIGATION BAR ===
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
      decoration: BoxDecoration(
        color: const Color(0xFF0C4481),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: const Offset(0, -1))
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == _currentIndex;
          final item = items[i];
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onNavTap(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                decoration: BoxDecoration(
                  color:
                      active ? highlight.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: active
                            ? highlight.withOpacity(0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon,
                          color: active ? highlight : const Color.fromARGB(255, 255, 255, 255), size: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(item.label,
                        style: TextStyle(
                            fontSize: 11,
                            color: active ? highlight : const Color.fromARGB(255, 255, 255, 255))),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
