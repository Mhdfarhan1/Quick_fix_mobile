import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import 'package:quick_fix/screens/pengguna/Lainnya/riwayat_komplain_page.dart';
import 'package:quick_fix/screens/pengguna/Lainnya/bantuan_laporan_page.dart';


import '../../auth/login_screen.dart';
import 'profile_edit_pengguna_page.dart';
import '../../../config/base_url.dart';
import '../Lainnya/Lainnya_route.dart';
import '../../../widgets/user_bottom_nav.dart';

class ProfilePenggunaPage extends StatefulWidget {
  const ProfilePenggunaPage({super.key});

  @override
  State<ProfilePenggunaPage> createState() => _ProfilePenggunaPageState();
}

class _ProfilePenggunaPageState extends State<ProfilePenggunaPage> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ====================== MUAT DATA USER DARI API ======================
  Future<void> _loadUser() async {
    final token = await ApiService.storage.read(key: 'token');

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.api}/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('📡 Status code: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data is Map<String, dynamic> && data.containsKey('data')
            ? data['data']
            : data;

        setState(() {
          user = userData;
          if (user!['foto_profile'] != null && user!['foto_profile'].toString().isNotEmpty) {
            // gabungkan BaseUrl.server + storage path
            user!['foto_profile'] = '${BaseUrl.server}/storage/foto/foto_teknisi/${user!['foto_profile']}';
          }

          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        _logout();
      } else {
        debugPrint('❌ Gagal ambil profil: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error saat ambil profil: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _openEdit() async {
    if (user == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileEditPenggunaPage(
          currentName: user?['nama'],
          currentEmail: user?['email'],
          currentPhone: user?['no_hp'],
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        user?['nama'] = result['name'] ?? user?['nama'];
        user?['email'] = result['email'] ?? user?['email'];
        user?['no_hp'] = result['phone'] ?? user?['no_hp'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil diperbarui')),
      );

      _loadUser(); // refresh data
    }
  }

  // ====================== UPLOAD FOTO PROFIL ======================
  Future<void> _pickAndUploadPhoto() async {
    if (user == null) return;

    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    setState(() => isUploading = true);

    try {
      final token = await ApiService.storage.read(key: 'token');
      final userId = user?['id_user'];

      if (token == null || userId == null) return;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseUrl.api}/profile/uploadFoto'),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['id_user'] = userId.toString()
        ..files.add(await http.MultipartFile.fromPath(
          'foto_profile',
          file.path,
          filename: file.path.split("/").last,
        ));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final resJson = jsonDecode(resBody);

      debugPrint('📤 Upload Response: $resBody');

      if (response.statusCode == 200 && resJson['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto profil berhasil diperbarui")),
        );

        setState(() {
          // backend sudah mengirim URL lengkap via asset()
          user?['foto_profile'] = '${BaseUrl.server}/storage/foto/foto_teknisi/${resJson['filename']}';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Gagal upload: ${resJson['message'] ?? 'Terjadi kesalahan'}")),
        );
      }
    } catch (e) {
      debugPrint('❌ Error upload foto: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Terjadi kesalahan")));
    } finally {
      setState(() => isUploading = false);
    }
  }

  // ====================== LOGOUT ======================
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await ApiService.storage.delete(key: 'token');
    await prefs.clear();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // ====================== BUILD UI ======================
  @override
  Widget build(BuildContext context) {
    final userName = user?['nama'] ?? '-';
    final userEmail = user?['email'] ?? '-';
    final userRole = user?['role'] ?? '-';
    final userPhoto = (user?['foto_profile'] != null && user!['foto_profile'].toString().isNotEmpty)
          ? user!['foto_profile']  // sudah lengkap dari _loadUser()
          : null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profilku",
            style: TextStyle(color: Color.fromARGB(255, 234, 234, 234))),
        backgroundColor: const Color(0xFF0C4481),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== HEADER PROFIL =====
            Container(
              color: const Color(0xFF0C4381),
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFFFFCC33),
                          backgroundImage: (userPhoto != null &&
                                  userPhoto.toString().isNotEmpty)
                              ? NetworkImage(userPhoto)
                              : null,
                          child: (userPhoto == null || userPhoto.isEmpty)
                              ? Text(
                                  userName.isNotEmpty
                                      ? userName
                                          .split(' ')
                                          .map((e) => e[0])
                                          .take(2)
                                          .join()
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: isUploading ? null : _pickAndUploadPhoto,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: isUploading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEmail,
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Role: $userRole",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF0C4381)),
                      onPressed: _openEdit,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            sectionTitle("Preferensi"),
            profileMenu("Keamanan akun", Icons.lock_outline),
            profileMenu("Alamat tersimpan", Icons.bookmark_outline),

            const SizedBox(height: 20),
            sectionTitle("Aktivitas di QuickFix"),
            profileMenu("Aktivitas", Icons.history),

            const SizedBox(height: 20),
            sectionTitle("Lainnya"),
            profileMenu("Bantuan & laporan", Icons.help_outline),
            profileMenu("Kebijakan Privasi", Icons.privacy_tip_outlined),
            profileMenu(
              "Riwayat Komplain",
              Icons.receipt_long,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RiwayatKomplainPage()),
                );
              },
            ),
            profileMenu("Tentang Aplikasi", Icons.info_outline),

            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Keluar",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNav(selectedIndex: 4),
    );
  }

  // ===================== FUNGSI TAMBAHAN =====================
  Widget sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      );

  Widget profileMenu(String title, IconData icon,
      {String? trailing, VoidCallback? onTap}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0C4381)),
        title: Text(title),
        trailing: trailing != null
            ? Text(
                trailing,
                style: const TextStyle(color: Color(0xFF0C4381)),
              )
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap ??
            () {
              switch (title) {
                case "Keamanan akun":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const KeamananAkunPage()),
                  );
                  break;
                case "Alamat tersimpan":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PilihAlamatPage()),
                  );
                  break;
                case "Aktivitas":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AktivitasPage()),
                  );
                  break;
                case "Bantuan & laporan":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BantuanLaporanPage()),
                  );
                  break;
                case "Kebijakan Privasi":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const KebijakanPrivasiPage()),
                  );
                  break;
                case "Tentang Aplikasi":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TentangAplikasiPage()),
                  );
                  break;
              }
            },
      ),
    );
  }
}
