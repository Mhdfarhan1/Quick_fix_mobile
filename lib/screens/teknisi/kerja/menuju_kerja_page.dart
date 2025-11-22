// file: proses_kerja_page_with_follow.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../config/base_url.dart';
import 'sedang_bekerja_page.dart';

class MenujuKerjaPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const MenujuKerjaPage({super.key, required this.data});

  @override
  State<MenujuKerjaPage> createState() => _MenujuKerjaPageState();
}

class _MenujuKerjaPageState extends State<MenujuKerjaPage>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _isFollowing = true;
  bool _userInteracted = false;

  String token = "";
  Map<String, dynamic>? dataPemesanan;

  LatLng pelangganPos = LatLng(0, 0);

  Timer? _trackingTimer;
  Timer? _pollingTimer;

  final int pollingIntervalSeconds = 5;
  final int trackingIntervalSeconds = 10;
  

  // Animasi marker teknisi
  late AnimationController _animController;
  late Animation<double> _anim;

  LatLng? _animatedPosition;
  LatLng? _targetPosition;
  LatLng? _startPosition;

  // OSRM
  List<LatLng> _routePoints = [];
  String _distanceText = "-";
  String _etaText = "-";

  void _onCenterButtonPressed() {
    if (_animatedPosition == null) return;

    _mapController.move(_animatedPosition!, _mapController.zoom);

    setState(() {
      _isFollowing = true;
      _userInteracted = false;
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Gagal"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _loadToken();
    dataPemesanan = widget.data;


    final data = widget.data;

    pelangganPos = LatLng(
      double.tryParse(data['latitude']?.toString() ?? '') ?? 0.0,
      double.tryParse(data['longitude']?.toString() ?? '') ?? 0.0,
    );

    final tekLat =
        double.tryParse(data['latitude_teknisi']?.toString() ?? '') ??
            pelangganPos.latitude;
    final tekLng =
        double.tryParse(data['longitude_teknisi']?.toString() ?? '') ??
            pelangganPos.longitude;

    _animatedPosition = LatLng(tekLat, tekLng);
    _targetPosition = _animatedPosition;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);

    _animController.addListener(() {
      if (_startPosition != null && _targetPosition != null) {
        final t = _anim.value;
        _animatedPosition = _lerpLatLng(_startPosition!, _targetPosition!, t);
        setState(() {});
      }
    });

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startPosition = _targetPosition;
      }
    });

    _fetchOnceAndStartPolling();
    _handleTrackingByStatus();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _trackingTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  // ========================== TRACKING CONTROL ==========================

  void _handleTrackingByStatus() {
    print("📦 RAW DATA: ${widget.data}");

    final status =
      widget.data['status_pekerjaan'] ??
      widget.data['data']?['status_pekerjaan'];

    print("📦 Status sekarang: $status");

    if (status == "menuju_lokasi") {
      _startTracking();
    } else {
      print("🚫 Tracking tidak jalan karena status: $status");
    }
  }


  void _startTracking() {
    final idTeknisi = int.parse(widget.data['id_teknisi'].toString());

    if (_trackingTimer != null) return;

    _trackingTimer =
        Timer.periodic(Duration(seconds: trackingIntervalSeconds), (timer) {
      updateLokasiTeknisi(idTeknisi);
    });

    print("🚀 Tracking ON");
  }

  void _stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    print("🛑 Tracking OFF");
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString("token");

    if (savedToken != null && savedToken.isNotEmpty) {
      setState(() {
        token = savedToken;
      });
      print("✅ Token dari storage: $token");
    } else {
      print("❌ Token tidak ditemukan di SharedPreferences");
    }
  }


  // ============================ LOCATION ============================

  Future<bool> requestLocationPermission() async {
    var status = await Geolocator.checkPermission();

    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }

    if (status == LocationPermission.deniedForever) {
      await openAppSettings();
      return false;
    }

    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  Future<void> updateLokasiTeknisi(int idTeknisi) async {
    bool izin = await requestLocationPermission();
    if (!izin) return;

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print("Kirim lokasi: ${pos.latitude}, ${pos.longitude}");

    final url = "${BaseUrl.api}/update-lokasi-teknisi";

    final res = await http.post(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
      body: {
        "id_teknisi": idTeknisi.toString(),
        "latitude": pos.latitude.toString(),
        "longitude": pos.longitude.toString(),
      },
    );

    print("STATUS API: ${res.statusCode}");
    print("BODY API: ${res.body}");
  }

  // ============================ POLLING ============================

  Future<void> _fetchOnceAndStartPolling() async {
    await _fetchTeknisiLocation();
    _pollingTimer =
        Timer.periodic(Duration(seconds: pollingIntervalSeconds), (_) {
      _fetchTeknisiLocation();
    });
  }

  Future<void> _fetchTeknisiLocation() async {
    try {
      final idTeknisi = widget.data['id_teknisi'].toString();
      final res = await http.get(
        Uri.parse("${BaseUrl.api}/lokasi-teknisi/$idTeknisi"),
      );

      if (res.statusCode != 200) return;

      final body = jsonDecode(res.body);

      if (!body['status']) return;

      final data = body['data'];

      if (data['latitude'] == null || data['longitude'] == null) return;

      final lat = double.parse(data['latitude'].toString());
      final lng = double.parse(data['longitude'].toString());

      if (lat == 0.0 || lng == 0.0) return;

      final newPos = LatLng(lat, lng);

      if (_targetPosition == null ||
          _distanceBetween(_targetPosition!, newPos) > 0.02) {
        _startPosition = _animatedPosition ?? newPos;
        _targetPosition = newPos;
        _animController.reset();
        _animController.forward();
      }

      _fetchRouteFromOSRM(newPos, pelangganPos);

      if (_isFollowing) {
        _mapController.move(newPos, _mapController.zoom);
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  // ============================ ROUTE ============================

  Future<void> _fetchRouteFromOSRM(LatLng from, LatLng to) async {
    if (from.latitude == 0 || to.latitude == 0) return;

    final res = await http.get(Uri.parse(
        "https://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?overview=full&geometries=geojson"));

    if (res.statusCode != 200) return;

    final json = jsonDecode(res.body);

    if (json['routes'] == null || json['routes'].isEmpty) return;

    final route = json['routes'][0];

    final coords = route['geometry']['coordinates'];

    _routePoints = coords.map<LatLng>((c) {
      return LatLng(
        (c[1] as num).toDouble(),
        (c[0] as num).toDouble(),
      );
    }).toList();

    _distanceText = _formatDistance(route['distance']);
    _etaText = _formatDuration(route['duration']);

    setState(() {});
  }

  Future<void> _handleSampaiLokasi() async {
    try {
      final int idPemesanan = int.parse(widget.data["id_pemesanan"].toString());

      if (token.isEmpty) {
        _showError("Token tidak ditemukan, silakan login ulang.");
        return;
      }

      print("🚀 Update status untuk pemesanan: $idPemesanan");

      final response = await http.post(
        Uri.parse("${BaseUrl.api}/teknisi/pemesanan/$idPemesanan/sampai-lokasi"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "status_pekerjaan": "sedang_bekerja",
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result["status"] == true) {
        print("✅ Status berhasil diubah ke sedang_bekerja");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SedangBekerjaPage(
              idPemesanan: idPemesanan,
              token: token,              // ✅ kirim token
              initialData: dataPemesanan, // ✅ kirim data
            ),
          ),
        );
      } else {
        _showError(result["message"] ?? "Gagal update status pekerjaan");
      }

    } catch (e) {
      print("❌ ERROR: $e");
      _showError("Terjadi kesalahan saat mengubah status.");
    }
  }


  // ============================ UTIL ============================

  LatLng _lerpLatLng(LatLng a, LatLng b, double t) {
    return LatLng(
      a.latitude + ((b.latitude - a.latitude) * t),
      a.longitude + ((b.longitude - a.longitude) * t),
    );
  }

  double _distanceBetween(LatLng a, LatLng b) {
    return Distance().as(LengthUnit.Kilometer, a, b);
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return "${meters.toInt()} m";
    return "${(meters / 1000).toStringAsFixed(2)} km";
  }

  String _formatDuration(double seconds) {
    final d = Duration(seconds: seconds.round());
    if (d.inHours > 0) return "${d.inHours} jam ${d.inMinutes % 60} mnt";
    return "${d.inMinutes} mnt";
  }

  // ============================ UI MAP ============================

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter:
            pelangganPos.latitude == 0 ? LatLng(-6.2, 106.8) : pelangganPos,
        initialZoom: 15,
        onPositionChanged: (_, hasGesture) {
          if (hasGesture) _isFollowing = false;
        },
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 4.5,
                color: Colors.blue,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: pelangganPos,
              width: 40,
              height: 40,
              child:
                  const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
            if (_animatedPosition != null)
              Marker(
                point: _animatedPosition!,
                width: 40,
                height: 40,
                child: const Icon(Icons.pedal_bike,
                    color: Colors.blue, size: 36),
              ),
          ],
        ),
      ],
    );
  }

  // ============================ BUILD UI ============================

  // ------------------
  // BUILD UI PAGE
  // ------------------
  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: const Color(0xffEAF4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xff0A4B88),
        title: const Text("Proses", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildMap(),

                Positioned(
                  top: 12,
                  left: 12,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _onCenterButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                        ),
                        child: const Text("Ikuti Teknisi"),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text("Jarak: $_distanceText",
                                style: const TextStyle(fontSize: 13)),
                            Text("ETA: $_etaText",
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // CARD BAWAH (UI asli)
          _buildBottomCard(data),
        ],
      ),
    );
  }

  // ------------------
  // Bottom card
  // ------------------
  Widget _buildBottomCard(data) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _buildHeaderLokasi(data),
          const SizedBox(height: 10),
          _buildUserInfo(data),
          const SizedBox(height: 10),
          _buildDetailLayanan(data),
          const SizedBox(height: 20),
          _buildTanggalWaktu(data),
          const SizedBox(height: 20),
          _buildButton(),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // =============================== UI ===============================
  Widget _buildHeaderLokasi(data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Color(0xff0A4B88),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        children: [
          Text(
            data['alamat_lengkap'] ?? "Alamat tidak tersedia",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 3),
          Text(
            data['kota'] ?? "",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.home_repair_service, color: Colors.white, size: 28),
              SizedBox(width: 20),
              Icon(Icons.arrow_forward, color: Colors.white, size: 26),
              SizedBox(width: 20),
              Icon(Icons.bike_scooter, color: Colors.white, size: 28),
              SizedBox(width: 20),
              Icon(Icons.arrow_forward, color: Colors.white, size: 26),
              SizedBox(width: 20),
              Icon(Icons.home, color: Colors.white, size: 28),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUserInfo(data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage("assets/images/profile.jpg"),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              data['nama_pelanggan'] ?? "Nama tidak ada",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.amber, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat_rounded, color: Colors.amber, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  String formatRupiah(dynamic harga) {
    if (harga == null) return "Rp 0,00";
    final number = double.tryParse(harga.toString()) ?? 0.0;
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2);
    return formatter.format(number);
  }

  Widget _buildDetailLayanan(data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xffF7F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['nama_Kategori'] ?? "Kategori",
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    data['nama_keahlian'] ?? "-",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  formatRupiah(data['harga']),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data['keluhan'] ?? "",
              style:
                  const TextStyle(fontSize: 14, color: Colors.black87, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTanggalWaktu(data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tanggal",
                    style: TextStyle(color: Colors.black54)),
                Text(
                  data['tanggal_booking'] ?? "-",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Waktu",
                    style: TextStyle(color: Colors.black54)),
                Text(
                  data['jam_booking'] ?? "-",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffFDBA12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _handleSampaiLokasi,
          child: const Text(
            "Sampai lokasi",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

}
