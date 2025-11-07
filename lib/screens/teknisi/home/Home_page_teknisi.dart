import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_fix/screens/teknisi/profile/profile_menu.dart';
import 'package:quick_fix/screens/teknisi/progress/halaman_tugas_teknisi.dart';
import '../../../models/task_model.dart';
import '../../../services/task_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeTeknisiPage extends StatefulWidget {
  const HomeTeknisiPage({super.key});

  @override
  State<HomeTeknisiPage> createState() => _HomeTeknisiPageState();
}

class _HomeTeknisiPageState extends State<HomeTeknisiPage> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _taskService.fetchTasks(1); // contoh id teknisi
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Sedang dikerjakan":
        return Colors.blue;
      case "Tugas Baru":
        return Colors.green;
      case "Menunggu Konfirmasi":
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        backgroundColor: const Color(0xff004aad),
        title: const Text(
          "Halo, Fixer!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.white),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTaskSummary(),
                  const SizedBox(height: 12),
                  Column(
                    children: _tasks.map((task) => _buildTaskCard(task)).toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildMapSection(),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
  selectedItemColor: const Color(0xff004aad),
  unselectedItemColor: Colors.grey,
  currentIndex: 0, // Profil aktif
  onTap: (index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeTeknisiPage()),
        );
        break;
      case 1:
       Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HalamanTugasTeknisi(token:  '')),
        );
        break;
      case 2:
        
        break;
      case 3:
        
        break;
      case 4:
        // Profil sedang aktif → tidak perlu apa-apa
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileMenu()),
        );
        break;
    }
  },
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
    BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Pesanan"),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
    BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Obrolan"),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
  ],
),

    );
  }

  Widget _buildTaskSummary() {
    int baru = _tasks.where((t) => t.statusTugas == "Tugas Baru").length;
    int dikerjakan = _tasks.where((t) => t.statusTugas == "Sedang dikerjakan").length;
    int selesai = _tasks.where((t) => t.statusTugas == "Selesai").length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tugas Anda Hari Ini",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("Lihat Semua"),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem("Tugas Baru", baru.toString()),
              _buildSummaryItem("Sedang dikerjakan", dikerjakan.toString()),
              _buildSummaryItem("Selesai", selesai.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: const AssetImage('assets/images/teknisi.png'),
          radius: 24,
        ),
        title: Text(
          task.namaPelanggan,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.deskripsi),
            const SizedBox(height: 4),
            Text(task.estimasi, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(task.statusTugas).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            task.statusTugas,
            style: TextStyle(
              color: _getStatusColor(task.statusTugas),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(1.1201, 104.0483),
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.quick_fix',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: const LatLng(1.1201, 104.0483),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}