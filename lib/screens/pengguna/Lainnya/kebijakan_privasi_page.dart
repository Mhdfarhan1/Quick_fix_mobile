import 'package:flutter/material.dart';

class KebijakanPrivasiPage extends StatelessWidget {
  const KebijakanPrivasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Kebijakan Privasi', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro
              _sectionTitle('Tentang QuickFix'),
              _sectionText(
                'Kebijakan ini menjelaskan bagaimana QuickFix mengumpulkan, '
                'menggunakan, menyimpan, dan melindungi data pribadi Anda saat '
                'menggunakan aplikasi kami. Dengan menggunakan layanan QuickFix, '
                'Anda menyetujui praktik yang dijelaskan dalam kebijakan ini.',
              ),

              _divider(),

              // 1. Informasi yang dikumpulkan
              _sectionTitle('1. Informasi yang Dikumpulkan'),
              _sectionText(
                'Kami dapat mengumpulkan berbagai jenis informasi untuk menyediakan '
                'dan meningkatkan layanan kami, antara lain:',
              ),
              _bulletList([
                'Data pribadi: nama, alamat email, nomor telepon.',
                'Informasi lokasi: lokasi perangkat (termasuk pelacakan lokasi real-time bila diperlukan untuk layanan teknisi).',
                'Foto & dokumen: foto pekerjaan (sebelum/sesudah), foto identitas, bukti pembayaran atau dokumen terkait layanan.',
                'Riwayat pemesanan dan transaksi.',
                'Informasi teknis perangkat: sistem operasi, model perangkat, alamat IP.',
                'Data penggunaan: logs aktivitas aplikasi, crash report, dan timestamp.',
                'Informasi verifikasi: data KTP atau dokumen lain yang dikumpulkan untuk proses verifikasi teknisi.',
              ]),

              _divider(),

              // 2. Cara Pengumpulan Data
              _sectionTitle('2. Cara Pengumpulan Data'),
              _bulletList([
                'Data yang Anda berikan langsung melalui formulir pendaftaran, profil, atau upload dokumen/foto.',
                'Data yang dikumpulkan secara otomatis saat Anda menggunakan aplikasi (logs, crash report, device info).',
                'Data lokasi dikumpulkan dari perangkat saat Anda memberikan izin, termasuk lokasi real-time saat teknisi melakukan tugas jika fitur tersebut aktif.',
                'Informasi transaksi dikumpulkan melalui integrasi layanan pembayaran pihak ketiga (Midtrans).',
              ]),

              _divider(),

              // 3. Tujuan Penggunaan Data
              _sectionTitle('3. Tujuan Penggunaan Data'),
              _bulletList([
                'Memproses pesanan, penjadwalan, dan komunikasi antara pelanggan dan teknisi.',
                'Verifikasi identitas teknisi dan keamanan akun.',
                'Mengirimkan notifikasi dan pembaruan layanan (push notification / email).',
                'Pemrosesan pembayaran dan rekonsiliasi transaksi (Midtrans).',
                'Analisis penggunaan untuk peningkatan produk dan pemecahan masalah teknis.',
                'Memenuhi kewajiban hukum dan penegakan ketentuan layanan.',
              ]),

              _divider(),

              // 4. Pihak Ketiga & Layanan Eksternal
              _sectionTitle('4. Pihak Ketiga & Layanan Eksternal'),
              _sectionText(
                'QuickFix menggunakan layanan pihak ketiga untuk menyediakan beberapa '
                'fitur. Layanan ini mungkin memiliki kebijakan privasinya sendiri.',
              ),
              _bulletList([
                'Midtrans — penyedia layanan pembayaran untuk memproses transaksi.',
                'Google Maps / Street View — digunakan untuk pemetaan, penentuan alamat, dan tampilan lokasi.',
                'Email SMTP / Gmail API — digunakan untuk pengiriman email verifikasi, reset password, dan dukungan.',
                'Layanan analytics dan push notification yang dipakai (misal Firebase) — untuk memahami penggunaan aplikasi dan mengirim pemberitahuan.',
              ]),
              _sectionText(
                'Saat data dibagikan ke pihak ketiga, kami hanya memberikan data yang '
                'diperlukan untuk tujuan terkait dan sesuai kontrak/aturan privasi mereka.',
              ),

              _divider(),

              // 5. Hak Pengguna
              _sectionTitle('5. Hak Pengguna'),
              _sectionText(
                'Anda memiliki hak atas data pribadi Anda sesuai ketentuan yang berlaku. '
                'Hak tersebut meliputi:',
              ),
              _bulletList([
                'Akses: Meminta salinan data pribadi yang kami simpan tentang Anda.',
                'Perbaikan: Meminta koreksi data yang tidak akurat atau tidak lengkap.',
                'Penghapusan: Meminta penghapusan akun dan/atau data pribadi (lihat prosedur di bawah).',
                'Pembatasan pemrosesan: Meminta pembatasan penggunaan data dalam kondisi tertentu.',
              ]),
              _sectionText(
                'Permintaan atas hak-hak di atas dapat diajukan dengan menghubungi tim dukungan melalui email support@quickfix.id. '
                'Kami akan menanggapi permintaan sesuai dengan hukum yang berlaku dan mungkin meminta verifikasi identitas sebelum memproses permintaan tersebut.',
              ),

