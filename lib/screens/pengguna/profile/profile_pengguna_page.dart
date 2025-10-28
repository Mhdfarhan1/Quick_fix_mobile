import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/login_screen.dart';
import 'profile_edit_pengguna_page.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.158.125.178:8000/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('📡 Status code: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final userData =
            data is Map<String, dynamic> && data.containsKey('data')
                ? data['data']
                : data;

        setState(() {
          user = userData;
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = user?['id_user'];

      if (token == null || userId == null) return;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.158.125.178:8000/api/profile/upload-foto'),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['id_user'] = userId.toString()
        ..files.add(await http.MultipartFile.fromPath('foto_profile', file.path));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      debugPrint('📤 Upload Response: $resBody');

      final resJson = jsonDecode(resBody);

      if (response.statusCode == 200 && resJson['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto profil berhasil diperbarui")),
        );

        setState(() {
          user?['foto_profile'] = resJson['path'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal upload: ${resJson['message'] ?? 'Error'}")),
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
    await prefs.remove('token');
    await prefs.remove('user');

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
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: _loadUser,
            child: const Text("Gagal memuat profil. Coba lagi."),
          ),
        ),
      );
    }

    final userName = user?['nama'] ?? '-';
    final userEmail = user?['email'] ?? '-';
    final userPhone = user?['phone'] ?? '-';
    final userRole = user?['role'] ?? '-';
    final userPhoto = user?['foto_profile'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profilku", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===================== HEADER PROFIL =====================
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
                          child: (userPhoto == null ||
                                  userPhoto.toString().isEmpty)
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
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileEditPenggunaPage(
                              currentName: userName,
                              currentEmail: userEmail,
                              currentPhone: userPhone,
                            ),
                          ),
                        );
                      },
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
            profileMenu("Atur akun", Icons.settings),

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

  Widget profileMenu(String title, IconData icon, {String? trailing}) => Container(
        color: Colors.white,
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF0C4381)),
          title: Text(title),
          trailing: trailing != null
              ? Text(trailing,
                  style: const TextStyle(color: Color(0xFF0C4381)))
              : const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {},
        ),
      );
}
