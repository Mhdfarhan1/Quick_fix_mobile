import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/task_model.dart';
import '../profile/prof_tek.dart';
import '../riwayat/riwayat_teknisi_page.dart';
import '../lainnya/lainnya_page.dart';
import '../pesan/pesan_teknisi_page.dart';
import '../kerja/sedang_bekerja_page.dart';
import '../kerja/menuju_kerja_page.dart';
import '../home/chat_teknisi_page.dart';
import '../home/notifikasi_page.dart';
import '../../../services/task_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import '../verifikasi/verifikasi_teknisi_page.dart';
import '../../chat/chat_list_page.dart';
import '../pesan/terima_pesanan_page.dart';




class HomeTeknisiPage extends StatefulWidget {
  const HomeTeknisiPage({super.key});

  @override
  State<HomeTeknisiPage> createState() => _HomeTeknisiPageState();
}

class _HomeTeknisiPageState extends State<HomeTeknisiPage> {
  List<Task> tasks = [];
  List<Task> tugasHariIni = [];
  List<Task> pesananBaru = [];

  bool _isSiapKerja = true;
  int _currentIndex = 0;

  bool _isVerified = false;
  bool _checkingVerification = true;
  bool _isSubmitted = false;

  bool _loadingTasks = true;
  bool _loadingPesananBaru = true;

  String? namaTeknisi;
  bool _loadingNama = true;

  String limitText(String text, int limit) {
    if (text.length <= limit) return text;
    return text.substring(0, limit) + "...";
  }

  Future<void> _onRefresh() async {
    await loadUser(); // ⬅️ refresh nama teknisi
    await _checkVerificationStatus();
    await _loadPesananBaru();
    await _loadTasksFromAPI();
  }


  Future<void> loadUser() async {
    setState(() => _loadingNama = true);

    try {
      final res = await ApiService.request(
        method: 'GET',
        endpoint: '/me', // endpoint user login
      );

      if (res['statusCode'] == 200 && res['data'] != null) {
        setState(() {
          namaTeknisi = res['data']['nama']; // ⬅️ ambil dari tabel user
          _loadingNama = false;
        });
      } else {
        _loadingNama = false;
      }
    } catch (e) {
      _loadingNama = false;
    }
  }





