import 'package:flutter/material.dart';

class PusatBantuanFAQPage extends StatelessWidget {
  const PusatBantuanFAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
        ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    final sectionStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
        ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.6)
        ?? const TextStyle(fontSize: 14, height: 1.6);

    final sections = _faqSections(context, bodyStyle);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Pusat Bantuan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FAQ Pelanggan', style: titleStyle),
              const SizedBox(height: 8),
              Text(
                'Kumpulan pertanyaan umum untuk membantu penggunaan aplikasi QuickFix.',
                style: bodyStyle.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 14),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Material(
                    color: Colors.white,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: sections.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final s = sections[i];
                        return _buildSectionTile(context, s, sectionStyle, bodyStyle);
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  'FAQ Pelanggan • QuickFix 2025',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])
                      ?? const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTile(BuildContext context, _FaqSection data, TextStyle sectionStyle, TextStyle bodyStyle) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      initiallyExpanded: false,
      leading: _sectionNumberChip(data.index),
      title: Text(data.title, style: sectionStyle),
      children: data.contentWidgets,
    );
  }

  static Widget _sectionNumberChip(int index) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF0C4481),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        (index + 1).toString(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

  List<_FaqSection> _faqSections(BuildContext context, TextStyle bodyStyle) {
    return [
      // ======================================================
      // 1. AKUN & REGISTRASI
      // ======================================================
      _FaqSection(
        index: 0,
        title: 'Akun & Registrasi',
        contentWidgets: [
          _faqItem(
            'Bagaimana cara membuat akun QuickFix?',
            '''
Untuk membuat akun:

1. Buka aplikasi QuickFix
2. Pilih "Daftar / Buat Akun"
3. Masukkan data diri (nama, email, nomor telepon)
4. Verifikasi menggunakan kode OTP
5. Buat kata sandi

Akun Anda siap digunakan.
            ''',
            bodyStyle,
          ),
          _faqItem(
            'Saya tidak menerima kode OTP, apa yang harus saya lakukan?',
            '''
Coba langkah berikut:

- Pastikan nomor telepon sudah benar
- Periksa sinyal atau jaringan
- Tunggu 30–60 detik
- Tekan tombol "Kirim ulang OTP"

Jika tetap tidak masuk, hubungi: support@quickfix.id
            ''',
            bodyStyle,
          ),
        ],
      ),

      // ======================================================
      // 2. PEMESANAN LAYANAN
      // ======================================================
      _FaqSection(
        index: 1,
        title: 'Pemesanan Layanan',
        contentWidgets: [
          _faqItem(
            'Bagaimana cara memesan layanan?',
            '''
1. Buka aplikasi QuickFix
2. Pilih kategori layanan
3. Pilih jenis layanan
4. Isi detail kerusakan + foto (opsional)
5. Pilih teknisi atau gunakan "Pilih Otomatis"
6. Tentukan alamat & jadwal
7. Konfirmasi pesanan

Setelah itu teknisi akan menerima permintaan Anda.
            ''',
            bodyStyle,
          ),
          _faqItem(
            'Apakah saya bisa memilih teknisi sendiri?',
            '''
Ya. Anda bisa memilih teknisi berdasarkan:

- Rating teknisi
- Lokasi terdekat
- Ketersediaan teknisi

Atau gunakan fitur "Pilih Otomatis".
            ''',
            bodyStyle,
          ),
          _faqItem(
            'Bagaimana jika teknisi menolak pesanan?',
            '''
Jika teknisi menolak, sistem otomatis mencarikan teknisi lain.

Anda juga bisa memilih teknisi secara manual.
            ''',
            bodyStyle,
          ),
        ],
      ),

      // ======================================================
      // 3. PEMBAYARAN & BIAYA
      // ======================================================
      _FaqSection(
        index: 2,
        title: 'Pembayaran & Biaya',
        contentWidgets: [
          _faqItem(
            'Metode pembayaran apa saja yang tersedia?',
            '''
Kami mendukung:

- Transfer Bank / Virtual Account
- E-wallet (OVO, Dana, ShopeePay, dll)
- QRIS

Pembayaran diproses melalui Midtrans.
            ''',
            bodyStyle,
          ),
          _faqItem(
            'Apakah ada biaya tambahan?',
            '''
Biaya tambahan dapat muncul untuk:

- Kerusakan tambahan saat pengecekan
- Permintaan layanan darurat
- Pembelian material

Semua biaya harus disetujui pelanggan terlebih dahulu.
            ''',
            bodyStyle,
          ),
          _faqItem(
            'Apakah saya bisa membatalkan pesanan?',
            '''
Ya.

- Gratis jika teknisi belum berangkat
- Jika teknisi sudah menuju lokasi, mungkin dikenakan biaya pembatalan
            ''',
            bodyStyle,
          ),
        ],
      ),

      // ======================================================
      // 4. LAYANAN & PENGERJAAN
      // ======================================================
      _FaqSection(
        index: 3,
        title: 'Layanan & Pengerjaan',
        contentWidgets: [
          _faqItem(
            'Bagaimana cara melacak teknisi?',
            '''
Anda dapat melihat lokasi teknisi secara real-time
melalui halaman "Detail Pesanan".
            ''',
            bodyStyle,
          ),
          _faqItem(
            'Apa yang harus saya lakukan jika teknisi terlambat?',
            '''
Anda dapat:

- Menghubungi teknisi via chat
- Menghubungi pusat dukungan
- Membatalkan pesanan jika diperlukan
            ''',
            bodyStyle,
          ),
        ],
      ),

      // ======================================================
      // 5. KOMPLAIN & DUKUNGAN
      // ======================================================
      _FaqSection(
        index: 4,
        title: 'Komplain & Dukungan',
        contentWidgets: [
          _faqItem(
            'Bagaimana cara melaporkan masalah layanan?',
            '''
Masuk ke:

Bantuan & Laporan → Laporkan Masalah

Atau email: support@quickfix.id
            ''',
            bodyStyle,
          ),
          _faqItem(
            'Bagaimana jika hasil layanan tidak memuaskan?',
            '''
Anda dapat mengajukan komplain atau meminta
perbaikan ulang (rework) dalam batas waktu tertentu.
            ''',
            bodyStyle,
          ),
          _faqItem(
            'Bagaimana cara menghubungi dukungan pelanggan?',
            '''
Email: support@quickfix.id
Telepon/WA: +62 812-3456-7890

Atau gunakan menu "Kontak Dukungan".
            ''',
            bodyStyle,
          ),
        ],
      ),
    ];
  }

  Widget _faqItem(String question, String answer, TextStyle bodyStyle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 6),
          Text(answer, style: bodyStyle),
        ],
      ),
    );
  }
}

class _FaqSection {
  final int index;
  final String title;
  final List<Widget> contentWidgets;

  _FaqSection({required this.index, required this.title, required this.contentWidgets});
}
