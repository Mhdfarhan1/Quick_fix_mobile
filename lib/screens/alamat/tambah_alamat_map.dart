import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/base_url.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/api_service.dart';

class TambahAlamatMap extends StatefulWidget {
  const TambahAlamatMap({super.key});

  @override
  State<TambahAlamatMap> createState() => _TambahAlamatMapState();
}

class _TambahAlamatMapState extends State<TambahAlamatMap>
    with SingleTickerProviderStateMixin {
  LatLng current = LatLng(-6.2000, 106.8166);
  LatLng? userLocation;
  String alamat = "";
  String label = "";
  String? countryCode; // <- Tambahan untuk filter negara
  bool saving = false;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();


  final TextEditingController searchC = TextEditingController();
  final mapController = MapController();
  List<dynamic> suggestions = [];

  late AnimationController pin;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    pin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.7,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    pin.dispose();
    super.dispose();
  }

  /// Ambil lokasi pengguna
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        current = LatLng(pos.latitude, pos.longitude);
        userLocation = current;
      });

      await reverseGeo();
      mapController.move(current, 16);
    } catch (e) {
      debugPrint("Lokasi gagal: $e");
    }
  }

  /// Reverse geocoding + ambil kode negara
  Future<void> reverseGeo() async {
    try {
      List<Placemark> place =
          await placemarkFromCoordinates(current.latitude, current.longitude);

      final p = place.first;
      setState(() {
        alamat =
            "${p.street}, ${p.locality}, ${p.administrativeArea}, ${p.country}";
        countryCode = p.isoCountryCode?.toLowerCase(); // misal: "id"
      });
    } catch (_) {
      setState(() {
        alamat = "Tidak dapat memuat detail alamat";
      });
    }
  }

  double distanceBetween(LatLng a, LatLng b) {
    const R = 6371000;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;

    final h = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    return R * 2 * atan2(sqrt(h), sqrt(1 - h));
  }

  /// 🔍 Autocomplete dalam negara pengguna
  Future<void> fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    String cc = countryCode ?? "id"; // default Indonesia
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$query&countrycodes=$cc&format=json&addressdetails=1&limit=7");

    final res = await http.get(url, headers: {'User-Agent': 'QuickFixApp/1.0'});

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (userLocation != null) {
        data.sort((a, b) {
          final latA = double.tryParse(a['lat'] ?? "0") ?? 0;
          final lonA = double.tryParse(a['lon'] ?? "0") ?? 0;
          final latB = double.tryParse(b['lat'] ?? "0") ?? 0;
          final lonB = double.tryParse(b['lon'] ?? "0") ?? 0;

          final distA =
              distanceBetween(userLocation!, LatLng(latA, lonA));
          final distB =
              distanceBetween(userLocation!, LatLng(latB, lonB));

          return distA.compareTo(distB);
        });
      }

      setState(() {
        suggestions = data;
      });
    }
  }

  void selectSuggestion(dynamic place) {
    final lat = double.parse(place['lat']);
    final lon = double.parse(place['lon']);
    setState(() {
      current = LatLng(lat, lon);
      alamat = place['display_name'];
      suggestions = [];
      searchC.text = place['display_name'];
    });
    mapController.move(current, 16);
  }

  Future<void> saveAlamat() async {
    if (saving) return;
    setState(() => saving = true);

    final prefs = await SharedPreferences.getInstance();
    final token = await ApiService.storage.read(key: 'token');

    print("TOKEN DARI STORAGE: ${prefs.getString('token')}");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kamu belum login / token kosong")),
      );
      setState(() => saving = false);
      return;
    }

    final body = {
      "label": label.isEmpty ? "Lainnya" : label,
      "alamat_lengkap": alamat,
      "latitude": current.latitude,
      "longitude": current.longitude,
      "is_default": 0
    };

    print("📤 KIRIM DATA: $body");
    print("🔑 TOKEN: $token");

    final res = await http.post(
      Uri.parse("${BaseUrl.api}/alamat"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(body),
    );

    print("📥 STATUS CODE: ${res.statusCode}");
    print("📥 RESPONSE: ${res.body}");

    if (!mounted) return;
    setState(() => saving = false);

    if (res.statusCode == 201 || res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alamat berhasil disimpan ✅")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: ${res.statusCode}\n${res.body}")),
      );
    }
  }
  


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black26,
        elevation: 0,
        title: const Text("Tentukan Lokasi"),
      ),
      body: Stack(
        children: [
          /// 🌍 Peta
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: current,
              zoom: 15,
              onPositionChanged: (pos, _) {
                setState(() => current = pos.center!);
                reverseGeo();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              )
            ],
          ),

          /// 📍 Pin
          Center(
            child: ScaleTransition(
              scale: CurvedAnimation(parent: pin, curve: Curves.easeOut),
              child: const Icon(Icons.location_on, size: 46, color: Colors.red),
            ),
          ),

          /// 🔍 Kolom pencarian + hasil suggestion
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: searchC,
                    onChanged: fetchSuggestions,
                    decoration: const InputDecoration(
                      hintText: "Cari alamat (contoh: Poltek Batam)",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14), // ✅ teks rata tengah
                    ),
                  ),
                ),

                if (suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: suggestions.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = suggestions[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300, // warna garis antar item
                                width: 1, // ketebalan garis
                              ),
                            ),
                          ),
                          child: ListTile(
                            dense: true, // bikin item lebih rapat
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                            title: Text(
                              item['display_name'],
                              style: const TextStyle(fontSize: 14),
                            ),
                            onTap: () => selectSuggestion(item),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          /// 🟡 Bottom info alamat
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(alamat, textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                        hintText: "Label (Rumah/Kantor/...)"),
                    onChanged: (v) => label = v,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: saveAlamat,
                    child: const Text("Gunakan Lokasi Ini"),
                  )
                ],
              ),
            ),
          ),

          /// 📌 Tombol "Gunakan Lokasi Saya"
          Positioned(
            bottom: 200,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
