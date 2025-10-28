import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // opsional untuk animasi

class AppDialog {
  // ✅ Error State dengan ilustrasi + tombol Coba Lagi
  static void showError(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ilustrasi ikon (bisa diganti dengan asset atau Lottie)
            const Icon(Icons.cloud_off, color: Color(0xFF007BFF), size: 60),
            const SizedBox(height: 16),
            const Text(
              "Ups! Terjadi kesalahan saat memuat data.",
              style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF007BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF007BFF)),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text("COBA LAGI"),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Empty State (misal belum ada layanan)
  static Widget emptyState({
    required String message,
    String? subText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, color: Color(0xFF0046C7), size: 80),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (subText != null) ...[
              const SizedBox(height: 6),
              Text(
                subText,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ✅ Loading State dengan shimmer effect sederhana
  static Widget loadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF007BFF)),
          SizedBox(height: 12),
          Text("Memuat data...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
