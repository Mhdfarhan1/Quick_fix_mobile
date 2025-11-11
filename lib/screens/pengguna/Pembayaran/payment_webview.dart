import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../config/base_url.dart';
import '../../pengguna/Pembayaran/struk_page.dart';
import 'payment_failed_page.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final String kodePemesanan;

  const PaymentWebView({
    super.key,
    required this.paymentUrl,
    required this.kodePemesanan,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool loading = true;
  bool waiting = false;

  @override
  void initState() {
    super.initState();

    final params = const PlatformWebViewControllerCreationParams();

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print("🌐 Start load: $url");
          },
          onPageFinished: (url) {
            print("✅ Page finished loading: $url");
            setState(() => loading = false);

            // Jalankan polling hanya kalau sudah sampai halaman terakhir simulator Midtrans
            if (url.contains("/v2/deeplink/payment")) {
              print("🚀 Detected FINAL payment page, start polling...");
              setState(() => waiting = true);
              _pollStatus();
            } else {
              print("⏸ Bukan halaman akhir, jangan polling dulu");
            }
          },
          onNavigationRequest: (request) {
            print("➡️ Navigating to: ${request.url}");

            // ❌ Jika user cancel / deny
            if (request.url.contains("deny") ||
                request.url.contains("cancel") ||
                request.url.contains("expire") ||
                request.url.contains("status=FAILED")) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentFailedPage(kodePemesanan: widget.kodePemesanan),
                ),
              );
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// 🔁 Cek status pembayaran ke backend (maks 10x)
  Future<void> _pollStatus() async {
    try {
      for (int attempt = 1; attempt <= 5; attempt++) {
        final res = await http.get(
          Uri.parse("${BaseUrl.api}/payment/status?kode_pemesanan=${widget.kodePemesanan}"),
        );

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final status = data['payment_status'];
          print("🔍 Poll $attempt → $status");

          if (status == "dibayar" || status == "settlement") {
            print("✅ Pembayaran sukses (settlement), buka struk...");
            _openStruk();
            return;
          } else if (status == "gagal" || status == "cancel" || status == "deny") {

            print("❌ Pembayaran gagal");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentFailedPage(kodePemesanan: widget.kodePemesanan),
              ),
            );
            return;
          }
        }

        await Future.delayed(const Duration(seconds: 3));
      }

      // ⏳ Timeout jika Midtrans belum kirim notifikasi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaksi belum dikonfirmasi oleh Midtrans.")),
        );
      }
      setState(() => waiting = false);
    } catch (e) {
      print("❌ Error saat polling: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memeriksa status pembayaran.")),
        );
      }
      setState(() => waiting = false);
    }
  }

  /// ✅ Jika status sudah dibayar, buka halaman struk
  Future<void> _openStruk() async {
  print("🚀 Memanggil _openStruk()");
    final res = await http.get(
      Uri.parse("${BaseUrl.api}/get_struk/${widget.kodePemesanan}"),
    );

    if (res.statusCode == 200) {
      final struk = jsonDecode(res.body)['data'];

      // 🔧 Pastikan harga diubah ke int aman
      final rawHarga = struk['harga'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      final hargaInt = int.tryParse(rawHarga) ?? 0;

      Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StrukPage(
          kodePemesanan: struk['kode_pemesanan'] ?? '',
          namaLayanan: struk['nama_layanan'] ?? '',
          alamat: struk['alamat'] ?? '',
          tanggal: struk['tanggal'] ?? '',
          namaTeknisi: struk['nama_teknisi'] ?? '',
          harga: hargaInt, // ✅ Sudah bersih dari "Rp", ".", atau ","
        ),
      ),
    );
  }
}


  @override
  void dispose() {
    _controller.clearCache();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !waiting,
      child: Scaffold(
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),

            if (loading)
              const Center(child: CircularProgressIndicator()),

            if (waiting)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text(
                        'Menunggu konfirmasi Midtrans...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
