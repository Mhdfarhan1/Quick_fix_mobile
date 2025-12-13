import 'dart:convert';
import 'dart:io'; // Tambahan untuk File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

import '../../../services/api_service.dart';
import '../../../config/base_url.dart';
import '../../../screens/teknisi/home/home_page_teknisi.dart';

class VerifikasiTeknisiPage extends StatefulWidget {
  const VerifikasiTeknisiPage({Key? key}) : super(key: key);

  @override
  State<VerifikasiTeknisiPage> createState() => _VerifikasiTeknisiPageState();
}

class _VerifikasiTeknisiPageState extends State<VerifikasiTeknisiPage> {
  // Warna Utama (Biru QuickFix)
  final Color _primaryColor = const Color(0xFF0C4481);
  final Color _backgroundColor = const Color(0xFFF8F9FD);

  // Controller
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _rekeningController = TextEditingController();
  final TextEditingController _namaAkunRekeningController = TextEditingController();
  final TextEditingController _bankCodeController = TextEditingController();
  final TextEditingController _expiredSkckController = TextEditingController();

  String? selectedBank;
  DateTime? _selectedExpiredDate;

  // List bank + kode
  final Map<String, String> bankList = {
    "BCA": "014",
    "Mandiri": "008",
    "BRI": "002",
    "BNI": "009",
    "BTN": "200",
    "CIMB Niaga": "022",
    "Maybank": "016",
    "Permata Bank": "013",
    "Danamon": "011",
  };

  // Data wilayah
  List<dynamic> provinsiList = [];
  List<dynamic> kotaList = [];
  List<dynamic> kecamatanList = [];

  String? selectedProvinsiId;
  String? selectedKotaId;
  String? selectedKecamatanId;

  String? selectedProvinsiName;
  String? selectedKotaName;
  String? selectedKecamatanName;

  // File
  XFile? _ktpFile;
  XFile? _skckFile;
  final ImagePicker picker = ImagePicker();

  bool _isLoading = false; // Untuk indikator loading saat submit

  @override
  void initState() {
    super.initState();
    loadProvinsi();
  }

