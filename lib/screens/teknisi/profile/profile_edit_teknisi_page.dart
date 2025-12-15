import 'package:flutter/material.dart';
import '../../../services/api_service.dart'; // path sesuai project Anda
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart'; // contoh jika token disimpan di provider

class ProfileEditTeknisiPage extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String currentPhone;

  // optional: Anda bisa pass token secara langsung atau ambil dari Provider dalam state
  final String? authToken;

  const ProfileEditTeknisiPage({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.currentPhone,
    this.authToken,
  });

  @override
  State<ProfileEditTeknisiPage> createState() =>
      _ProfileEditTeknisiPageState();
}

class _ProfileEditTeknisiPageState extends State<ProfileEditTeknisiPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _phoneController = TextEditingController(text: widget.currentPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
    final emailRegex = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[\w]{2,4}$");
    if (!emailRegex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return null; // boleh kosong
    // Validasi sederhana: hanya angka dan +, 6..30 panjang
    final phoneRegex = RegExp(r'^[\d\+\-\s]{6,30}$');
    if (!phoneRegex.hasMatch(value)) return 'Format nomor telepon tidak valid';
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0C4481)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return '$label tidak boleh kosong';
              }
              return null;
            },
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Ambil token: prioritas parameter, kalau null coba ambil dari Provider
    String? token = widget.authToken;
    if (token == null) {
      try {
        // contoh jika anda menyimpan token di AuthProvider
        final authProv = Provider.of<AuthProvider>(context, listen: false);
        token = authProv.token; // sesuaikan properti token
      } catch (_) {
        token = null;
      }
    }

    // Tambahkan setelah cek Provider
    if (token == null || token.isEmpty) {
      token = await ApiService.storage.read(key: 'token');
    }


    if (token == null || token.isEmpty) {
      setState(() => _isLoading = false);
      // Tampilkan pesan error bila token tidak tersedia
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token autentikasi tidak ditemukan. Silakan login ulang.')),
      );
      return;
    }

    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPhone = _phoneController.text.trim();

    final result = await ApiService.updateProfile(
      token: token,
      nama: newName,
      email: newEmail,
      noHp: newPhone.isEmpty ? null : newPhone,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final serverUser = result['data']?['data'];

      if (serverUser != null) {
        // 🔥 UPDATE AUTH PROVIDER AGAR UI LANGSUNG REFRESH
        final authProv = Provider.of<AuthProvider>(context, listen: false);
        authProv.setUser(serverUser);
      }

      Navigator.pop(context, true); // cukup true
    } else {
      // Tangani error (validasi 422 atau error lain)
      if (result['status'] == 422 && result['errors'] != null) {
        final errors = result['errors'];
        // Ambil pesan error field (jika ada)
        String message = 'Validasi gagal';
        if (errors is Map) {
          final firstKey = errors.keys.first;
          final firstMsg = errors[firstKey] is List ? errors[firstKey][0] : errors[firstKey];
          message = firstMsg.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } else {
        final msg = result['message'] ?? 'Gagal memperbarui profil';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0C4481),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),

              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person,
              ),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),

              _buildTextField(
                controller: _phoneController,
                label: 'Nomor Telepon',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC33),
                  foregroundColor: const Color(0xFF0C4481),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
