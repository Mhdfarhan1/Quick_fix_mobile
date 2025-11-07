// halaman_bayar_sekarang.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../config/base_url.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HalamanBayarSekarang extends StatefulWidget {
  final int idPemesanan;
  final String kodePemesanan;
  final int total; // dalam rupiah (integer)

  const HalamanBayarSekarang({
    super.key,
    required this.idPemesanan,
    required this.kodePemesanan,
    required this.total,
  });

  @override
  State<HalamanBayarSekarang> createState() => _HalamanBayarSekarangState();
}

class _HalamanBayarSekarangState extends State<HalamanBayarSekarang> {
  bool loading = false;
  bool paying = false;
  String paymentStatus = "unknown"; // contoh: pending, hold, settlement, failed
  String orderStatus = "menunggu"; // status pekerjaan: menunggu, diproses, selesai, dll
  String? paymentUrl;
  String? snapToken;
  Timer? pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchInitial(); // ambil status saat pertama buka
    _startPolling();
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchInitial() async {
    setState(() => loading = true);
    try {
      final res = await http.get(
        Uri.parse("${BaseUrl.api}/payment/status/${widget.idPemesanan}"),
        headers: await _authHeader(),
      );

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        setState(() {
          paymentStatus = body['payment_status'] ?? paymentStatus;
          orderStatus = body['status'] ?? orderStatus;
        });
      }
    } catch (e) {
      debugPrint("fetchInitial error: $e");
    }
    setState(() => loading = false);
  }

  Future<Map<String, String>> _authHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {'Authorization': 'Bearer $token'};
  }

  void _startPolling() {
    pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _pollStatus();
    });
  }

  Future<void> _pollStatus() async {
    try {
      final res = await http.get(
        Uri.parse("${BaseUrl.api}/payment/status/${widget.idPemesanan}"),
        headers: await _authHeader(),
      );
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final newPaymentStatus = body['payment_status'] ?? paymentStatus;
        final newOrderStatus = body['status'] ?? orderStatus;

        if (newPaymentStatus != paymentStatus) {
          // status berubah -> beri notifikasi/sweet alert
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Pembayaran: $newPaymentStatus")),
          );
        }

        if (newOrderStatus != orderStatus) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Status pesanan: $newOrderStatus")),
          );
        }

        setState(() {
          paymentStatus = newPaymentStatus;
          orderStatus = newOrderStatus;
        });
      }
    } catch (e) {
      debugPrint("poll error: $e");
    }
  }

  bool get canPay {
    // tombol bayar muncul ketika order status menunggu_pembayaran / konfirmasi
    // juga pastikan payment belum settlement atau release
    return (orderStatus == 'menunggu' || orderStatus == 'konfirmasi' || orderStatus == 'menunggu_pembayaran') &&
        !(paymentStatus == 'settlement' || paymentStatus == 'release' || orderStatus == 'selesai');
  }

  Future<void> _createPayment() async {
    setState(() => paying = true);

    try {
      final res = await http.post(
        Uri.parse("${BaseUrl.api}/payment/create"),
        headers: {
          'Content-Type': 'application/json',
          ...(await _authHeader()),
        },
        body: json.encode({'id_pemesanan': widget.idPemesanan}),
      );

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        snapToken = body['snap_token'];
        paymentUrl = body['payment_url'];

        // Simpan snap_token di local (opsional)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('snap_${widget.idPemesanan}', snapToken ?? '');

        // Jika kamu punya Midtrans SDK Flutter, panggil SDK di sini menggunakan snapToken
        // contoh pseudo:
        // if (Midtrans.isAvailable) {
        //   Midtrans.payWithSnapToken(snapToken);
        // } else {
        //   // fallback ke webview
        // }

        // fallback: buka webview ke paymentUrl
        if (paymentUrl != null) {
          await Navigator.push(context, MaterialPageRoute(builder: (_) {
            return PaymentWebView(
              url: paymentUrl!,
              onFinished: () {
                // ketika webview tertutup, kita mulai polling intensif sebentar
                // polling sudah berjalan, jadi cukup tunggu
              },
            );
          }));
        } else if (snapToken != null) {
          // jika kamu ingin membuka vtweb dengan snapToken url:
          final vtUrl = "https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken";
          await Navigator.push(context, MaterialPageRoute(builder: (_) {
            return PaymentWebView(
              url: vtUrl,
              onFinished: () {},
            );
          }));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal membuat pembayaran")),
          );
        }
      } else {
        final body = res.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Create payment gagal: $body")),
        );
      }
    } catch (e) {
      debugPrint("createPayment error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal koneksi ke server")),
      );
    }

    setState(() => paying = false);
  }

  Future<void> _releaseDana() async {
    // tombol release hanya untuk teknisi/admin (panggilan backend)
    setState(() => loading = true);
    try {
      final res = await http.post(
        Uri.parse("${BaseUrl.api}/payment/release/${widget.idPemesanan}"),
        headers: {
          'Content-Type': 'application/json',
          ...(await _authHeader()),
        },
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dana berhasil direlease")),
        );
        // fetch ulang status
        await _fetchInitial();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Release gagal: ${res.body}")),
        );
      }
    } catch (e) {
      debugPrint("release error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal koneksi ke server")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _fancyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C4481), Color(0xFF2C7BE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pembayaran', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Kode: ${widget.kodePemesanan}', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text('Total: Rp ${widget.total.toString()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(paymentStatus), backgroundColor: Colors.white24, labelStyle: const TextStyle(color: Colors.white)),
              Chip(label: Text(orderStatus), backgroundColor: Colors.white24, labelStyle: const TextStyle(color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bayar Sekarang'),
        backgroundColor: const Color(0xFF0C4481),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _fancyCard(),
            const SizedBox(height: 20),
            if (loading) const LinearProgressIndicator(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (canPay && !paying) ? _createPayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC33),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 6,
              ),
              child: paying
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black))
                  : const Text('BAYAR SEKARANG', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: (paymentStatus == 'settlement' || paymentStatus == 'release') ? null : () async {
                // Tombol refresh manual
                await _fetchInitial();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status diperbarui")));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              child: const Text('PERBARUI STATUS'),
            ),
            const SizedBox(height: 20),
            if (orderStatus == 'selesai' && paymentStatus == 'hold')
              ElevatedButton(
                onPressed: loading ? null : _releaseDana,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: loading ? const CircularProgressIndicator() : const Text('Release Dana (Admin/Tecknisi)'),
              ),
            const SizedBox(height: 8),
            const Spacer(),
            Text('Catatan: Pastikan menyelesaikan pembayaran di halaman Midtrans.', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class PaymentWebView extends StatefulWidget {
  final String url;
  final VoidCallback onFinished;

  const PaymentWebView({super.key, required this.url, required this.onFinished});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          setState(() => loading = false);
        },
        onNavigationRequest: (nav) {
          // jika butuh detect success url, cek url di sini
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: const Color(0xFF0C4481),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.onFinished();
    super.dispose();
  }
}
