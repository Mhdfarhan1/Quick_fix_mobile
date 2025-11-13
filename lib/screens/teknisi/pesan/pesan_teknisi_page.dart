import 'package:flutter/material.dart';
import 'package:quick_fix/screens/teknisi/riwayat/riwayat_teknisi_page.dart';
import '../home/Home_page_teknisi.dart';
import '../profile/prof_tek.dart';
import '../lainnya/lainnya_page.dart';

class PesananTeknisiPage extends StatefulWidget {
  const PesananTeknisiPage({Key? key}) : super(key: key);

  @override
  State<PesananTeknisiPage> createState() => _PesananTeknisiPageState();
}

class _PesananTeknisiPageState extends State<PesananTeknisiPage> {
  int _currentIndex = 1;
  int _selectedFilter = 1;
  final Color blueHeader = const Color(0xFF0C4481);
  final List<String> filters = ["Hari ini", "Minggu ini", "Bulan ini", "Tahun ini"];

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeTeknisiPage()));
        break;
      case 1:
        // Ganti ke halaman Pesanan jika sudah siap
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const RiwayatTeknisiPage()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const TechnicianProfilePage()));
        break;
      case 4:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LainnyaPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const blueHeader = Color(0xFF0C4481);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ==== HEADER ====
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: blueHeader,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.only(top: 50, bottom: 14),
            child: const Center(
              child: Text(
                "Pesanan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildFilterCarousel(),
          const SizedBox(height: 10),
          Expanded(child: _buildTaskList()),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildFilterCarousel() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD2F4F9) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isSelected ? blueHeader : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList() {
    final List<Map<String, dynamic>> tasks = [
      {
        "date": "Rabu, 23 Oktober 2025",
        "items": [
          {"time": "08.00", "title": "Servis AC Rumah Tangga", "name": "Rizky Hidayat", "address": "Jl.Merpati No.33"},
          {"time": "11.00", "title": "Instalasi Kabel", "name": "Siti Budiman", "address": "Jl.Merak No.05"},
          {"time": "14.00", "title": "Perbaikan Mesin Cuci", "name": "Agus Rahardjo", "address": "Jl.Elang No.11"},
        ]
      },
      {
        "date": "Kamis, 24 Oktober 2025",
        "items": [
          {"time": "09.00", "title": "Perbaikan Kulkas", "name": "Rahmat Jaya", "address": "Jl.Bangau No.27"},
          {"time": "13.00", "title": "Instalasi CCTV", "name": "Tono Suryo", "address": "Jl.Kenari No.14"},
        ]
      },
      {
        "date": "Jumat, 25 Oktober 2025",
        "items": [
          {"time": "08.30", "title": "Pengecekan Listrik", "name": "Lukman Hakim", "address": "Jl.Cendrawasih No.09"},
          {"time": "10.00", "title": "Servis Pompa Air", "name": "Nina Wahyuni", "address": "Jl.Kutilang No.21"},
          {"time": "15.00", "title": "Perbaikan Mesin Cuci", "name": "Bagus Saputra", "address": "Jl.Garuda No.07"},
        ]
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        final day = tasks[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day["date"], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            ...List.generate((day["items"] as List).length, (j) {
              final item = day["items"][j];
              return _buildTaskCard(item);
            }),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom waktu + garis vertikal tipis
          Column(
            children: [
              Text(
                item["time"],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Container(
                width: 1.5,
                height: 60,
                color: Colors.grey.shade300,
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Detail tugas di kanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["title"], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(item["name"], style: const TextStyle(fontSize: 13, color: Colors.black87)),
                Text(item["address"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Detail ${item["title"]}")),
                  ),
                  child: const Text(
                    "Detail Tugas",
                    style: TextStyle(
                      color: Color(0xFF0C4481),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, -1))],
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
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: active ? highlight.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: active ? highlight : Colors.grey, size: 22),
                    const SizedBox(height: 4),
                    Text(item.label,
                        style: TextStyle(fontSize: 11, color: active ? highlight : Colors.grey)),
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
