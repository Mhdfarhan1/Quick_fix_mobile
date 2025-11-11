import 'package:flutter/material.dart';
import '../home/home_page.dart'; // sesuaikan import dengan struktur project kamu

class PaymentFailedPage extends StatelessWidget {
  final String kodePemesanan;
  final String? reason; // optional pesan gagal
  final VoidCallback? onRetry;

  const PaymentFailedPage({
    super.key,
    required this.kodePemesanan,
    this.reason,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran Gagal"),
        backgroundColor: const Color(0xFF0C4481),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cancel_rounded,
                size: 100,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                "Pembayaran Gagal!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Kode Pesanan: $kodePemesanan",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              // reason optional
              if (reason != null) ...[
                const SizedBox(height: 10),
                Text(
                  reason!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],

              const SizedBox(height: 35),

              // tombol retry jika callback disediakan
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Coba Lagi"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),

              if (onRetry != null) const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text("Kembali ke Beranda"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C4481),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Kembali"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
