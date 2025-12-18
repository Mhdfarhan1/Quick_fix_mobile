import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORT FILE API & HALAMAN LAIN ---
// Pastikan path import ini sesuai dengan struktur folder project Anda
import '../../../services/api_service.dart'; // Ganti jika path beda
import '../../../config/base_url.dart';      // Ganti jika path beda

import 'package:quick_fix/screens/teknisi/pesan/pesan_teknisi_page.dart';
import 'package:quick_fix/screens/teknisi/riwayat/riwayat_teknisi_page.dart';
import 'package:quick_fix/screens/teknisi/lainnya/pendapatan_page.dart';
import 'package:quick_fix/screens/teknisi/lainnya/bantuan_laporan_page.dart';
import '../home/Home_page_teknisi.dart';
import '../profile/prof_tek.dart';
import '../../../screens/auth/login_screen.dart';
import '../../pengguna/Lainnya/bantuan_laporan_page.dart';
import '../../pengguna/Lainnya/kebijakan_privasi_page.dart';
import '../../pengguna/Lainnya/tentang_aplikasi.dart';
import '../profile/profile_edit_teknisi_page.dart';
import 'bantuan_laporan_page.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';



class LainnyaPage extends StatefulWidget {
  const LainnyaPage({super.key});

  @override
  State<LainnyaPage> createState() => _LainnyaPageState();
}

class _LainnyaPageState extends State<LainnyaPage> {
  int _currentIndex = 4; // Index untuk tab 'Lainnya'

  // --- STATE UNTUK VERIFIKASI ---
  bool _isVerified = false;       // Apakah status = 'disetujui'?
  bool _isLoadingStatus = true;   // Loading saat fetch API
  String _namaUser = "Memuat...";

  @override
  void initState() {
    super.initState();
    // Panggil fungsi cek status saat halaman dimuat
    _checkVerificationStatus();
    _fetchNamaUser();
  }

  // --- FUNGSI CEK STATUS KE API ---
  Future<void> _checkVerificationStatus() async {
    try {
      // Menggunakan helper request dari ApiService yang sudah Anda miliki
      final res = await ApiService.request(
        method: 'GET',
        endpoint: '/teknisi/verifikasi/status',
      );

      print("DEBUG LAINNYA PAGE RESP: $res");

      if (res['statusCode'] == 200 && res['data'] != null) {
        final data = res['data'];

        // Ambil string status, default 'belum_verifikasi'
        // Sesuaikan parsing JSON ini dengan struktur response controller Anda
        String statusServer = data['status'] ?? 'belum_verifikasi';

        // Handle jika data terbungkus dalam key 'data' lagi
        if (data['data'] != null && data['data'] is Map) {
          statusServer = data['data']['status'] ?? 'belum_verifikasi';
        }

        if (mounted) {
          setState(() {
            // Logika Verifikasi: Status harus persis 'disetujui'
            _isVerified = (statusServer == 'disetujui');
            _isLoadingStatus = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isVerified = false;
            _isLoadingStatus = false;
          });
        }
      }
    } catch (e) {
      print("Error Check Status (LainnyaPage): $e");
      if (mounted) {
        setState(() {
          _isVerified = false;
          _isLoadingStatus = false;
        });
      }
    }
  }

  Future<void> _fetchNamaUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idTeknisi = prefs.getInt("id_teknisi");

      if (idTeknisi == null) {
        setState(() => _namaUser = "Teknisi");
        return;
      }

      final res = await ApiService.get("/get_teknisi?id=$idTeknisi");

