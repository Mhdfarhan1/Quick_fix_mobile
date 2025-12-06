import 'package:flutter/material.dart';
import '../screens/teknisi/home/Home_page_teknisi.dart';
import '../screens/teknisi/pesan/pesan_teknisi_page.dart';
import '../screens/teknisi/riwayat/riwayat_teknisi_page.dart';
import '../screens/teknisi/lainnya/lainnya_page.dart';

class TeknisiBottomNav extends StatelessWidget {
  final int currentIndex;

  const TeknisiBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -1),
          )
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final bool active = i == currentIndex;
          final item = items[i];

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onNavTap(i, context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                decoration: BoxDecoration(
                  color: active ? highlight.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: active ? highlight.withOpacity(0.18) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.icon,
                        color: active ? highlight : Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: active ? highlight : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _onNavTap(int index, BuildContext context) {
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
        break;
      case 4:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LainnyaPage()));
        break;
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