  Widget _buildUploadVerificationCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const VerifikasiTeknisiPage(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0C4481).withOpacity(0.08), // transparan biru
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF0C4481).withOpacity(0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(
              Icons.upload_file,
              color: Color(0xFF0C4481),
              size: 26,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                "Lengkapi dokumen verifikasi untuk mulai menerima pesanan",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0C4481),
                  height: 1.3,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Color(0xFF0C4481),
            ),
          ],
        ),
      ),
    );
  }


  // ===============================
  // CARD: MENUNGGU VERIFIKASI
  // ===============================
  Widget _buildWaitingVerificationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        children: const [
          Icon(Icons.hourglass_top, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Dokumen sudah dikirim. Menunggu verifikasi admin.",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }




  @override
  void initState() {
    super.initState();
    loadUser(); // ⬅️ WAJIB (ambil nama teknisi)
    _checkVerificationStatus();
    _loadPesananBaru();
    _loadTasksFromAPI();
  }

  Future<void> _checkVerificationStatus() async {
    try {
      // 1. Panggil API
      final res = await ApiService.request(
        method: 'GET',
        endpoint: '/teknisi/verifikasi/status',
      );

      print("DEBUG RESP API: $res"); // Cek ini di Debug Console!

      if (res['statusCode'] == 200 && res['data'] != null) {

        // 2. AMBIL DATA JSON
        final data = res['data'];

        // 3. LOGIKA BARU (Membaca String)
        // Pastikan key JSON-nya sesuai dengan Controller Laravel Anda ('status')
        String statusServer = data['status'] ?? 'belum_verifikasi';

        // Jika kembaliannya ada di dalam objek 'data' lagi (tergantung controller)
        if (data['data'] != null && data['data'] is Map) {
          statusServer = data['data']['status'] ?? 'belum_verifikasi';
        }

        print("STATUS DI SERVER SEKARANG: $statusServer");

        setState(() {
          // 🟢 KUNCI PERBAIKAN: Bandingkan String, bukan Boolean
          _isVerified = (statusServer == 'disetujui'); // Harus sama persis tulisannya

          // Cek apakah sudah pernah upload (status bukan 'belum_verifikasi')
          _isSubmitted = (statusServer != 'belum_verifikasi');

          _checkingVerification = false;
        });

      } else {
        setState(() {
          _isVerified = false;
          _isSubmitted = false;
          _checkingVerification = false;
        });
      }
    } catch (e) {
      print("ERROR: $e");
      setState(() {
        _isVerified = false;
        _isSubmitted = false;
        _checkingVerification = false;
      });
    }
  }



  Future<void> _loadTasksFromAPI() async {
    setState(() => _loadingTasks = true);

    final service = TaskService();
    final data = await service.fetchTasks();

    setState(() {
      tasks = data;
      _loadingTasks = false;
    });
  }

  Future<void> _loadPesananBaru() async {
    setState(() => _loadingPesananBaru = true);

    final service = TaskService();
    final data = await service.fetchPesananBaru(  );

    setState(() {
      pesananBaru = data;
      _loadingPesananBaru = false;
    });
  }

  // --- 🟡 Header AppBar ---
  PreferredSizeWidget _buildHeader() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(150),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0C4481),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _loadingNama
                          ? "Selamat datang..."
                          : "Selamat datang, ${namaTeknisi?.split(' ').first ?? 'Teknisi'}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),


                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChatListPage(), // arah ke halaman chat
                              ),
                            );
                          },
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotifikasiPage(),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Istirahat dulu, ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        activeColor: const Color(0xFFFECC32),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.white54,
                        value: _isSiapKerja,
                        onChanged: (val) {
                          setState(() {
                            _isSiapKerja = val;
                          });
                        },
                      ),
                      const Text(
                        "Siap Kerja",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  // --- 🔵 BODY ---
  @override
  Widget build(BuildContext context) {
    final menunggu = pesananBaru.where((t) =>
      t.statusPekerjaan.trim().toLowerCase() == "menunggu_diterima"
    ).toList();

    final dijadwalkan = tasks.where((t) =>
        t.statusPekerjaan == "dijadwalkan"
    ).toList();

    final sedang = tasks.where((t) =>

        (t.statusPekerjaan == "menuju_lokasi" ||
        t.statusPekerjaan == "sedang_bekerja")
    ).toList();

    final selesai = tasks.where((t) =>

        t.statusPekerjaan == "selesai"
    ).toList();


    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: _buildHeader(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // ⬅️ WAJIB
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // 🔴🔴🔴 TARUH DI SINI 🔴🔴🔴
              if (!_checkingVerification && !_isVerified) ...[
                _isSubmitted
                    ? _buildWaitingVerificationCard()
                    : _buildUploadVerificationCard(),
                const SizedBox(height: 16),
              ],

              // ⬇️ BARU KONTEN NORMAL
              _buildProsesBerlangsung(sedang),
              const SizedBox(height: 16),

              _buildTugasHariIni(
                menunggu.length,
                dijadwalkan.length,
                sedang.length,
                selesai.length,
                menunggu,
              ),
              const SizedBox(height: 16),

              _buildRiwayatBulanIni(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget shimmerPesananBaru() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 90,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _shimmerProses() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }



  // --- 🟢 PROSES SEDANG BERLANGSUNG ---
  Widget _buildProsesBerlangsung(List<Task> sedang) {
    if (sedang.isEmpty && !_loadingTasks) return SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 245, 245),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Proses Sedang Berlangsung",
            style: TextStyle(
              color: Color(0xFF0C4481),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _loadingTasks
              ? _shimmerProses()
              : SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sedang.length,
                    itemBuilder: (context, i) {
                      final t = sedang[i];
                      final screenWidth = MediaQuery.of(context).size.width;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {

                            print("CARD DI KLIK: ${t.id} - ${t.statusPekerjaan}");

                            final token = await ApiService.storage.read(key: 'token');

                            if (token == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Token tidak ditemukan, silakan login ulang")),
                              );
                              return;
                            }

                            print("STATUS PEKERJAAN: ${t.statusPekerjaan}");

                            if (t.statusPekerjaan == "sedang_bekerja") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SedangBekerjaPage(
                                    idPemesanan: t.id,
                                    token: token,
                                    initialData: {
                                      "kode_pemesanan": t.kodePemesanan,
                                      "nama_pelanggan": t.namaPelanggan,
                                      "keluhan": t.deskripsi,
                                      "tanggal_booking": t.tanggalBooking != null
                                          ? DateFormat("yyyy-MM-dd").format(t.tanggalBooking!)
                                          : "-",
                                      "jam_booking": t.jamBooking ?? "-",
                                      "harga": t.harga,
                                      "alamat_lengkap": t.alamatLengkap ?? "-",
                                      "kota": t.kota ?? "-",
                                    },
                                  ),
                                ),
                              );
                            } else if (t.statusPekerjaan == "menuju_lokasi") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MenujuKerjaPage.fromTask(task: t),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Status tidak dikenali: ${t.statusPekerjaan}")),
                              );
                            }
                          },
                          child: Container(
                            width: screenWidth * 0.81,
                            margin: EdgeInsets.only(
                              right: 12,
                              left: i == 0 ? 16 : 0,
                            ),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD2F2F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 25,
                                  backgroundImage: AssetImage('assets/images/teknisi_avatar.png'),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        t.namaPelanggan,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        t.deskripsi,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        t.jamBooking ??
                                        (t.createdAt != null
                                            ? DateFormat('HH:mm').format(t.createdAt!)
                                            : "--:--"),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade800,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    t.statusPekerjaan == "menuju_lokasi"
                                        ? "Menuju Lokasi"
                                        : "Sedang Dikerjakan",
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  // --- 🟡 TUGAS HARI INI ---
  Widget _buildTugasHariIni(
      int menungguCount,
      int dijadwalkanCount,
      int sedangCount,
      int selesaiCount,
      List<Task> menungguList,
    ){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- BAGIAN ATAS: KOTAK TUGAS ANDA HARI INI ---
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0C4481),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Tugas Anda",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Lihat Semua",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statusBox("Dijadwalkan", dijadwalkanCount),
                    _statusBox("Sedang bekerja", sedangCount),


                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // --- BAGIAN BAWAH: PESANAN BARU NIH!! ---
        const Text(
          "Pesanan Baru Nihh!!",
          style: TextStyle(
            color: Color(0xFF0C4481),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        _loadingPesananBaru
            ? shimmerPesananBaru()
            : Column(
                children: menungguList.map((t) => _pesananBaruCard(t.toJson())).toList(),
              ),


      ],
    );
  }

  Widget _statusBox(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            color: Color(0xFF0C4481),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _pesananBaruCard(Map<String, dynamic> order) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPesananPage(order: order),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/images/teknisi_avatar.png'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order["nama_pelanggan"] ?? "-",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    limitText(order["keluhan"] ?? "-", 40),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    order["jam_booking"] ?? "-",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }




  // --- ⚙️ RIWAYAT BULAN INI ---
  Widget _buildRiwayatBulanIni() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Text(
            "Riwayat Bulan Ini",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C4481),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.wallet, color: Colors.green),
                SizedBox(width: 6),
                Text("Pendapatan: Rp 00.000,00"),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _RiwayatBox(icon: Icons.star, label: "Ulasan", value: "0,0"),
              _RiwayatBox(
                icon: Icons.done_all,
                label: "Pekerjaan Selesai",
                value: "0",
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    // 🔒 JIKA BELUM DIVERIFIKASI
    if (!_checkingVerification && !_isVerified) {

      // ❌ SELAIN BERANDA (0) DAN LAINNYA (4) TIDAK BOLEH
      if (index != 0 && index != 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Akun Anda belum diverifikasi. Lengkapi berkas terlebih dahulu.",
            ),
          ),
        );
        return; // ⛔ STOP TOTAL
      }
    }

    // ⬇️ AMAN, BOLEH LANJUT
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeTeknisiPage()),
        );
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PesananTeknisiPage()),
        );
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RiwayatTeknisiPage()),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileTeknisiPage.self(),
          ),
        );
        break;

      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LainnyaPage()),
        );
        break;
    }
  }




  Widget _buildCustomBottomNav() {
    const highlight = Color(0xFFFFCC33);

    final items = [
      _NavItem(icon: Icons.home, label: 'Beranda'),
      _NavItem(icon: Icons.assignment, label: 'Pesanan'),
      _NavItem(icon: Icons.history, label: 'Riwayat'),
      _NavItem(icon: Icons.person, label: 'Profil'),
      _NavItem(icon: Icons.more_horiz, label: 'Lainnya'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0C4481),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == _currentIndex;
          final item = items[i];

          // 🔒 KUNCI SELAIN BERANDA (0) & LAINNYA (4)
          final locked = !_checkingVerification &&
              !_isVerified &&
              i != 0 &&
              i != 4;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),

              // ⛔ NULL = BENAR-BENAR TIDAK BISA DIKLIK
              onTap: locked ? null : () => _onNavTap(i),

              child: Opacity(
                opacity: locked ? 0.45 : 1, // efek disable modern
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? highlight.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: active
                              ? highlight.withOpacity(0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
                              color: active
                                  ? highlight
                                  : Colors.white,
                            ),

                            // 🔐 ICON KUNCI
                            if (locked)
                              const Positioned(
                                right: -2,
                                top: -2,
                                child: Icon(
                                  Icons.lock,
                                  size: 12,
                                  color: Colors.white70,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: active ? highlight : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _RiwayatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _RiwayatBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blueGrey),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
