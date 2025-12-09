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

  bool _loadingTasks = true;
  bool _loadingPesananBaru = true;

  String limitText(String text, int limit) {
    if (text.length <= limit) return text;
    return text.substring(0, limit) + "...";
  }


  @override
  void initState() {
    super.initState();
    _loadPesananBaru();
    _loadTasksFromAPI();
    
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
                    const Text(
                      "Halo, Fixer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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

  // --- 🔻 Bottom Navigation ---
  void _onNavTap(int index) {
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
          MaterialPageRoute(builder: (_) => const ProfileTeknisiPage.self())
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
              color: Colors.black12, blurRadius: 6, offset: const Offset(0, -1))
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == _currentIndex;
          final item = items[i];
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onNavTap(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                decoration: BoxDecoration(
                  color:
                      active ? highlight.withOpacity(0.12) : Colors.transparent,
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
                      child: Icon(item.icon,
                          color: active ? highlight : const Color.fromARGB(255, 255, 255, 255), size: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(item.label,
                        style: TextStyle(
                            fontSize: 11,
                            color: active ? highlight : const Color.fromARGB(255, 255, 255, 255))),
                  ],
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
