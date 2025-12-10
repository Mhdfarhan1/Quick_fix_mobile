import 'package:flutter/material.dart';

class PusatBantuanFAQTeknisi extends StatelessWidget {
  PusatBantuanFAQTeknisi({super.key});

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
              Text('FAQ Teknisi', style: titleStyle),
              const SizedBox(height: 8),
              Text(
                'Kumpulan pertanyaan paling umum untuk teknisi QuickFix.',
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
                  'FAQ Teknisi • QuickFix 2025',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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

  // ============================================================
  //             DAFTAR FAQ — KHUSUS TEKNISI
  // ============================================================
  List<_FaqSection> _faqSections(BuildContext context, TextStyle bodyStyle) {
    return [
      _FaqSection(
        index: 0,
        title: 'Akun Teknisi',
        contentWidgets: [
          _faqItem(
            'Bagaimana cara teknisi mendaftar?',
            '''
1. Ajukan pendaftaran teknisi melalui aplikasi
2. Upload dokumen identitas (KTP/SIM)
3. Upload sertifikat/keahlian jika ada
4. Menunggu verifikasi dari admin QuickFix

Jika disetujui, akun teknisi langsung aktif.
            ''',
            bodyStyle,
          ),
          _faqItem(
            'Berapa lama proses verifikasi teknisi?',
            '''
Biasanya 1–3 hari kerja, tergantung kelengkapan dokumen.
            ''',
            bodyStyle,
          ),
        ],
      ),

      _FaqSection(
        index: 1,
        title: 'Menerima Pesanan',
        contentWidgets: [
          _faqItem(
            'Bagaimana cara menerima atau menolak pesanan?',
            '''
Saat ada pesanan masuk:

- Tekan tombol "Terima" untuk mengambil pekerjaan
- Tekan "Tolak" jika Anda tidak bisa datang

Jika ditolak, pesanan berpindah ke teknisi lain.
            ''',
            bodyStyle,
          ),
          _faqItem(
            'Apa yang terjadi jika teknisi sering menolak pesanan?',
            '''
Tingkat prioritas akun teknisi dapat menurun.

Sistem akan lebih jarang mengirim pesanan otomatis.
            ''',
            bodyStyle,
          ),
        ],
      ),

      _FaqSection(
        index: 2,
        title: 'Pengerjaan Layanan',
        contentWidgets: [
          _faqItem(
            'Apa yang harus dilakukan setelah tiba di lokasi pelanggan?',
            '''
1. Tekan "Saya sudah tiba"
2. Periksa kerusakan
3. Sampaikan estimasi biaya tambahan jika ada
4. Tunggu persetujuan pelanggan
            ''',
            bodyStyle,
          ),
          _faqItem(
            'Bagaimana jika pelanggan meminta tambahan pekerjaan?',
            '''
Tambahkan detail tambahan melalui aplikasi sebelum mengerjakan.

Pastikan pelanggan menyetujui biaya tambahan.
            ''',
            bodyStyle,
          ),
        ],
      ),

      _FaqSection(
        index: 3,
        title: 'Pembayaran & Pendapatan',
        contentWidgets: [
          _faqItem(
            'Kapan teknisi menerima pembayaran?',
            '''
Dana masuk ke saldo teknisi setelah pekerjaan selesai dan dikonfirmasi pelanggan.
            ''',
            bodyStyle,
          ),
          _faqItem(
            'Bagaimana cara menarik saldo?',
            '''
Masuk ke:

Menu → Pendapatan → Tarik Saldo

Penarikan membutuhkan rekening bank yang valid.
            ''',
            bodyStyle,
          ),
        ],
      ),

      _FaqSection(
        index: 4,
        title: 'Komplain & Dukungan',
        contentWidgets: [
          _faqItem(
            'Bagaimana jika pelanggan komplain?',
            '''
Admin akan menghubungi teknisi untuk klarifikasi.

Jangan khawatir—QuickFix akan menilai secara adil.
            ''',
            bodyStyle,
          ),
          _faqItem(
            'Bagaimana cara menghubungi dukungan teknisi?',
            '''
Email: support@quickfix.id
WA: +62 812-3456-7890
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
