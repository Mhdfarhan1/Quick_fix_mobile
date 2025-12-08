// form_pemesanan.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../config/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../alamat/pilih_alamat_page.dart';
import '../Pembayaran/konfirmasi_pembayaran_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class FormPemesanan extends StatefulWidget {
  final int idPelanggan;
  final int idTeknisi;
  final int idKeahlian;
  final String namaTeknisi;
  final String namaKeahlian;
  final int harga;
  final String fotoProfile; 

  const FormPemesanan({
    super.key,
    required this.idPelanggan,
    required this.idTeknisi,
    required this.idKeahlian,
    required this.namaTeknisi,
    required this.namaKeahlian,
    required this.harga,
    required this.fotoProfile
  });

  @override
  State<FormPemesanan> createState() => _FormPemesananState();
}

class _FormPemesananState extends State<FormPemesanan> {
  // ====== Config / constants ======
  static const int ADMIN_FEE = 10000;
  static const int PROP_RUMAH = 30000;
  static const int PROP_APART = 50000;
  static const int PROP_LAIN = 100000;

  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  bool isFormValid() {
    return alamatDipilih != null &&
          keluhan.trim().isNotEmpty &&
          imageKeluhan != null;
  }



  // ====== State ======
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

  XFile? imageKeluhan;


  String keluhan = "";
  String selectedPayment = "transfer";
  String selectedProperty = "Rumah";

  bool sending = false;
  bool loadingAlamat = true;
  List<Map<String, dynamic>> alamatUser = [];
  Map<String, dynamic>? alamatDipilih;

  int hargaDasar = 0;

  @override
  void initState() {
    super.initState();
    hargaDasar = widget.harga;
    _fetchAlamatUser();
  }

  Future<void> _fetchAlamatUser() async {
    setState(() => loadingAlamat = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAlamat = prefs.getString("alamat_default");
    int? savedIdAlamat = prefs.getInt("id_alamat_default");

    if (savedAlamat != null) {
      setState(() {
        alamatDipilih = {
          "id_alamat": savedIdAlamat,
          "alamat_lengkap": savedAlamat,
          "is_default": true,
        };
      });
    }

    try {
      final token = await ApiService.storage.read(key: 'token');

      final res = await http.get(
        Uri.parse("${BaseUrl.api}/alamat"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        List<Map<String, dynamic>> results = [];

        if (body is Map && body.containsKey('data')) {
          results = List<Map<String, dynamic>>.from(body['data']);
        }

        if (results.isNotEmpty) {
          final d = results.firstWhere(
            (a) => (a['is_default'] == 1 || a['is_default'] == true),
            orElse: () => results.first,
          );

          await prefs.setString("alamat_default", d['alamat_lengkap'] ?? "");
          if (d['id_alamat'] != null) await prefs.setInt("id_alamat_default", d['id_alamat']);

          setState(() {
            alamatUser = results;
            alamatDipilih = d;
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal ambil alamat: $e");
    }

    setState(() => loadingAlamat = false);
  }

  int get propertyFee {
    switch (selectedProperty) {
      case "Rumah":
        return PROP_RUMAH;
      case "Apartemen":
        return PROP_APART;
      default:
        return PROP_LAIN;
    }
  }

  int get totalPembayaran => hargaDasar + propertyFee + ADMIN_FEE;
  String fmt(int v) => currency.format(v);

  Future<void> pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (d != null) setState(() => selectedDate = d);
  }

  Future<void> pickTime() async {
    final t = await showTimePicker(context: context, initialTime: selectedTime);
    if (t != null) setState(() => selectedTime = t);
  }

  // pilih gambar dari source (camera / gallery)
  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80); // compress ringan

      if (picked != null) {
        setState(() => imageKeluhan = picked);
      }
    } catch (e) {
      debugPrint("Error pickImage: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memilih gambar")));
    }
  }

  // hapus gambar yang sudah dipilih
  void removeImage() {
    setState(() => imageKeluhan = null);
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto (Kamera)'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Batal'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }





  Future<void> submitPemesanan() async {
    if (keluhan.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deskripsi masalah wajib diisi")),
      );
      return;
    }

