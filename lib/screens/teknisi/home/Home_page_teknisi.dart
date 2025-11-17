import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/task_model.dart';
import '../profile/prof_tek.dart';
import '../riwayat/riwayat_teknisi_page.dart';
import '../lainnya/lainnya_page.dart';
import '../pesan/pesan_teknisi_page.dart';
import '../home/chat_teknisi_page.dart';
import '../../teknisi/home/chat_detail_teknisi_page.dart';
import '../home/notifikasi_page.dart';


class HomeTeknisiPage extends StatefulWidget {
  const HomeTeknisiPage({super.key});

  @override
  State<HomeTeknisiPage> createState() => _HomeTeknisiPageState();
}

class _HomeTeknisiPageState extends State<HomeTeknisiPage> {
  List<Task> tasks = []; // ✅ fix: inisialisasi langsung
  bool _isSiapKerja = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDummyTasks();
  }

  void _loadDummyTasks() {
    final now = DateTime.now();
    tasks = [
      Task(
        id: 1,
        namaPelanggan: 'Rani Syahrini',
        deskripsi: 'AC tidak dingin',
        statusTugas: 'Sedang Dikerjakan',
        harga: 150000,
        alamatLengkap: 'Jl. Merpati No. 12',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      Task(
        id: 2,
        namaPelanggan: 'Mahfuz Hadid',
        deskripsi: 'Lampu mati total',
        statusTugas: 'Tugas Baru',
        harga: 80000,
        alamatLengkap: 'Jl. Kenari No. 9',
        createdAt: now,
      ),
      Task(
        id: 3,
        namaPelanggan: 'Rani Syahrini',
        deskripsi: 'Pompa air bocor',
        statusTugas: 'Menunggu Konfirmasi',
        harga: 120000,
        alamatLengkap: 'Jl. Melati No. 4',
        createdAt: now,
      ),
    ];
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
                                    const ChatTeknisiPage(), // arah ke halaman chat
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
                        "Siap Kerja",
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
                        "Istirahat",
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
    final sedang = tasks
        .where(
          (t) =>
              t.statusTugas.toLowerCase().contains("sedang") ||
              t.statusTugas.toLowerCase().contains("berjalan"),
        )
        .toList();
    final baru = tasks
        .where((t) => t.statusTugas.toLowerCase() == "tugas baru")
        .toList();
    final selesai = tasks
        .where((t) => t.statusTugas.toLowerCase() == "selesai")
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: _buildHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProsesBerlangsung(sedang),
            const SizedBox(height: 16),
            _buildTugasHariIni(baru.length, sedang.length, selesai.length),
            const SizedBox(height: 16),
            _buildRiwayatBulanIni(),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // --- 🟢 PROSES SEDANG BERLANGSUNG ---
  Widget _buildProsesBerlangsung(List<Task> sedang) {
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
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sedang.length,
              itemBuilder: (context, i) {
                final t = sedang[i];
                final screenWidth = MediaQuery.of(context).size.width;

                return Container(
                  width:
                      screenWidth *
                      0.81, // ✅ lebar 90% layar biar penuh tapi masih bisa geser
                  margin: EdgeInsets.only(
                    right: 12,
                    left: i == 0 ? 16 : 0, // jarak kiri hanya di item pertama
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
                        backgroundImage: AssetImage(
                          'assets/images/teknisi_avatar.png',
                        ),
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
                              DateFormat('HH:mm').format(t.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade800,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Sedang dikerjakan",
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
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
  Widget _buildTugasHariIni(int baru, int sedang, int selesai) {
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
                    "Tugas Anda Hari Ini",
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
                    _statusBox("Dijadwalkan", 2),
                    _statusBox("Sedang bekerja", 1),
                    _statusBox("Terlambat", 1),
                    _statusBox("Selesai", 3),
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
        _pesananBaruCard("Mahfuz Hadid", "Lampu mati total", "19:20"),
        const SizedBox(height: 8),
        _pesananBaruCard("Rani Syahrini", "Pompa air bocor", "20:55"),
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

  Widget _pesananBaruCard(String nama, String deskripsi, String jam) {
    return Container(
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
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  deskripsi,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                Text(
                  jam,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFCC33),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            ),
            child: const Text(
              "Terima",
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCount(String label, int count) => Column(
    children: [
      Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ],
  );

  Widget _buildTaskCard(Task t) {
    Color badgeColor;
    String badgeText = t.statusTugas;
    switch (t.statusTugas.toLowerCase()) {
      case "tugas baru":
        badgeColor = Colors.green.shade300;
        break;
      case "menunggu konfirmasi":
        badgeColor = Colors.amber.shade300;
        break;
      default:
        badgeColor = Colors.grey.shade400;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
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
              children: [
                Text(
                  t.namaPelanggan,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  t.deskripsi,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                Text(
                  DateFormat('HH:mm').format(t.createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(badgeText, style: const TextStyle(fontSize: 11)),
          ),
        ],
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
          MaterialPageRoute(builder: (_) => const TechnicianProfilePage()),
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
        color: Colors.white,
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
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onNavTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
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
                      child: Icon(
                        item.icon,
                        color: active ? highlight : Colors.grey,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: active ? highlight : Colors.grey,
                      ),
                    ),
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
