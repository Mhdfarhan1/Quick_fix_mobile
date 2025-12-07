import 'package:flutter/material.dart';

class StatusPopup {
  static void show(
    BuildContext context, {
    required String status,
  }) {
    late OverlayEntry overlay;

    final data = _getStatusUI(status);

    overlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: data['color'],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  data['icon'],
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),

                /// TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['subtitle'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () => overlay.remove(),
                  child: const Icon(Icons.close, color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);

    Future.delayed(const Duration(seconds: 5), () {
      if (overlay.mounted) overlay.remove();
    });
  }

  /// ✨ UI DATA PER STATUS
  static Map<String, dynamic> _getStatusUI(String status) {
    switch (status) {
      case 'batal':
        return {
          "color": Colors.red,
          "icon": Icons.cancel,
          "title": "Pesanan Dibatalkan",
          "subtitle": "Pelanggan atau teknisi membatalkan pesanan ini."
        };

      case 'selesai':
        return {
          "color": Colors.grey.shade800,
          "icon": Icons.check_circle,
          "title": "Pekerjaan Selesai",
          "subtitle": "Terima kasih telah menggunakan layanan kami."
        };

      case 'menuju_lokasi':
        return {
          "color": Colors.green,
          "icon": Icons.directions_run,
          "title": "Teknisi Menuju Lokasi",
          "subtitle": "Harap tunggu teknisi tiba di lokasi Anda."
        };

      case 'sedang_bekerja':
        return {
          "color": Colors.green.shade700,
          "icon": Icons.build,
          "title": "Teknisi Sedang Bekerja",
          "subtitle": "Pekerjaan sedang berlangsung."
        };

      case 'dijadwalkan':
        return {
          "color": Colors.blue,
          "icon": Icons.schedule,
          "title": "Pekerjaan Dijadwalkan",
          "subtitle": "Teknisi akan datang sesuai jadwal."
        };

      default:
        return {
          "color": Colors.black,
          "icon": Icons.info,
          "title": "Status Tidak Dikenal",
          "subtitle": "Status pekerjaan belum tersedia."
        };
    }
  }
}
