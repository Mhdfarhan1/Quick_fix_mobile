import 'package:flutter/material.dart';

class KebijakanPrivasiPage extends StatelessWidget {
  const KebijakanPrivasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    final sectionStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600) ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.6) ?? const TextStyle(fontSize: 14, height: 1.6);

    // Sections data (kept simple so it's easy to maintain)
    final sections = <_SectionData>[
      _SectionData(
        index: 1,
        title: 'Informasi yang Dikumpulkan',
        contentWidgets: [
          Text('Kami dapat mengumpulkan berbagai jenis informasi untuk menyediakan dan meningkatkan layanan kami, antara lain:', style: bodyStyle),
          const SizedBox(height: 8),
          _bulletList(context, [
            'Data pribadi: nama, alamat email, nomor telepon.',
            'Informasi lokasi: lokasi perangkat (termasuk pelacakan lokasi real-time bila diperlukan untuk layanan teknisi).',
            'Foto & dokumen: foto pekerjaan (sebelum/sesudah), foto identitas, bukti pembayaran atau dokumen terkait layanan.',
            'Riwayat pemesanan dan transaksi.',
            'Informasi teknis perangkat: sistem operasi, model perangkat, alamat IP.',
            'Data penggunaan: logs aktivitas aplikasi, crash report, dan timestamp.',
            'Informasi verifikasi: data KTP atau dokumen lain yang dikumpulkan untuk proses verifikasi teknisi.',
          ]),
        ],
      ),
      _SectionData(
        index: 2,
        title: 'Cara Pengumpulan Data',
        contentWidgets: [
          _bulletList(context, [
            'Data yang Anda berikan langsung melalui formulir pendaftaran, profil, atau upload dokumen/foto.',
            'Data yang dikumpulkan secara otomatis saat Anda menggunakan aplikasi (logs, crash report, device info).',
            'Data lokasi dikumpulkan dari perangkat saat Anda memberikan izin, termasuk lokasi real-time saat teknisi melakukan tugas jika fitur tersebut aktif.',
            'Informasi transaksi dikumpulkan melalui integrasi layanan pembayaran pihak ketiga (Midtrans).',
          ]),
        ],
      ),
      _SectionData(
        index: 3,
        title: 'Tujuan Penggunaan Data',
        contentWidgets: [
          _bulletList(context, [
            'Memproses pesanan, penjadwalan, dan komunikasi antara pelanggan dan teknisi.',
            'Verifikasi identitas teknisi dan keamanan akun.',
            'Mengirimkan notifikasi dan pembaruan layanan (push notification / email).',
            'Pemrosesan pembayaran dan rekonsiliasi transaksi (Midtrans).',
            'Analisis penggunaan untuk peningkatan produk dan pemecahan masalah teknis.',
            'Memenuhi kewajiban hukum dan penegakan ketentuan layanan.',
          ]),
        ],
      ),
      _SectionData(
        index: 4,
        title: 'Pihak Ketiga & Layanan Eksternal',
        contentWidgets: [
          Text('QuickFix menggunakan layanan pihak ketiga untuk menyediakan beberapa fitur. Layanan ini mungkin memiliki kebijakan privasinya sendiri.', style: bodyStyle),
          const SizedBox(height: 8),
          _bulletList(context, [
            'Midtrans — penyedia layanan pembayaran untuk memproses transaksi.',
            'Google Maps / Street View — digunakan untuk pemetaan, penentuan alamat, dan tampilan lokasi.',
            'Email SMTP / Gmail API — digunakan untuk pengiriman email verifikasi, reset password, dan dukungan.',
            'Layanan analytics dan push notification yang dipakai (misal Firebase) — untuk memahami penggunaan aplikasi dan mengirim pemberitahuan.',
          ]),
        ],
      ),
      _SectionData(
        index: 5,
        title: 'Hak Pengguna',
        contentWidgets: [
          Text('Anda memiliki hak atas data pribadi Anda sesuai ketentuan yang berlaku. Hak tersebut meliputi:', style: bodyStyle),
          const SizedBox(height: 8),
          _bulletList(context, [
            'Akses: Meminta salinan data pribadi yang kami simpan tentang Anda.',
            'Perbaikan: Meminta koreksi data yang tidak akurat atau tidak lengkap.',
            'Penghapusan: Meminta penghapusan akun dan/atau data pribadi (lihat prosedur di bawah).',
            'Pembatasan pemrosesan: Meminta pembatasan penggunaan data dalam kondisi tertentu.',
          ]),
          const SizedBox(height: 8),
          Text('Permintaan atas hak-hak di atas dapat diajukan dengan menghubungi tim dukungan melalui email support@quickfix.id. Kami akan menanggapi permintaan sesuai dengan hukum yang berlaku dan mungkin meminta verifikasi identitas sebelum memproses permintaan tersebut.', style: bodyStyle),
        ],
      ),
      _SectionData(
        index: 6,
        title: 'Penghapusan Akun & Retensi Data',
        contentWidgets: [
          Text('Pengguna dapat meminta penghapusan akun dengan mengirimkan email ke support@quickfix.id. Setelah permintaan diverifikasi, kami akan memproses penghapusan sesuai kebijakan retensi kami.', style: bodyStyle),
          const SizedBox(height: 8),
          _bulletList(context, [
            'Beberapa data mungkin disimpan untuk keperluan hukum, perpajakan, atau audit meskipun akun telah dihapus.',
            'Data yang disimpan untuk tujuan hukum atau keamanan akan disimpan selama periode yang diperlukan oleh hukum atau kebijakan internal.',
          ]),
        ],
      ),
      _SectionData(
        index: 7,
        title: 'Keamanan Data',
        contentWidgets: [
          Text('Kami menerapkan langkah-langkah administratif, teknis, dan fisik untuk melindungi data pribadi pengguna, termasuk:', style: bodyStyle),
          const SizedBox(height: 8),
          _bulletList(context, [
            'Enkripsi data saat transfer (TLS/HTTPS) dan, bila diperlukan, enkripsi pada penyimpanan.',
            'Kontrol akses berbasis peran sehingga hanya personel berwenang yang dapat mengakses data sensitif.',
            'Pemantauan, logging, dan sistem deteksi intrusi untuk mengidentifikasi dan menanggapi ancaman.',
            'Backup berkala dan prosedur pemulihan bencana.',
            'Pemeliharaan keamanan server (firewall, pembaruan patch, konfigurasi aman).',
          ]),
        ],
      ),
      _SectionData(
        index: 8,
        title: 'Kebijakan Cookie',
        contentWidgets: [
          Text('Aplikasi dan layanan web kami dapat menggunakan cookie dan teknologi serupa untuk meningkatkan pengalaman pengguna, mengingat preferensi, dan melakukan analitik. Anda dapat mengelola izin lokasi, notifikasi, dan pengaturan privasi lain melalui pengaturan perangkat atau akun Anda.', style: bodyStyle),
        ],
      ),
      _SectionData(
        index: 9,
        title: 'Pembagian Data ke Pihak Ketiga',
        contentWidgets: [
          Text('Kami dapat membagikan data dengan pihak ketiga hanya dalam kondisi terbatas, antara lain:', style: bodyStyle),
          const SizedBox(height: 8),
          _bulletList(context, [
            'Penyedia layanan yang membantu operasional (proses pembayaran, hosting, pengiriman email, analytics).',
            'Saat diwajibkan oleh hukum, perintah pengadilan, atau untuk menegakkan syarat & ketentuan.',
            'Untuk melindungi hak, properti, atau keselamatan QuickFix, pengguna, atau publik.',
          ]),
          const SizedBox(height: 6),
          Text('Kami menuntut agar pihak ketiga tersebut memproses data sesuai instruksi kami dan menjaga standar keamanan yang wajar.', style: bodyStyle),
        ],
      ),
      _SectionData(
        index: 10,
        title: 'Ketentuan untuk Anak',
        contentWidgets: [
          Text('Layanan QuickFix tidak ditujukan untuk anak-anak di bawah usia mayoritas setempat. Kami tidak sengaja mengumpulkan data pribadi dari anak-anak. Jika Anda menjadi orang tua/wali dan mengetahui bahwa anak Anda telah memberikan informasi tanpa izin, hubungi support@quickfix.id agar kami dapat menghapus data tersebut.', style: bodyStyle),
        ],
      ),
      _SectionData(
        index: 11,
        title: 'Perubahan Kebijakan',
        contentWidgets: [
          Text('Kami dapat memperbarui kebijakan ini dari waktu ke waktu. Perubahan akan diumumkan melalui aplikasi atau di situs resmi kami (www.quickfix.id). Tanggal pembaruan akan dicantumkan pada versi kebijakan yang berlaku.', style: bodyStyle),
        ],
      ),
      _SectionData(
        index: 12,
        title: 'Informasi Hosting & Penyimpanan',
        contentWidgets: [
          Text('Saat ini data aplikasi dikelola oleh backend berbasis Laravel dengan basis data MySQL. Kami mungkin memindahkan atau menempatkan layanan pada penyedia hosting/cloud untuk tujuan ketersediaan dan skalabilitas. Setiap perubahan hosting akan tetap mematuhi standar keamanan dan peraturan perlindungan data.', style: bodyStyle),
        ],
      ),
      _SectionData(
        index: 13,
        title: 'Kontak Dukungan',
        contentWidgets: [
          Text('Jika ada pertanyaan, permintaan akses data, atau permintaan penghapusan akun, hubungi:', style: bodyStyle),
          const SizedBox(height: 8),
          _bulletList(context, [
            'Email: support@quickfix.id',
            'Telepon: +62 8123456789',
            'Situs resmi: www.quickfix.id',
          ]),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Kebijakan Privasi', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Text('Kebijakan Privasi', style: titleStyle),
              const SizedBox(height: 8),
              Text('Kebijakan ini menjelaskan bagaimana QuickFix mengumpulkan, menggunakan, menyimpan, dan melindungi data pribadi Anda saat menggunakan aplikasi kami. Dengan menggunakan layanan QuickFix, Anda menyetujui praktik yang dijelaskan dalam kebijakan ini.',
              style: bodyStyle,),
              const SizedBox(height: 14),
              Text('Informasi tentang bagaimana QuickFix mengelola dan menjaga data pengguna.',style: bodyStyle.copyWith(color: Colors.grey[700]),),
              const SizedBox(height: 18),

              // content (ExpansionTile list)
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
                  '© 2025 QuickFix. Semua hak dilindungi.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]) ?? TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTile(BuildContext context, _SectionData data, TextStyle sectionStyle, TextStyle bodyStyle) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      initiallyExpanded: data.index == 0, // keep first section open
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
        '${index == 0 ? '' : index}.',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

  static Widget _bulletList(BuildContext context, List<String> items) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5) ?? const TextStyle(fontSize: 14, height: 1.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6, right: 8),
                    child: Icon(Icons.fiber_manual_record, size: 8),
                  ),
                  Expanded(child: Text(i, style: textStyle)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SectionData {
  final int index;
  final String title;
  final List<Widget> contentWidgets;

  _SectionData({required this.index, required this.title, required this.contentWidgets});
}
