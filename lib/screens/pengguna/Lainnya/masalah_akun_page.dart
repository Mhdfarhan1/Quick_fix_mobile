import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MasalahAkunPage extends StatefulWidget {
  const MasalahAkunPage({super.key});

  @override
  State<MasalahAkunPage> createState() => _MasalahAkunPageState();
}

class _MasalahAkunPageState extends State<MasalahAkunPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _kontakController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  String? _jenisMasalah;
  final List<String> _listMasalah = const [
    "Tidak bisa login",
    "Lupa kata sandi",
    "Email / nomor tidak bisa diganti",
    "Akun terblokir",
    "Profil tidak bisa di perbarui",
  ];

  final ImagePicker _picker = ImagePicker();
  XFile? _lampiran;

  @override
  void dispose() {
    _kontakController.dispose();
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
          "Masalah Akun",
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
                          CupertinoIcons.person_crop_circle_badge_exclam,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Laporkan kendala terkait akun seperti login, kata sandi, atau perubahan data agar tim kami dapat segera membantu.",
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
                            // EMAIL / NO HP
                            const Text(
                              "Email/ No.hp",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _kontakController,
                              hint: "Email atau nomor HP yang digunakan di akun",
                              prefixIcon: CupertinoIcons.at,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email / No.hp wajib diisi";
                                }
                                return null;
                              },
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
                              "Ceritakan detail kendala akun, termasuk pesan error atau langkah yang sudah dicoba...",
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
                                            ? "Upload screenshot / foto terkait masalah akun"
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

  void _submitForm() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || _jenisMasalah == null) {
      setState(() {});
      return;
    }

    // TODO: kirim data ke backend (sertakan _lampiran kalau tidak null)
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
            "Terima kasih, laporan masalah akun Anda sudah kami terima. "
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
}
