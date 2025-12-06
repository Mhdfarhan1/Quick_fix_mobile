import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// === Import halaman yang akan dibuka ===
import '../screens/pengguna/orders/my_order_screen.dart';
import '../screens/chat/chat_list_page.dart';
import '../screens/notifikasi/notificationPage.dart';
import '../screens/pengguna/profile/profile_page.dart';
import '../providers/auth_provider.dart';

class UserBottomNav extends StatelessWidget {
  final int selectedIndex;

  const UserBottomNav({
    Key? key,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF0C4481),
      currentIndex: selectedIndex,
      selectedItemColor: const Color(0xFFFFC918),
      unselectedItemColor: Colors.white,
      onTap: (index) => _onItemTapped(index, context),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Aktivitas'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyOrderScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyOrderScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ChatListPage()),
        );
        break;
      case 3:
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (auth.userId == null) {
          print("❌ ERROR: userId masih NULL");
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => NotificationPage(userId: auth.userId!)),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePenggunaPage()),
        );
        break;
    }
  }
}
