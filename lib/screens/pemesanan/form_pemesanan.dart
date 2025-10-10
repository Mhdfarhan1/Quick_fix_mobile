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
    const Color primaryYellow = Color(0xFFFECC32);
    const Color pureWhite = Color(0xFFFEFEFE);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Pesanan",
          style: GoogleFonts.inter(
            color: pureWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Kategori Layanan ---
            _roundedContainer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Kategori Layanan",
                      style: GoogleFonts.lato(color: Colors.grey, fontSize: 14)),
                  Text("Elektronik",
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Tukang Service ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(30),
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
                    radius: 28,
                    backgroundImage: AssetImage('assets/images/default_user.png'),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vannes Wijaya",
                          style: GoogleFonts.inter(
                            color: pureWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildServiceItem("Servis AC"),
                        _buildServiceItem("Servis Mesin Cuci"),
                        _buildServiceItem("Servis Kulkas"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Deskripsi Masalah ---
            _roundedContainer(
              child: TextField(
                maxLines: 3,
                style: GoogleFonts.lato(),
                decoration: const InputDecoration(
                  hintText: "Deskripsi Masalah",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Tanggal & Jam ---
            Row(
              children: [
                Expanded(
                  child: _roundedContainer(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tanggal",
                                style: GoogleFonts.lato(
                                    color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text("30 Sep 2025",
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
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: pureWhite,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: primaryBlue, width: 2),
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
                        const Icon(Icons.access_time,
                            size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Jam",
                                style: GoogleFonts.lato(
                                    color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text("09:00",
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
            const SizedBox(height: 16),

            // --- Alamat ---
            _roundedContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Alamat",
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    "Jl. Ahmad Yani, Tlk. Tering, Kec. Batam Kota, Kota Batam, Kepulauan Riau",
                    style: GoogleFonts.lato(
                        fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Tap untuk menentukan titik lokasi",
                      style:
                          GoogleFonts.lato(color: pureWhite, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Ringkasan Pembayaran ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ringkasan Pembayaran",
                      style: GoogleFonts.inter(
                          color: pureWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildPaymentItem("Servis AC", "150.000"),
                  _buildPaymentItem("Servis Mesin Cuci", "120.000"),
                  _buildPaymentItem("Servis Kulkas", "130.000"),
                  const Divider(color: pureWhite, thickness: 0.8),
                  _buildPaymentItem("Total Pembayaran", "400.000", bold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Metode Pembayaran ---
            _roundedContainer(
              child: DropdownButtonFormField<String>(
                value: selectedMetode,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "Pilih Metode Pembayaran",
                  labelStyle: GoogleFonts.lato(color: Colors.grey),
                ),
                items: const [
                  DropdownMenuItem(value: "qris", child: Text("QRIS")),
                  DropdownMenuItem(
                      value: "va", child: Text("Virtual Account")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedMetode = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // --- Tombol Pesan Sekarang ---
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryYellow,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Pesan Sekarang",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: pureWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Rounded Container
  static Widget _roundedContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFEFE),
        borderRadius: BorderRadius.circular(30),
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

  static Widget _buildServiceItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_box, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(title,
              style: GoogleFonts.lato(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  static Widget _buildPaymentItem(String title, String value,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
