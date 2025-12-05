import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_fix/services/api_service.dart';

// =================================================================
// 🎨 THEME & COLORS (Modern Palette)
// =================================================================
class AppTheme {
  static const Color primary = Color(0xFF0C4481); // Biru Utama
  static const Color secondary = Color(0xFF48A9FE);
  static const Color bg = Color(0xFFF8F9FD); // Cool Gray Background
  static const Color surface = Colors.white;
  static const Color textMain = Color(0xFF1A1D1E);
  static const Color textSub = Color(0xFF6C757D);

  // Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF0984E3);
  static const Color neutral = Color(0xFFB2BEC3);
}

// =================================================================
// 📱 MAIN PAGE: RIWAYAT KOMPLAIN
// =================================================================

class RiwayatKomplainPage extends StatefulWidget {
  const RiwayatKomplainPage({super.key});

  @override
  State<RiwayatKomplainPage> createState() => _RiwayatKomplainPageState();
}

class _RiwayatKomplainPageState extends State<RiwayatKomplainPage> {
  bool isLoading = true;
  List complaints = [];

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  void _navigateToDetail(Map<String, dynamic> complaintData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RiwayatKomplainDetailPage(data: complaintData),
      ),
    );
  }

  Future<void> fetchComplaints() async {
    setState(() => isLoading = true);
    try {
      final token = await ApiService.storage.read(key: "token");
      if (token == null || token.isEmpty) {
        if (mounted) _snack("Sesi habis. Login ulang.");
        setState(() => isLoading = false);
        return;
      }

      final url = Uri.parse("http://192.168.1.6:8000/api/complaints");
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = (json is Map && json['data'] != null) ? json['data'] as List : [];
        setState(() {
          complaints = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (mounted) _snack("Gagal memuat (${response.statusCode})");
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) _snack("Koneksi bermasalah");
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.primary, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Riwayat Komplain",
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 20),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchComplaints,
        color: AppTheme.primary,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : complaints.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final c = complaints[index] as Map<String, dynamic>;
            return _PremiumCard(
              data: c,
              onTap: () => _navigateToDetail(c),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Icon(Icons.assignment_outlined, size: 60, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 20),
          Text(
            "Belum Ada Komplain",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            "Semua laporan Anda akan muncul di sini.",
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// 💎 PREMIUM CARD COMPONENT
// =================================================================

class _PremiumCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _PremiumCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String jenis = data['jenis_masalah'] ?? 'Masalah';
    final String status = data['status'] ?? 'baru';
    final String kategori = data['kategori'] ?? 'lain';

    // Config berdasarkan status
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'baru': statusColor = AppTheme.warning; break;
      case 'diproses': statusColor = AppTheme.info; break;
      case 'selesai': statusColor = AppTheme.success; break;
      default: statusColor = AppTheme.neutral;
    }

    // Config Icon
    IconData icon;
    switch (kategori.toLowerCase()) {
      case 'pesanan': icon = Icons.local_mall_outlined; break;
      case 'pembayaran': icon = Icons.account_balance_wallet_outlined; break;
      case 'aplikasi': icon = Icons.phonelink_setup_outlined; break;
      default: icon = Icons.article_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C4481).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Status Strip (Garis warna di kiri)
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        // Icon dengan Hero Animation
                        Hero(
                          tag: 'icon_${data['id']}',
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.bg,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(icon, color: AppTheme.primary, size: 24),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Texts
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                jenis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppTheme.textMain,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _SmallBadge(text: kategori.toUpperCase()),
                                  const SizedBox(width: 8),
                                  // Status Text Kecil
                                  Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: statusColor,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Arrow
                        Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;
  const _SmallBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: AppTheme.textSub, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// =================================================================
// 📄 DETAIL PAGE: MODERN & CLEAN (Updated)
// =================================================================

class RiwayatKomplainDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const RiwayatKomplainDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String jenis = data['jenis_masalah'] ?? 'N/A';
    final String deskripsi = data['deskripsi'] ?? '-';
    final String status = data['status'] ?? 'baru';
    final String kategori = data['kategori'] ?? 'Lain-lain';
    final String tanggal = data['tanggal_lapor'] ?? '-';
    final String balasanAdmin = data['balasan_admin'] ?? '';

    // ⭐ UPDATE: Ekstraksi Nomor Pesanan agar aman (handle null dan int)
    final String nomorPesanan = data['nomor_pesanan'] != null ? data['nomor_pesanan'].toString() : '-';

    final String metodePembayaran = data['metode_pembayaran'] != null ? data['metode_pembayaran'].toString() : '-';

    IconData icon;
    switch (kategori.toLowerCase()) {
      case 'pesanan': icon = Icons.local_mall_outlined; break;
      case 'pembayaran': icon = Icons.account_balance_wallet_outlined; break;
      case 'aplikasi': icon = Icons.phonelink_setup_outlined; break;
      default: icon = Icons.article_outlined;
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Detail Komplain", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- HEADER CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'icon_${data['id']}',
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: AppTheme.primary, size: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    jenis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tanggal,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSub),
                  ),
                  const SizedBox(height: 16),
                  _StatusPill(status: status),
                  const SizedBox(height: 24),

                  // Grid Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _InfoBit(label: "Kategori", value: kategori.toUpperCase()),

                      // ⭐ UPDATE: Tampilkan Nomor Pesanan jika ada (tanpa cek kategori)
                      if (nomorPesanan != '-')
                        _InfoBit(label: "No. Pesanan", value: nomorPesanan),

                      if (metodePembayaran != '-')
                        _InfoBit(label: "Pembayaran", value: metodePembayaran),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- DESKRIPSI ---
            _SectionHeader(title: "Deskripsi Masalah"),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                deskripsi,
                style: const TextStyle(fontSize: 15, height: 1.6, color: AppTheme.textMain),
              ),
            ),

            const SizedBox(height: 24),

            // --- ADMIN REPLY (CHAT STYLE) ---
            _SectionHeader(title: "Balasan Admin"),
            _AdminChatBubble(reply: balasanAdmin),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------
// KOMPONEN PENDUKUNG (Status, Chat, dll)
// -----------------------------------------------------------

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'baru': color = AppTheme.warning; break;
      case 'diproses': color = AppTheme.info; break;
      case 'selesai': color = AppTheme.success; break;
      default: color = AppTheme.neutral;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12, letterSpacing: 1),
      ),
    );
  }
}

class _InfoBit extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBit({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSub)),
          const SizedBox(height: 4),
          Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain),
              overflow: TextOverflow.ellipsis
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSub)),
      ),
    );
  }
}

class _AdminChatBubble extends StatelessWidget {
  final String reply;
  const _AdminChatBubble({required this.reply});

  @override
  Widget build(BuildContext context) {
    if (reply.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_chat_unread_outlined, color: Colors.grey.shade400),
            const SizedBox(width: 10),
            Text("Belum ada tanggapan.", style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.support_agent, color: AppTheme.success, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Customer Support", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.success)),
                const SizedBox(height: 6),
                Text(reply, style: const TextStyle(fontSize: 14, color: AppTheme.textMain, height: 1.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}