import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../../../services/api_service.dart';
import '../../../config/base_url.dart';
import '../../../screens/teknisi/home/home_page_teknisi.dart';

class VerifikasiTeknisiPage extends StatefulWidget {
  const VerifikasiTeknisiPage({Key? key}) : super(key: key);

  @override
  State<VerifikasiTeknisiPage> createState() => _VerifikasiTeknisiPageState();
}

class _VerifikasiTeknisiPageState extends State<VerifikasiTeknisiPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _rekeningController = TextEditingController();
  final TextEditingController _namaAkunRekeningController =
      TextEditingController();
  final TextEditingController _bankCodeController = TextEditingController();

  String? selectedBank;

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

  @override
  void initState() {
    super.initState();
    loadProvinsi();
  }

  // ===================== LOAD WILAYAH =====================

  Future<void> loadProvinsi() async {
    final url = Uri.parse(
      "https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json",
    );
    final res = await http.get(url);

    if (res.statusCode == 200) {
      provinsiList = jsonDecode(res.body);
      setState(() {});
    }
  }

  Future<void> loadKota(String provId) async {
    final url = Uri.parse(
      "https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provId.json",
    );
    final res = await http.get(url);

    if (res.statusCode == 200) {
      kotaList = jsonDecode(res.body);
      kecamatanList = [];
      setState(() {});
    }
  }

  Future<void> loadKecamatan(String kotaId) async {
    final url = Uri.parse(
      "https://www.emsifa.com/api-wilayah-indonesia/api/districts/$kotaId.json",
    );
    final res = await http.get(url);

    if (res.statusCode == 200) {
      kecamatanList = jsonDecode(res.body);
      setState(() {});
    }
  }

  // ===================== PICK IMAGE =====================

  Future<void> pickImage(String type) async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    setState(() {
      if (type == "ktp") _ktpFile = img;
      if (type == "skck") _skckFile = img;
    });
  }

  // ===================== SUBMIT =====================

  Future<void> submitData() async {
    // Validasi dasar (client side)
    if (selectedProvinsiName == null ||
        selectedKotaName == null ||
        selectedKecamatanName == null) {
      return showMsg("Wilayah belum lengkap.");
    }

    if (_nikController.text.length != 16) {
      return showMsg("NIK harus 16 digit.");
    }

    if (_rekeningController.text.isEmpty) {
      return showMsg("Nomor rekening wajib diisi.");
    }

    if (_namaAkunRekeningController.text.isEmpty) {
      return showMsg("Nama pemilik rekening wajib diisi.");
    }

    if (selectedBank == null) {
      return showMsg("Pilih bank terlebih dahulu.");
    }

    if (_bankCodeController.text.isEmpty) {
      return showMsg("Kode bank tidak valid.");
    }

    if (_ktpFile == null || _skckFile == null) {
      return showMsg("Lengkapi semua dokumen (KTP dan SKCK).");
    }

    final token = await ApiService.getToken();
    if (token == null) {
      return showMsg("Token tidak ditemukan. Silakan login ulang.");
    }

    final uri = Uri.parse("${BaseUrl.api}/verifikasi-teknisi");
    final req = http.MultipartRequest("POST", uri);

    req.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    // === NAMA FIELD HARUS SAMA DENGAN VALIDASI LARAVEL ===
    req.fields.addAll({
      "provinsi": selectedProvinsiName!,
      "kabupaten": selectedKotaName!,
      "kecamatan": selectedKecamatanName!,
      "nik": _nikController.text,
      "rekening": _rekeningController.text,
      "bank": selectedBank!,
      "bank_code": _bankCodeController.text,
      "nama_akun_rekening": _namaAkunRekeningController.text,
    });

    // File
    req.files.add(await http.MultipartFile.fromPath("ktp", _ktpFile!.path));
    req.files.add(await http.MultipartFile.fromPath("skck", _skckFile!.path));

    final res = await req.send();
    final body = await http.Response.fromStream(res);

    print("STATUS = ${res.statusCode}");
    print("BODY   = ${body.body}");

    if (res.statusCode == 201) {
      showMsg("Data berhasil dikirim");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeTeknisiPage()),
      );
    } else {
      showMsg("Gagal: ${body.body}");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Profile Usaha"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wilayah
            dropdownWilayah("Provinsi *", provinsiList, selectedProvinsiId, (
              v,
            ) {
              selectedProvinsiId = v;
              selectedKotaId = null;
              selectedKecamatanId = null;
              selectedProvinsiName = provinsiList.firstWhere(
                (e) => e['id'].toString() == v,
              )['name'];
              loadKota(v!);
            }),
            const SizedBox(height: 16),

            dropdownWilayah("Kabupaten / Kota *", kotaList, selectedKotaId, (
              v,
            ) {
              selectedKotaId = v;
              selectedKotaName = kotaList.firstWhere(
                (e) => e['id'].toString() == v,
              )['name'];
              loadKecamatan(v!);
            }),
            const SizedBox(height: 16),

            dropdownWilayah("Kecamatan *", kecamatanList, selectedKecamatanId, (
              v,
            ) {
              selectedKecamatanId = v;
              selectedKecamatanName = kecamatanList.firstWhere(
                (e) => e['id'].toString() == v,
              )['name'];
            }),
            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 16),

            // Upload KTP
            uploadBox("Foto KTP *", _ktpFile, () => pickImage("ktp")),
            const SizedBox(height: 20),

            // NIK
            label("Isi NIK Secara Manual *"),
            const SizedBox(height: 6),
            inputSmall(
              controller: _nikController,
              hint: "Masukkan 16 digit NIK",
              maxLength: 16,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Upload SKCK
            uploadBox("SKCK *", _skckFile, () => pickImage("skck")),
            const SizedBox(height: 20),

            // Rekening
            label("Nomor Rekening *"),
            const SizedBox(height: 6),
            inputSmall(
              controller: _rekeningController,
              hint: "Masukkan nomor rekening",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Nama akun rekening
            label("Nama Akun Rekening *"),
            const SizedBox(height: 6),
            inputSmall(
              controller: _namaAkunRekeningController,
              hint: "Masukkan nama pemilik rekening",
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),

            // Bank
            label("Pilih Bank *"),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedBank,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: bankList.keys
                  .map(
                    (bank) => DropdownMenuItem(
                      value: bank,
                      child: Text(bank, style: const TextStyle(fontSize: 12)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedBank = value;
                  _bankCodeController.text = bankList[value] ?? "";
                });
              },
            ),
            const SizedBox(height: 20),

            // Kode bank (otomatis)
            label("Kode Bank"),
            const SizedBox(height: 6),
            inputSmall(
              controller: _bankCodeController,
              hint: "Kode bank otomatis",
              readOnly: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),

            // Tombol submit
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: submitData,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Kirim Verifikasi",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== HELPER WIDGETS =====================

  Widget label(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
    );
  }

  Widget inputSmall({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: 42,
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          counterText: "",
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  Widget dropdownWilayah(
    String labelText,
    List items,
    String? value,
    Function(String?) onChange,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: labelText),
      isExpanded: true,
      value: value,
      items: items.map((e) {
        return DropdownMenuItem(
          value: e['id'].toString(),
          child: Text(e['name']),
        );
      }).toList(),
      onChanged: (v) {
        onChange(v);
        setState(() {});
      },
    );
  }

  Widget uploadBox(String title, XFile? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            const Icon(Icons.upload_file, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (file != null)
                    Text(
                      p.basename(file.path),
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
