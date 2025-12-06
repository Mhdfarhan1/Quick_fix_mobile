import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:quick_fix/services/api_service.dart';

class MasalahPembayaranPage extends StatefulWidget {
  const MasalahPembayaranPage({super.key});

  @override
  State<MasalahPembayaranPage> createState() => _MasalahPembayaranPageState();
}

class _MasalahPembayaranPageState extends State<MasalahPembayaranPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _metodePembayaranController =
  TextEditingController();
  final TextEditingController _nominalIdController = TextEditingController();
  final TextEditingController _nomorTujuanController = TextEditingController();
  final TextEditingController _namaTujuanController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  String? _jenisMasalah;
  final List<String> _listMasalah = const [
    "Pembayaran gagal",
    "Pembayaran berhasil tapi pesanan tidak masuk",
    "Refund belum diterima",
    "Pembayaran ganda",
  ];

  final ImagePicker _picker = ImagePicker();
  XFile? _lampiran;

  @override
  void dispose() {
    _metodePembayaranController.dispose();
    _nominalIdController.dispose();
    _nomorTujuanController.dispose();
    _namaTujuanController.dispose();
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
          "Masalah Pembayaran",
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
                          CupertinoIcons.creditcard_fill,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Laporkan kendala terkait pembayaran yang Anda alami saat menggunakan aplikasi agar tim kami dapat segera menindaklanjuti.",
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
                            // METODE PEMBAYARAN
                            const Text(
                              "Metode Pembayaran",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _metodePembayaranController,
                              hint:
                              "Contoh: DANA, OVO, BCA Mobile, BRI, Mandiri, BNI, ShopeePay, dll",
                              prefixIcon: CupertinoIcons.creditcard,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Metode pembayaran wajib diisi";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // NOMINAL / ID PEMBAYARAN
                            const Text(
                              "Nominal / ID Pembayaran",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _nominalIdController,
                              hint:
                              "Masukkan nominal atau ID pembayaran (jika ada)",
                              prefixIcon: CupertinoIcons.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Nominal / ID pembayaran wajib diisi";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // NOMOR TUJUAN
                            const Text(
                              "Nomor Tujuan (Rekening / No. HP / VA)",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _nomorTujuanController,
                              hint:
                              "Contoh: 08123456789 / 1234567890 / 3901xxxxxxxxx (opsional, tapi sangat membantu)",
                              prefixIcon: CupertinoIcons.phone,
                              validator: null, // opsional
                            ),

                            const SizedBox(height: 16),

                            // NAMA TUJUAN
                            const Text(
                              "Nama Pemilik Akun / Rekening",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _namaTujuanController,
                              hint:
                              "Nama pemilik rekening / akun pembayaran (opsional)",
                              prefixIcon: CupertinoIcons.person,
                              validator: null, // opsional
                            ),

                            const SizedBox(height: 16),

                            // JENIS MASALAH
                            const Text(
                              "Pilih Jenis Masalah",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _jenisMasalah,
                                  hint: const Text("Pilih jenis masalah"),
                                  isExpanded: true,
                                  items: _listMasalah
                                      .map(
                                        (e) => DropdownMenuItem<String>(
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
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.red),
                                ),
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
                              "Jelaskan detail kendala pembayaran, termasuk waktu transaksi dan nominal jika perlu...",
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
                                    horizontal: 12, vertical: 12),
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
                                            ? "Upload bukti pembayaran (screenshot / foto)"
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
                                      color: Colors.black54),
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
  // WIDGET TEXT FIELD
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
        hintStyle:
        TextStyle(color: Colors.grey.shade500, fontSize: 13.5),
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
          borderSide:
          BorderSide(color: Color(0xFF0C4481), width: 1.4),
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
  // SUBMIT FORM KE BACKEND
  // ============================================================

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || _jenisMasalah == null) {
      setState(() {}); // untuk munculkan error dropdown
      return;
    }

    // AMBIL TOKEN DARI SECURE STORAGE
    final token = await ApiService.storage.read(key: "token");

    if (token == null || token.isEmpty) {
      _showErrorDialog(
        "Anda belum login atau sesi sudah habis.\nSilakan login ulang.",
      );
      return;
    }

    // Debug log (opsional)
    print("===== DEBUG PEMBAYARAN =====");
    print("TOKEN: Bearer $token");
    print("Metode Pembayaran: ${_metodePembayaranController.text}");
    print("Nominal / ID: ${_nominalIdController.text}");
    print("Nomor Tujuan: ${_nomorTujuanController.text}");
    print("Nama Tujuan: ${_namaTujuanController.text}");
    print("Jenis Masalah: $_jenisMasalah");
    print("Deskripsi: ${_deskripsiController.text}");
    print("Lampiran: ${_lampiran?.path}");
    print("============================");

    // TAMPILKAN LOADING
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

      // DATA YANG DIKIRIM
      request.fields['kategori'] = "pembayaran";
      request.fields['metode_pembayaran'] =
          _metodePembayaranController.text;
      request.fields['nominal_id'] = _nominalIdController.text;
      request.fields['nomor_tujuan'] = _nomorTujuanController.text;
      request.fields['nama_tujuan'] = _namaTujuanController.text;
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

      print("===== RESPONSE PEMBAYARAN =====");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: $responseBody");
      print("================================");

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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Laporan terkirim",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          "Terima kasih, laporan pembayaran Anda sudah kami terima. "
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
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