    if (alamatDipilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih alamat terlebih dahulu")),
      );
      return;
    }

    if (keluhan.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deskripsi masalah wajib diisi")),
      );
      return;
    }

    if (imageKeluhan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto keluhan wajib diupload")),
      );
      return;
    }


    setState(() => sending = true);

    final tanggalBooking = DateFormat('yyyy-MM-dd').format(selectedDate);
    final jamBooking = DateFormat('HH:mm:ss').format(
      DateTime(0, 1, 1, selectedTime.hour, selectedTime.minute),
    );

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${BaseUrl.api}/add_pemesanan"),
      );

      request.fields.addAll({
        "id_pelanggan": widget.idPelanggan.toString(),
        "id_teknisi": widget.idTeknisi.toString(),
        "id_keahlian": widget.idKeahlian.toString(),
        "tanggal_booking": tanggalBooking,
        "jam_booking": jamBooking,
        "keluhan": keluhan,
        "harga": totalPembayaran.toString(),
      });

      if (alamatDipilih?['id_alamat'] != null) {
        request.fields['id_alamat'] = alamatDipilih!['id_alamat'].toString();
      }

      // === UPLOAD FOTO ===
      if (imageKeluhan != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto_keluhan',
            imageKeluhan!.path,
          ),
        );
      }

      var response = await request.send();
      var res = await http.Response.fromStream(response);

      setState(() => sending = false);

      print("Response: ${res.statusCode} ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => KonfirmasiPembayaranPage(
              kodePemesanan: data['data']['kode_pemesanan'],
              metodePembayaran: selectedPayment,
              totalPembayaran: totalPembayaran,
              namaTeknisi: widget.namaTeknisi,
              namaKeahlian: widget.namaKeahlian,
              keluhan: keluhan,
              tanggalBooking: tanggalBooking,
              jamBooking: jamBooking,
              alamat: alamatDipilih?['alamat_lengkap'] ?? "",
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => sending = false);
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan"),
        backgroundColor: const Color(0xFF0C4481),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      
      bottomNavigationBar: Container(
        
        color: Colors.transparent,
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: (!isFormValid() || sending) ? null : submitPemesanan,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFCC33),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: sending
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black))
              : Text("Pesan Sekarang • ${fmt(totalPembayaran)}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ====== ALAMAT PEMESANAN ======
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Alamat Pemesanan", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              loadingAlamat
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : Center(
                      child: Text(
                        alamatDipilih != null
                            ? (alamatDipilih!['alamat_lengkap'] ?? "Alamat tidak ditemukan")
                            : "Belum memilih alamat...",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff004aad),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  onPressed: () async {
                    final picked = await Navigator.push<Map<String, dynamic>?>(
                      context,
                      MaterialPageRoute(builder: (_) => const PilihAlamatPage()),
                    );
                    if (picked != null) {
                      setState(() => alamatDipilih = picked);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString("alamat_default", picked['alamat_lengkap'] ?? "");
                      if (picked['id_alamat'] != null) {
                        await prefs.setInt("id_alamat_default", picked['id_alamat']);
                      }
                    }
                  },
                  child: const Text(
                    "Pilih lokasi",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Layanan
          _layananCard(),

          const SizedBox(height: 16),

          _deskripsiMasalah(),

          const SizedBox(height: 16),

          _propertiPilihan(),

          const SizedBox(height: 16),

          _tanggalDanJam(),

          const SizedBox(height: 16),

          _ringkasanPembayaran(),

          const SizedBox(height: 16),

          _metodePembayaran(),

          const SizedBox(height: 90),

          
        ]),
      ),
    );
  }

  // ======== Sub-Widgets ========
  Widget _layananCard() {
    final foto = widget.fotoProfile;
    final imageUrl = (foto == null || foto.isEmpty)
        ? "${BaseUrl.storage}/foto/default_profile.jpg"
        : "${BaseUrl.storage}/foto_profile/$foto";


    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.namaTeknisi, style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(widget.namaKeahlian, style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Text(fmt(widget.harga), style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deskripsiMasalah() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row: TextField (expanded) + icon camera sejajar
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Deskripsi Masalah",
                ),
                onChanged: (v) => setState(() => keluhan = v),
              ),
            ),

            // icon camera kecil di sebelah kanan
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  onPressed: _showImageSourceSheet,
                  tooltip: 'Pilih foto (kamera/galeri)',
                ),
                // label kecil di bawah icon supaya balance
                const SizedBox(height: 4),
                const Text(
                  "Lampirkan",
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Preview gambar + tombol hapus
        if (imageKeluhan != null)
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.file(
                  File(imageKeluhan!.path),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    onPressed: removeImage,
                    tooltip: 'Hapus foto',
                  ),
                ),
              ),
            ],
          )
        else
          // hint kecil saat belum ada gambar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Text(
              'Belum ada foto. Tekan ikon kamera di samping untuk menambahkan.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
      ],
    ),
  );



  Widget _propertiPilihan() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          RadioListTile<String>(
            value: "Rumah",
            groupValue: selectedProperty,
            onChanged: (v) => setState(() => selectedProperty = v!),
            title: const Text("Rumah"),
            secondary: Text(fmt(PROP_RUMAH)),
          ),
          RadioListTile<String>(
            value: "Apartemen",
            groupValue: selectedProperty,
            onChanged: (v) => setState(() => selectedProperty = v!),
            title: const Text("Apartemen"),
            secondary: Text(fmt(PROP_APART)),
          ),
          RadioListTile<String>(
            value: "Lainnya",
            groupValue: selectedProperty,
            onChanged: (v) => setState(() => selectedProperty = v!),
            title: const Text("Lainnya"),
            secondary: Text(fmt(PROP_LAIN)),
          ),
        ]),
      );

  Widget _tanggalDanJam() => Row(children: [
        Expanded(
          child: InkWell(
            onTap: pickDate,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("${selectedDate.toIso8601String().substring(0, 10)}"),
                const Icon(Icons.calendar_today_outlined)
              ]),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: pickTime,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(selectedTime.format(context)),
                const Icon(Icons.access_time_outlined)
              ]),
            ),
          ),
        ),
      ]);

  Widget _ringkasanPembayaran() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          _summaryRow(widget.namaKeahlian, hargaDasar),
          const SizedBox(height: 6),
          _summaryRow("Biaya Properti (${selectedProperty})", propertyFee),
          const SizedBox(height: 6),
          _summaryRow("Biaya Admin", ADMIN_FEE),
          const Divider(),
          _summaryRow("Total Pembayaran", totalPembayaran, bold: true),
        ]),
      );

  Widget _metodePembayaran() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonFormField<String>(
          value: selectedPayment,
          items: const [
            DropdownMenuItem(value: "transfer", child: Text("Transfer Bank")),
            DropdownMenuItem(value: "ewallet", child: Text("E-Wallet")),
            DropdownMenuItem(value: "qris", child: Text("QRIS")),
          ],
          onChanged: (v) => setState(() => selectedPayment = v ?? "transfer"),
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      );

  Widget _summaryRow(String title, int price, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(fmt(price),
              style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? Colors.black : Colors.black54)),
        ],
      );

}

