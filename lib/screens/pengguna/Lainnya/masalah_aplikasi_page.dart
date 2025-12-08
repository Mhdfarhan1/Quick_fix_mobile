import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:quick_fix/services/api_service.dart';

class MasalahAplikasiPage extends StatefulWidget {
  const MasalahAplikasiPage({super.key});

  @override
  State<MasalahAplikasiPage> createState() => _MasalahAplikasiPageState();
}

class _MasalahAplikasiPageState extends State<MasalahAplikasiPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _lampiran;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F1FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        title: const Text(
          "Masalah Aplikasi",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF0C4481),
                        child: Icon(
                          CupertinoIcons.ant_fill,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Laporkan kendala terkait aplikasi yang Anda alami agar tim kami dapat segera memperbaikinya.",
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CARD FORM
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // JUDUL MASALAH
                            const Text(
                              "Judul Masalah",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _judulController,
                              hint: 'misal "Aplikasi tidak bisa login"',
                              prefixIcon: CupertinoIcons.doc_text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Judul masalah wajib diisi";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // DESKRIPSI MASALAH
                            const Text(
                              "Deskripsi Masalah (*)",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _deskripsiController,
                              hint:
                              "Jelaskan detail kendala aplikasi, langkah yang dilakukan, dan pesan error jika ada...",
                              maxLines: 4,
                              prefixIcon: CupertinoIcons.text_alignleft,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().length < 10) {
                                  return "Deskripsi minimal 10 karakter";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // LAMPIRAN
                            const Text(
                              "Lampiran Bukti (opsional)",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: _pickLampiran,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _lampiran == null
                                        ? Colors.grey.shade300
                                        : const Color(0xFF0C4481),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _lampiran == null
                                          ? CupertinoIcons.cloud_upload
                                          : CupertinoIcons.checkmark_seal_fill,
                                      size: 20,
                                      color: _lampiran == null
                                          ? Colors.grey.shade700
                                          : const Color(0xFF0C4481),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _lampiran == null
                                            ? "Upload screenshot / rekaman error"
                                            : "File terpilih: ${_lampiran!.name}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: _lampiran == null
                                              ? Colors.black54
                                              : Colors.black87,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_lampiran != null)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  "Lampiran akan dikirim bersama laporan.",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // BUTTON KIRIM
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C4481),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _submitForm,
                      child: const Text(
                        "Kirim Laporan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BUTTON BATAL
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD BUILDER
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, size: 20, color: Colors.grey.shade600),
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 13.5,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: Color(0xFF0C4481),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PICK LAMPIRAN
  // ============================================================

  Future<void> _pickLampiran() async {
    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (result != null) {
      setState(() {
        _lampiran = result;
      });
    }
  }

  // ============================================================
  // SUBMIT KE BACKEND
  // ============================================================

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() {}); // biar error validator muncul
      return;
    }

    // Ambil token dari secure storage
    final token = await ApiService.storage.read(key: "token");

    if (token == null || token.isEmpty) {
      _showErrorDialog(
        "Anda belum login atau sesi sudah habis.\nSilakan login ulang.",
      );
      return;
    }

    // Debug log (opsional)
    print("===== DEBUG MASALAH APLIKASI =====");
    print("TOKEN: Bearer $token");
    print("Judul: ${_judulController.text}");
    print("Deskripsi: ${_deskripsiController.text}");
    print("Lampiran: ${_lampiran?.path}");
    print("==================================");

    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF0C4481)),
      ),
    );

    try {
      final uri = Uri.parse("http://192.168.1.6:8000/api/complaints");

      var request = http.MultipartRequest("POST", uri);
      request.headers['Accept'] = "application/json";
      request.headers['Authorization'] = "Bearer $token";

      // Data yang dikirim
      request.fields['kategori'] = "aplikasi";
      request.fields['jenis_masalah'] = _judulController.text;
      request.fields['deskripsi'] = _deskripsiController.text;

      if (_lampiran != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "lampiran",
            _lampiran!.path,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("===== RESPONSE MASALAH APLIKASI =====");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: $responseBody");
      print("=====================================");

      Navigator.pop(context); // tutup loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      } else if (response.statusCode == 401) {
        _showErrorDialog(
          "Sesi login sudah tidak valid (401 Unauthorized).\nSilakan login ulang.",
        );
      } else {
        _showErrorDialog(
          "Gagal mengirim laporan.\n"
              "Status: ${response.statusCode}\n\n"
              "Response:\n$responseBody",
        );
      }
    } catch (e) {
      Navigator.pop(context); // tutup loading
      _showErrorDialog("Terjadi error: $e");
    }
  }

  // ============================================================
  // DIALOGS
  // ============================================================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Laporan terkirim",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text(
            "Terima kasih, laporan masalah aplikasi Anda sudah kami terima. "
                "Tim kami akan meninjau dan menindaklanjuti secepatnya.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          "Terjadi Kesalahan",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