              _divider(),

              // 6. Penghapusan Akun & Retensi Data
              _sectionTitle('6. Penghapusan Akun & Retensi Data'),
              _sectionText(
                'Pengguna dapat meminta penghapusan akun dengan mengirimkan email ke support@quickfix.id. '
                'Setelah permintaan diverifikasi, kami akan memproses penghapusan sesuai kebijakan retensi kami.',
              ),
              _bulletList([
                'Beberapa data mungkin disimpan untuk keperluan hukum, perpajakan, atau audit meskipun akun telah dihapus.',
                'Data yang disimpan untuk tujuan hukum atau keamanan akan disimpan selama periode yang diperlukan oleh hukum atau kebijakan internal.',
              ]),

              _divider(),

              // 7. Keamanan Data
              _sectionTitle('7. Keamanan Data'),
              _sectionText(
                'Kami menerapkan langkah-langkah administratif, teknis, dan fisik untuk melindungi data pribadi pengguna, termasuk:',
              ),
              _bulletList([
                'Enkripsi data saat transfer (TLS/HTTPS) dan, bila diperlukan, enkripsi pada penyimpanan.',
                'Kontrol akses berbasis peran sehingga hanya personel berwenang yang dapat mengakses data sensitif.',
                'Pemantauan, logging, dan sistem deteksi intrusi untuk mengidentifikasi dan menanggapi ancaman.',
                'Backup berkala dan prosedur pemulihan bencana.',
                'Pemeliharaan keamanan server (firewall, pembaruan patch, konfigurasi aman).',
              ]),

              _divider(),

              // 8. Kebijakan Cookie
              _sectionTitle('8. Kebijakan Cookie'),
              _sectionText(
                'Aplikasi dan layanan web kami dapat menggunakan cookie dan teknologi serupa untuk '
                'meningkatkan pengalaman pengguna, mengingat preferensi, dan melakukan analitik. '
                'Anda dapat mengelola izin lokasi, notifikasi, dan pengaturan privasi lain melalui pengaturan perangkat atau akun Anda.',
              ),

              _divider(),

              // 9. Pembagian Data ke Pihak Ketiga
              _sectionTitle('9. Pembagian Data ke Pihak Ketiga'),
              _sectionText(
                'Kami dapat membagikan data dengan pihak ketiga hanya dalam kondisi terbatas, antara lain:',
              ),
              _bulletList([
                'Penyedia layanan yang membantu operasional (proses pembayaran, hosting, pengiriman email, analytics).',
                'Saat diwajibkan oleh hukum, perintah pengadilan, atau untuk menegakkan syarat & ketentuan.',
                'Untuk melindungi hak, properti, atau keselamatan QuickFix, pengguna, atau publik.',
              ]),
              _sectionText(
                'Kami menuntut agar pihak ketiga tersebut memproses data sesuai instruksi kami dan menjaga standar keamanan yang wajar.',
              ),

              _divider(),

              // 10. Anak di Bawah Umur
              _sectionTitle('10. Ketentuan untuk Anak'),
              _sectionText(
                'Layanan QuickFix tidak ditujukan untuk anak-anak di bawah usia mayoritas setempat. '
                'Kami tidak sengaja mengumpulkan data pribadi dari anak-anak. Jika Anda menjadi orang tua/wali dan mengetahui bahwa anak Anda telah memberikan informasi tanpa izin, hubungi support@quickfix.id agar kami dapat menghapus data tersebut.',
              ),

              _divider(),

              // 11. Perubahan Kebijakan
              _sectionTitle('11. Perubahan Kebijakan'),
              _sectionText(
                'Kami dapat memperbarui kebijakan ini dari waktu ke waktu. Perubahan akan diumumkan melalui aplikasi atau di situs resmi kami (www.quickfix.id). Tanggal pembaruan akan dicantumkan pada versi kebijakan yang berlaku.',
              ),

              _divider(),

              // 12. Informasi Hosting & Penyimpanan
              _sectionTitle('12. Informasi Hosting & Penyimpanan'),
              _sectionText(
                'Saat ini data aplikasi dikelola oleh backend berbasis Laravel dengan basis data MySQL. '
                'Kami mungkin memindahkan atau menempatkan layanan pada penyedia hosting/cloud untuk tujuan ketersediaan dan skalabilitas. '
                'Setiap perubahan hosting akan tetap mematuhi standar keamanan dan peraturan perlindungan data.',
              ),

              _divider(),

              // 13. Kontak
              _sectionTitle('Kontak Dukungan'),
              _sectionText(
                'Jika ada pertanyaan, permintaan akses data, atau permintaan penghapusan akun, hubungi:',
              ),
              _bulletList([
                'Email: support@quickfix.id',
                'Telepon: +62 8123456789',
                'Situs resmi: www.quickfix.id',
              ]),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Tanggal efektif: 2025\nQuickFix — Semua hak dilindungi',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widgets
  static Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
    );
  }

  static Widget _bulletList(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        i,
                        style: const TextStyle(fontSize: 14, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  static Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      color: Colors.grey.shade300,
    );
  }
}
