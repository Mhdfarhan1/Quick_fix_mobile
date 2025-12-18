import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../services/api_service.dart';
import '../../../config/base_url.dart';
import '../../../models/riwayat_pendapatan.dart';
import '../../../providers/auth_provider.dart';


class PendapatanPage extends StatefulWidget {
  const PendapatanPage({super.key});

  @override
  State<PendapatanPage> createState() => _PendapatanPageState();
}

class _PendapatanPageState extends State<PendapatanPage> {
  bool isBulanan = true;
  bool isLoading = true;
  bool isLoadingMore = false;

  int currentPage = 1;
  int lastPage = 1;

  List<double> values = [];
  List<RiwayatPendapatan> riwayat = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPendapatan(reset: true);
    });
  }

  String formatRupiah(num number) {
    final format = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return format.format(number);
  }

  Future<void> fetchPendapatan({bool reset = false}) async {
    if (reset) {
      currentPage = 1;
      riwayat.clear();
      values.clear();
      isLoading = true;
    } else {
      isLoadingMore = true;
    }

    setState(() {});

    final token = await ApiService.storage.read(key: 'token');

    if (token == null) {
      debugPrint('❌ Token kosong (ApiService)');
      return;
    }


    final res = await http.get(
      Uri.parse(
        '${BaseUrl.api}/teknisi/pendapatan'
        '?mode=${isBulanan ? 'bulanan' : 'tahunan'}'
        '&page=$currentPage',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    debugPrint('🔑 TOKEN: $token');
    debugPrint('🌐 URL: ${BaseUrl.api}/teknisi/pendapatan');
    debugPrint('📄 STATUS CODE: ${res.statusCode}');
    debugPrint('📦 BODY: ${res.body}');


    final json = jsonDecode(res.body);

    if (currentPage == 1) {
      values = (json['grafik'] as List)
        .map<double>((e) => double.parse(e['total'].toString()))
        .toList();

    }

    final data = json['riwayat']['data'] as List;
    lastPage = json['riwayat']['last_page'];

    riwayat.addAll(
      data.map((e) => RiwayatPendapatan.fromJson(e)).toList(),
    );

    isLoading = false;
    isLoadingMore = false;

    setState(() {});
  }




    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0C4481),
          foregroundColor: Colors.white,
          title: const Text("Riwayat Pendapatan"),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _toggleButton("Bulanan", isBulanan, () {
                        setState(() => isBulanan = true);
                        fetchPendapatan(reset: true);
                      }),
                      const SizedBox(width: 10),
                      _toggleButton("Tahunan", !isBulanan, () {
                        setState(() => isBulanan = false);
                        fetchPendapatan(reset: true);
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildBarChart(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildRiwayatList()),
                ],
              ),
      );
    }


    Widget _toggleButton(String text, bool active, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF0C4481) : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFF0C4481)),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: active ? Colors.white : const Color(0xFF0C4481),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    Widget _buildRiwayatList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        ...riwayat.map((item) {
          return _riwayatCard(
            title: item.namaKeahlian,
            tanggal: DateFormat('dd MMM yyyy', 'id_ID').format(item.tanggal),
            pendapatan: formatRupiah(item.amount),
          );
        }),
        if (currentPage < lastPage)
          TextButton(
            onPressed: isLoadingMore
                ? null
                : () {
                    currentPage++;
                    fetchPendapatan();
                  },
            child: isLoadingMore
                ? const CircularProgressIndicator()
                : const Text("Load More"),
          ),
      ],
    );
  }


  Widget _buildBarChart() {
    if (values.isEmpty) {
      return const Center(child: Text("Belum ada data grafik"));
    }

    final labels = isBulanan
        ? ["M1", "M2", "M3", "M4"]
        : ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"];

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 320,
      child: BarChart(
        BarChartData(
          maxY: maxValue * 1.2,
          barGroups: List.generate(values.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: _chartColor(i),
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }


  Color _chartColor(int index) {
    List<Color> colors = [
      Colors.redAccent,
      Colors.lightBlue,
      Colors.purpleAccent,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
      Colors.cyan,
      Colors.deepOrange,
      Colors.blueGrey,
    ];
    return colors[index % colors.length];
  }


  Widget _riwayatCard({
    required String title,
    required String tanggal,
    required String pendapatan,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F8FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(tanggal,
              style: const TextStyle(color: Colors.black54, fontSize: 14)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Pendapatan",
                  style: TextStyle(fontSize: 15, color: Colors.black54)),
              Text(
                pendapatan,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}