      if (res != null && res["data"] != null) {
        setState(() {
          _namaUser = res["data"]["nama"] ?? "Teknisi";
        });
      }
    } catch (e) {
      setState(() => _namaUser = "Teknisi");
    }
  }


  void _onNavTap(int index) {
    // 🔴 LOGIKA PENGUNCIAN NAVBAR
    // Jika BELUM verifikasi DAN user klik menu selain Beranda(0) atau Lainnya(4)
    if (!_isVerified && !_isLoadingStatus) {
      if (index == 1 || index == 2 || index == 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Menu terkunci. Tunggu akun diverifikasi admin."),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
        return; // Stop, jangan pindah halaman
      }
    }

    setState(() => _currentIndex = index);

    // Navigasi Halaman
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeTeknisiPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PesananTeknisiPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RiwayatTeknisiPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileTeknisiPage.self())
        );
        break;
      case 4:
      // Tetap di halaman ini
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    final rootContext = context; // ⬅️ SIMPAN CONTEXT HALAMAN

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Anda yakin ingin keluar?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC918),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext); // ⬅️ TUTUP DIALOG DULU

                // Hapus session
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await ApiService.storage.deleteAll();

                // ⬇️ NAVIGASI PAKAI ROOT CONTEXT
                Navigator.of(rootContext).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      // Tambahkan RefreshIndicator agar user bisa tarik layar untuk cek status ulang
      body: RefreshIndicator(
        onRefresh: _checkVerificationStatus,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Wajib agar bisa ditarik
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),

              _buildSectionTitle("Preferensi"),
              _buildMenuCard([
                _buildMenuItem(Icons.security, "Keamanan akun"),

                _buildMenuItem(
                  Icons.payments,
                  "Pendapatan",
                  onTap: () {
                    // Proteksi menu dalam
                    if (!_isVerified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Fitur ini butuh verifikasi.")));
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PendapatanPage(),
                      ),
                    );
                  },
                ),
              ]),

              const SizedBox(height: 20),

              _buildSectionTitle("Lainnya"),
              _buildMenuCard([
                _buildMenuItem(
                  Icons.help_outline,
                  "Bantuan & Laporan",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BantuanLaporanPageTeknisi()),
                    );
                  },
                ),
                _buildMenuItem(
                  Icons.info_outline,
                  "Tentang Aplikasi",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TentangAplikasiPage()),
                    );
                  },
                ),
                _buildMenuItem(
                  Icons.privacy_tip_outlined,
                  "Kebijakan Privasi",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const KebijakanPrivasiPage()),
                    );
                  },
                ),
                _buildMenuItem(
                  Icons.logout,
                  "Keluar Akun",
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ]),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // ==== HEADER PROFIL ====
  Widget _buildHeader() {
    final auth = context.watch<AuthProvider>();
    final user = auth.userData;

    final foto = user?['foto_profile'];

    return Stack(
      children: [
        Container(
          height: 140,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_teknisi.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 90),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 🔥 FOTO TEKNISI
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    // Idealnya ganti dengan foto profil user dari API
                    child: Icon(Icons.person, size: 36, color: Colors.white),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _namaUser,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // === INDIKATOR STATUS (DINAMIS) ===
                        if (_isLoadingStatus)
                          const Text("Memuat status...", style: TextStyle(fontSize: 11, color: Colors.grey))
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: _isVerified ? Colors.green[100] : Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: _isVerified ? Colors.green : Colors.orange.withOpacity(0.5)
                                )
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isVerified ? Icons.check_circle : Icons.hourglass_top,
                                  size: 12,
                                  color: _isVerified ? Colors.green[800] : Colors.orange[800],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isVerified ? "Akun Terverifikasi" : "Menunggu Verifikasi",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: _isVerified ? Colors.green[800] : Colors.orange[800],
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ✏️ EDIT BUTTON
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black54),
                    onPressed: () async {
      final auth = context.read<AuthProvider>();
      final user = auth.userData;

      final updated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileEditTeknisiPage(
            currentName: user?['nama'] ?? '',
            currentEmail: user?['email'] ?? '',
            currentPhone: user?['no_hp'] ?? '',
          ),
        ),
      );

      if (updated == true) {
        // opsional: snackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
      }
    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }



  // ==== BAGIAN MENU ====
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
        child: Column(children: children),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ??
              () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title belum tersedia.")),
            );
          },
    );
  }

  // ==== CUSTOM BOTTOM NAV (SAMA SEPERTI HOMEPAGE) ====
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
      decoration: const BoxDecoration(
        color: Color(0xFF0C4481),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, -1))
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == _currentIndex;
          final item = items[i];

          // LOGIKA DISABLE:
          // Jika Loading atau Belum Verif -> Kunci item index 1,2,3
          bool isItemDisabled = !_isLoadingStatus && !_isVerified && (i != 0 && i != 4);

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onNavTap(i), // Panggil fungsi tap
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                decoration: BoxDecoration(
                  color: active
                      ? highlight.withOpacity(0.12)
                      : Colors.transparent,
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: isItemDisabled
                                ? Colors.grey.withOpacity(0.5)
                                : (active ? highlight : Colors.white),
                            size: 22,
                          ),
                          // Ikon Gembok Kecil jika dikunci
                          if(isItemDisabled)
                            const Positioned(
                              right: -2, top: -2,
                              child: Icon(Icons.lock, size: 10, color: Colors.white70),
                            )
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isItemDisabled
                            ? Colors.grey.withOpacity(0.5)
                            : (active ? highlight : Colors.white),
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
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}