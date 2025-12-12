import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quick_fix/services/api_service.dart';


class MasalahPesananPage extends StatefulWidget {
  const MasalahPesananPage({super.key});

  @override
  State<MasalahPesananPage> createState() => _MasalahPesananPageState();
}

class _MasalahPesananPageState extends State<MasalahPesananPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomorPesananController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  String? _jenisMasalah;
  final List<String> _listMasalah = const [
    "Teknisi tidak datang",
    "Pesanan tidak sesuai deskripsi",
    "Pesanan dibatalkan sepihak",
    "Status pesanan tidak berubah",
    "Kendala komunikasi dengan teknisi",
  ];

  final ImagePicker _picker = ImagePicker();
  XFile? _lampiran;

  @override
  void dispose() {
    _nomorPesananController.dispose();
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
          "Masalah Pesanan",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildFormCard(),
              const SizedBox(height: 25),
              _buildSubmitButton(),
              const SizedBox(height: 10),
              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UI COMPONENTS
  // ============================================================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFF0C4481),
          child: Icon(
            CupertinoIcons.exclamationmark_bubble_fill,
            size: 20,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            "Laporkan kendala terkait pesanan yang Anda alami agar tim kami dapat menindaklanjuti.",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldTitle("Nomor Pesanan"),
              _buildTextField(
                controller: _nomorPesananController,
                hint: "Masukkan nomor pesanan",
                prefixIcon: CupertinoIcons.number,
                validator: (v) =>
                v == null || v.isEmpty ? "Nomor pesanan wajib diisi" : null,
              ),

              const SizedBox(height: 16),

              _fieldTitle("Pilih Jenis Masalah"),
              _buildDropdown(),

              const SizedBox(height: 16),

              _fieldTitle("Deskripsi Masalah (*)"),
              _buildTextField(
                controller: _deskripsiController,
                hint: "Jelaskan kendala Anda...",
                maxLines: 4,
                prefixIcon: CupertinoIcons.text_alignleft,
                validator: (v) => v == null || v.trim().length < 10
                    ? "Deskripsi minimal 10 karakter"
                    : null,
              ),

              const SizedBox(height: 16),

              _fieldTitle("Lampiran Bukti (opsional)"),
              _buildUploadBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _jenisMasalah,
              hint: const Text("Pilih jenis masalah"),
              isExpanded: true,
              items: _listMasalah
                  .map(
                    (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _jenisMasalah = value;
                });
              },
            ),
          ),
        ),
        if (_jenisMasalah == null)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              "Jenis masalah wajib dipilih",
              style: TextStyle(fontSize: 11, color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadBox() {
    return GestureDetector(
      onTap: _pickLampiran,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    ? "Upload file / foto bukti"
                    : "File terpilih: ${_lampiran!.name}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                  _lampiran == null ? Colors.black54 : Colors.black87,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C4481),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _submitForm,
        child: const Text(
          "Kirim Laporan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.5),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          borderSide: BorderSide(color: Color(0xFF0C4481), width: 1.4),
        ),
      ),
    );
  }

  // ============================================================
  // PICK IMAGE
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
  // API SUBMIT
  // ============================================================

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || _jenisMasalah == null) {
      setState(() {});
      return;
    }

    // =====================
// AMBIL TOKEN DARI SECURE STORAGE
// =====================

    final token = await ApiService.storage.read(key: "token");

    print("===== DEBUG TOKEN =====");
    print("TOKEN DARI SECURE STORAGE: $token");
    print("=======================");

    if (token == null || token.isEmpty) {
      _showErrorDialog("Anda belum login atau sesi sudah habis.\nSilakan login ulang.");
      return;
    }

    print("===== DEBUG INFO =====");
    print("TOKEN: Bearer $token");
    print("Nomor Pesanan: ${_nomorPesananController.text}");
    print("Jenis Masalah: $_jenisMasalah");
    print("Deskripsi: ${_deskripsiController.text}");
    print("Lampiran: ${_lampiran?.path}");
    print("=======================");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF0C4481)),
      ),
    );

    try {
      // GANTI IP ini kalau backend kamu beda
      final uri = Uri.parse("http://10.202.59.178:8000/api/complaints");

      var request = http.MultipartRequest("POST", uri);
      request.headers['Accept'] = "application/json";
      request.headers['Authorization'] = "Bearer $token";

      request.fields['kategori'] = "pesanan";
      request.fields['nomor_pesanan'] = _nomorPesananController.text;
      request.fields['jenis_masalah'] = _jenisMasalah!;
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

      print("===== RESPONSE =====");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: $responseBody");
      print("====================");

      Navigator.pop(context);

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
      Navigator.pop(context);
      _showErrorDialog("Error: $e");
    }
  }

  // ============================================================
  // POPUPS
  // ============================================================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Laporan terkirim",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          "Terima kasih! Laporan Anda sudah kami terima.",
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
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Terjadi Kesalahan"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
