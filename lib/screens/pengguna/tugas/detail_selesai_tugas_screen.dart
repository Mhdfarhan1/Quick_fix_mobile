import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../config/base_url.dart';
import '../../../widgets/network_image_with_fallback.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';

class OrderDetailSelesaiScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  const OrderDetailSelesaiScreen({super.key, required this.order});

  @override
  State<OrderDetailSelesaiScreen> createState() => _OrderDetailSelesaiScreenState();
}

class _OrderDetailSelesaiScreenState extends State<OrderDetailSelesaiScreen> {
  bool _loadingCheck = true;
  bool _hasReviewed = false;
  Map<String, dynamic>? _existingReview; // menyimpan ulasan jika ada

  @override
  void initState() {
    super.initState();
    _checkIfReviewed();
  }

  Future<String?> getAuthToken() async {
    return await ApiService.storage.read(key: 'token');
  }


  Future<void> _checkIfReviewed() async {
    setState(() => _loadingCheck = true);

    try {
      final idPemesanan = widget.order['id_pemesanan'];
      final token = await getAuthToken();

      final res = await http.get(
        Uri.parse("${BaseUrl.server}/api/pemesanan/$idPemesanan/ulasan"),
        headers: token != null ? {"Authorization": "Bearer $token"} : {},
      );

      print("CEK ULASAN STATUS => ${res.statusCode}");
      print("CEK ULASAN BODY   => ${res.body}");

      final body = json.decode(res.body);

      if (body['status'] != true) {
        _hasReviewed = false;
        _existingReview = null;
      } else {
        _hasReviewed = body['sudah_review'] == true;
        _existingReview = body['ulasan'];
      }

    } catch (e) {
      print("CEK ULASAN ERROR => $e");
      _hasReviewed = false;
      _existingReview = null;
    }

    setState(() => _loadingCheck = false);
  }



  Future<void> _submitReview({required int rating, String? komentar}) async {
    final idPemesanan = widget.order['id_pemesanan'];
    final token = await getAuthToken();
    final uri = Uri.parse("${BaseUrl.server}/api/ulasan");

    final body = {
      'id_pemesanan': idPemesanan.toString(),
      'rating': rating.toString(),
      'komentar': komentar ?? ''
    };

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final res = await http.post(uri, headers: headers, body: body);

    print("ULASAN REQUEST BODY => $body");
    print("ULASAN RESPONSE STATUS => ${res.statusCode}");
    print("ULASAN RESPONSE BODY => ${res.body}");


    if (res.statusCode == 200 || res.statusCode == 201) {
      final resp = json.decode(res.body);
      if (resp['status'] == true) {
        // sukses
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ulasan berhasil dikirim")));
        // refresh cek ulasan
        await _checkIfReviewed();
      } else {
        final msg = resp['message'] ?? 'Terjadi kesalahan';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } else {
      String err = "Gagal mengirim ulasan (${res.statusCode})";
      try {
        final body = json.decode(res.body);
        if (body is Map && body['message'] != null) err = body['message'];
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  void _openReviewSheet() {
    int rating = 5;
    TextEditingController komentarController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(builder: (context, setStateSB) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // thumbnail teknisi kecil
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: NetworkImageWithFallback(
                          imageUrl: widget.order['foto_teknisi'] != null
                              ? "${BaseUrl.server}/storage/foto/foto_teknisi/${widget.order['foto_teknisi']}"
                              : "${BaseUrl.server}/storage/default.png",
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.order['nama_teknisi'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(widget.order['nama_keahlian'] ?? '-', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final idx = i + 1;
                      return GestureDetector(
                        onTap: () {
                          setStateSB(() {
                            rating = idx;
                          });
                        },
                        child: Icon(
                          idx <= rating ? Icons.star : Icons.star_border,
                          size: 36,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: komentarController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: "Tulis pengalamanmu (opsional)",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCC33),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop(); // tutup sheet dulu
                            // show loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(child: CircularProgressIndicator()),
                            );
                            await _submitReview(rating: rating, komentar: komentarController.text.trim());
                            Navigator.of(context).pop(); // tutup loading
                          },
                          child: const Text(
                            "Kirim",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  void _openViewReviewSheet() {
    if (_existingReview == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        final r = _existingReview!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 12),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWithFallback(
                      imageUrl: widget.order['foto_teknisi'] != null
                          ? "${BaseUrl.server}/storage/foto/foto_teknisi/${widget.order['foto_teknisi']}"
                          : "${BaseUrl.server}/storage/default.png",
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(widget.order['nama_teknisi'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final idx = i + 1;
                  return Icon(idx <= (r['rating'] ?? 0) ? Icons.star : Icons.star_border, color: Colors.amber, size: 32);
                }),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Text(r['komentar'] ?? "Tidak ada komentar"),
              ),
              const SizedBox(height: 16),
              Text("Tanggal: ${r['created_at'] ?? '-'}", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    
    final order = widget.order;

    print("DEBUG BUKTI: ${order['foto_bukti']}");
    print("FULL URL: ${order['foto_bukti_url']}");
    print("URL BUKTI: ${order['foto_bukti_url']}");

    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final rawHarga = order['harga'];
    final harga = (rawHarga is num)
        ? rawHarga
        : num.tryParse(rawHarga.toString().replaceAll(",", "").replaceAll(".00", "")) ?? 0;

    final namaTeknisi = order['nama_teknisi'] ?? '-';
    final namaLayanan = order['nama_keahlian'] ?? '-';
    final tanggal = order['tanggal_booking'] ?? '-';
    final alamat = order['alamat_lengkap'] ?? '-';
    final imageUrl = order['foto_teknisi'] != null
        ? "${BaseUrl.server}/storage/foto/foto_teknisi/${order['foto_teknisi']}"
        : "${BaseUrl.server}/storage/default.png";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A4CA7),
        title: const Text("Detail Pesanan Selesai", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            ListView(children: [
          // FOTO TEKNISI
          Center(
            child: GestureDetector(
              onTap: () => showImageZoom(context, imageUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(70),
                child: NetworkImageWithFallback(
                  imageUrl: imageUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(namaTeknisi, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          detailItem("Layanan", namaLayanan),
          detailItem("Tanggal Selesai", tanggal),
          detailItem("Alamat", alamat),
          detailItem("Harga", formatter.format(harga)),
          detailItem("Status", "Selesai"),
          const SizedBox(height: 20),
          if (order['foto_bukti_url'] != null && order['foto_bukti_url'] != "")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Bukti Pekerjaan:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => showImageZoom(context, order['foto_bukti_url']),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: NetworkImageWithFallback(
                      imageUrl: order['foto_bukti_url'],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 30),
          // Tombol ulasan
          _loadingCheck
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasReviewed ? Colors.blue : const Color(0xFFFFCC33),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (_hasReviewed) {
                      _openViewReviewSheet();
                    } else {
                      _openReviewSheet();
                    }
                  },
                  child: Text(
                    _hasReviewed ? "Lihat Ulasan" : "Beri Ulasan",
                    style: TextStyle(
                      color: _hasReviewed ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ]),
      ),
      
    );
  }

  Widget detailItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(
            value,
            style: const TextStyle(fontSize: 15),
          )),
        ],
      ),
    );
  }
  

  void showImageZoom(BuildContext context, String imageUrl) {
    print(widget.order['foto_bukti_url']);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: NetworkImageWithFallback(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
