import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormPemesananPage extends StatefulWidget {
  const FormPemesananPage({super.key});

  @override
  State<FormPemesananPage> createState() => _FormPemesananPageState();
}

class _FormPemesananPageState extends State<FormPemesananPage> {
  String? selectedMetode;

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0C4481);
    const Color accentYellow = Color(0xFFFECC32);
    const Color whiteColor = Color(0xFFFEFEFE);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(84),
        child: AppBar(
          backgroundColor: primaryBlue,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'Pesanan',
              style: GoogleFonts.inter(
                color: whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: whiteColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Kategori Layanan ===
            _roundedCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kategori Layanan',
                      style: GoogleFonts.lato(color: Colors.grey, fontSize: 13)),
                  Text('Elektronik',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // === Tukang ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/images/default_user.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vannes Wijaya',
                            style: GoogleFonts.inter(
                                color: whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 6),
                        _serviceRow('Servis AC'),
                        _serviceRow('Servis Mesin Cuci'),
                        _serviceRow('Servis Mesin Cuci'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // === Deskripsi Masalah ===
            _roundedCard(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      maxLines: 3,
                      style: GoogleFonts.lato(),
                      decoration: const InputDecoration(
                        hintText: 'Deskripsi Masalah',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Icon(Icons.image, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // === Tanggal & Jam ===
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _roundedCard(
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.grey, size: 20),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal',
                                style: GoogleFonts.lato(
                                    color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 6),
                            Text('30 Sep 2025',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _roundedCard(
                    child: Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: Colors.grey, size: 20),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jam',
                                style: GoogleFonts.lato(
                                    color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 6),
                            Text('09:00',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // === Alamat ===
            _roundedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alamat',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    'Jl. Ahmad Yani, Tlk. Tering, Kec. Batam Kota, Kota Batam, Kepulauan Riau',
                    style: GoogleFonts.lato(
                        fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Center(
                      child: Text(
                        'Tap untuk menentukan titik lokasi',
                        style: GoogleFonts.lato(
                            color: whiteColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // === Ringkasan Pembayaran ===
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(22)),
                    ),
                    child: Text(
                      'Ringkasan Pembayaran',
                      style: GoogleFonts.inter(
                          color: whiteColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        _paymentRow('Servis AC', '000,000'),
                        _paymentRow('Servis Mesin Cuci', '000,000'),
                        _paymentRow('Servis Mesin Cuci', '000,000'),
                        const Divider(),
                        _paymentRow('Total Pembayaran', '000,000',
                            isBold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // === Metode Pembayaran ===
            _roundedCard(
              child: DropdownButtonFormField<String>(
                value: selectedMetode,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Pilih Metode Pembayaran',
                  labelStyle: GoogleFonts.lato(color: Colors.grey),
                ),
                items: const [
                  DropdownMenuItem(value: 'qris', child: Text('QRIS')),
                  DropdownMenuItem(
                      value: 'va', child: Text('Virtual Account')),
                ],
                onChanged: (value) {
                  setState(() => selectedMetode = value);
                },
              ),
            ),
            const SizedBox(height: 20),

            // === Tombol Pesan Sekarang ===
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentYellow,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'Pesan Sekarang',
                  style: GoogleFonts.inter(
                      color: whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // === Helper Widgets ===

  static Widget _roundedCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFEFE),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget _serviceRow(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: GoogleFonts.lato(color: Colors.white, fontSize: 14)),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white),
            ),
            child: const Icon(Icons.check,
                color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  static Widget _paymentRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.lato(
                  fontWeight:
                      isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: GoogleFonts.lato(
                  fontWeight:
                      isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