  // ===================== DATE PICKER (SKCK) =====================
  Future<void> _selectExpiredDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedExpiredDate) {
      setState(() {
        _selectedExpiredDate = picked;
        _expiredSkckController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // ===================== LOAD WILAYAH =====================
  Future<void> loadProvinsi() async {
    try {
      final url = Uri.parse("https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() {
          provinsiList = jsonDecode(res.body);
        });
      }
    } catch (e) {
      print("Error load provinsi: $e");
    }
  }

  Future<void> loadKota(String provId) async {
    try {
      final url = Uri.parse("https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provId.json");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() {
          kotaList = jsonDecode(res.body);
          kecamatanList = []; // Reset kecamatan
          selectedKotaId = null;
          selectedKecamatanId = null;
        });
      }
    } catch (e) {
      print("Error load kota: $e");
    }
  }

  Future<void> loadKecamatan(String kotaId) async {
    try {
      final url = Uri.parse("https://www.emsifa.com/api-wilayah-indonesia/api/districts/$kotaId.json");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() {
          kecamatanList = jsonDecode(res.body);
          selectedKecamatanId = null;
        });
      }
    } catch (e) {
      print("Error load kecamatan: $e");
    }
  }

  // ===================== PICK IMAGE =====================
  Future<void> pickImage(String type) async {
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img == null) return;
    setState(() {
      if (type == "ktp") _ktpFile = img;
      if (type == "skck") _skckFile = img;
    });
  }

  // ===================== SUBMIT =====================
  Future<void> submitData() async {
    // Validasi Input
    if (selectedProvinsiName == null || selectedKotaName == null || selectedKecamatanName == null) {
      return showMsg("Mohon lengkapi data wilayah.", isError: true);
    }
    if (_nikController.text.length != 16) {
      return showMsg("NIK harus 16 digit.", isError: true);
    }
    if (_ktpFile == null || _skckFile == null) {
      return showMsg("Wajib upload foto KTP dan SKCK.", isError: true);
    }
    if (_expiredSkckController.text.isEmpty) {
      return showMsg("Tentukan masa berlaku SKCK.", isError: true);
    }
    if (selectedBank == null || _rekeningController.text.isEmpty) {
      return showMsg("Lengkapi data rekening bank.", isError: true);
    }

    setState(() => _isLoading = true);

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        showMsg("Sesi habis, silakan login ulang.", isError: true);
        setState(() => _isLoading = false);
        return;
      }

      final uri = Uri.parse("${BaseUrl.api}/verifikasi-teknisi");
      final req = http.MultipartRequest("POST", uri);

      req.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // Data Text
      req.fields.addAll({
        "provinsi": selectedProvinsiName!,
        "kabupaten": selectedKotaName!,
        "kecamatan": selectedKecamatanName!,
        "nik": _nikController.text,
        "rekening": _rekeningController.text,
        "bank": selectedBank!,
        "bank_code": _bankCodeController.text,
        "nama_akun_rekening": _namaAkunRekeningController.text,
        "skck_expired": _expiredSkckController.text,
      });

      // Data File
      req.files.add(await http.MultipartFile.fromPath("ktp", _ktpFile!.path));
      req.files.add(await http.MultipartFile.fromPath("skck", _skckFile!.path));

      final res = await req.send();
      final bodyStr = await res.stream.bytesToString();

      setState(() => _isLoading = false);

      print("STATUS: ${res.statusCode}");
      print("BODY: $bodyStr");

      if (res.statusCode == 201 || res.statusCode == 200) {
        _showSuccessDialog();
      } else {
        try {
          final jsonErr = jsonDecode(bodyStr);
          showMsg(jsonErr['message'] ?? "Gagal mengirim data.", isError: true);
        } catch (_) {
          showMsg("Terjadi kesalahan server.", isError: true);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showMsg("Koneksi bermasalah: $e", isError: true);
    }
  }

  void showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text("Berhasil Terkirim!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "Data verifikasi Anda telah dikirim ke Admin. Mohon tunggu proses verifikasi.",
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeTeknisiPage()),
                );
              },
              child: const Text(
                "Kembali ke Beranda",
                style: TextStyle(
                  color: Colors.white, // <--- Ubah warna jadi putih di sini
                  fontWeight: FontWeight.bold, // (Opsional) Agar tulisan lebih tebal
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== UI WIDGETS =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Verifikasi Data Diri",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white, // <--- UBAH WARNA TEKS JADI PUTIH
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        // Tambahkan ini agar tombol panah kembali (back button) juga putih
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderInfo(),
            const SizedBox(height: 24),

            // SECTION 1: WILAYAH & IDENTITAS
            _buildSectionLabel("Data Wilayah & Identitas"),
            _buildCardContainer(
              children: [
                _buildDropdown("Provinsi", provinsiList, selectedProvinsiId, (val) {
                  selectedProvinsiId = val;
                  selectedProvinsiName = provinsiList.firstWhere((e) => e['id'].toString() == val)['name'];
                  loadKota(val!);
                }),
                const SizedBox(height: 16),
                _buildDropdown("Kota / Kabupaten", kotaList, selectedKotaId, (val) {
                  selectedKotaId = val;
                  selectedKotaName = kotaList.firstWhere((e) => e['id'].toString() == val)['name'];
                  loadKecamatan(val!);
                }),
                const SizedBox(height: 16),
                _buildDropdown("Kecamatan", kecamatanList, selectedKecamatanId, (val) {
                  selectedKecamatanId = val;
                  selectedKecamatanName = kecamatanList.firstWhere((e) => e['id'].toString() == val)['name'];
                }),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nikController,
                  label: "NIK (KTP)",
                  hint: "16 Digit Angka",
                  icon: Icons.badge_outlined,
                  inputType: TextInputType.number,
                  maxLength: 16,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // SECTION 2: DOKUMEN
            _buildSectionLabel("Upload Dokumen"),
            _buildCardContainer(
              children: [
                _buildUploadBox("Foto KTP", _ktpFile, () => pickImage("ktp")),
                const SizedBox(height: 16),
                _buildUploadBox("Foto SKCK", _skckFile, () => pickImage("skck")),
                const SizedBox(height: 16),

                // Date Picker SKCK
                GestureDetector(
                  onTap: () => _selectExpiredDate(context),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: _expiredSkckController,
                      label: "Masa Berlaku SKCK",
                      hint: "Pilih Tanggal",
                      icon: Icons.calendar_month,
                      isReadOnly: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // SECTION 3: REKENING
            _buildSectionLabel("Informasi Bank"),
            _buildCardContainer(
              children: [
                _buildDropdownBank(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _bankCodeController,
                  label: "Kode Bank",
                  hint: "Otomatis",
                  icon: Icons.numbers,
                  isReadOnly: true,
                  fillColor: Colors.grey[100],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _rekeningController,
                  label: "Nomor Rekening",
                  hint: "Contoh: 1234567890",
                  icon: Icons.credit_card,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _namaAkunRekeningController,
                  label: "Nama Pemilik Rekening",
                  hint: "Sesuai Buku Tabungan",
                  icon: Icons.person_outline,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: _primaryColor.withOpacity(0.4),
                ),
                child: const Text(
                  "Kirim Verifikasi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeaderInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: _primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Lengkapi data di bawah ini agar akun teknisi Anda dapat diverifikasi oleh Admin.",
              style: TextStyle(fontSize: 13, color: Colors.blue[900]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool isReadOnly = false,
    int? maxLength,
    Color? fillColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          readOnly: isReadOnly,
          maxLength: maxLength,
          style: TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(icon, color: _primaryColor, size: 20),
            filled: true,
            fillColor: fillColor ?? Colors.white,
            counterText: "",
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List items, String? value, Function(String?) onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text("Pilih $label", style: TextStyle(fontSize: 13, color: Colors.grey[400])),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: items.map((e) {
                return DropdownMenuItem(
                  value: e['id'].toString(),
                  child: Text(e['name'], style: TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (v) {
                onChange(v);
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownBank() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Nama Bank", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedBank,
              isExpanded: true,
              hint: Text("Pilih Bank", style: TextStyle(fontSize: 13, color: Colors.grey[400])),
              icon: Icon(Icons.account_balance, color: _primaryColor, size: 20),
              items: bankList.keys.map((bank) {
                return DropdownMenuItem(
                  value: bank,
                  child: Text(bank, style: TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBank = value;
                  _bankCodeController.text = bankList[value] ?? "";
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox(String title, XFile? file, VoidCallback onTap) {
    bool isUploaded = file != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 80,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isUploaded ? Colors.blue[50] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUploaded ? _primaryColor : Colors.grey[300]!,
                style: isUploaded ? BorderStyle.solid : BorderStyle.solid, // Bisa ganti dotted jika pakai package
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUploaded ? Colors.white : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isUploaded ? Icons.check_circle : Icons.cloud_upload_outlined,
                    color: isUploaded ? Colors.green : _primaryColor,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isUploaded ? "File Terpilih" : "Tap untuk Upload",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isUploaded ? _primaryColor : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        isUploaded ? p.basename(file.path) : "Format: JPG/PNG",
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if(isUploaded) Icon(Icons.edit, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}