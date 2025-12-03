import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class PendapatanPage extends StatefulWidget {
  const PendapatanPage({super.key});

  @override
  State<PendapatanPage> createState() => _PendapatanPageState();
}

class _PendapatanPageState extends State<PendapatanPage> {
  bool isBulanan = true;

  String formatRupiah(num number) {
    final format = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return format.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Riwayat Pendapatan"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _toggleButton("Bulanan", isBulanan, () {
                setState(() => isBulanan = true);
              }),
              const SizedBox(width: 10),
              _toggleButton("Tahunan", !isBulanan, () {
                setState(() => isBulanan = false);
              }),
            ],
          ),
          const SizedBox(height: 20),
          _buildBarChart(),

          const SizedBox(height: 20),

          _riwayatCard(
            title: "Pekerjaan #12345",
            tanggal: "12 Juni 2024",
            pendapatan: formatRupiah(250000),
          ),
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

  Widget _buildBarChart() {
    List<double> values = isBulanan
        ? [150000, 70000, 200000, 120000]
        : [
            1500000,
            2000000,
            1750000,
            2200000,
            1800000,
            2100000,
            2300000,
            2500000,
            2000000,
            1900000,
            2400000,
            2600000
          ];

    List<String> labels = isBulanan
        ? ["M1", "M2", "M3", "M4"]
        : [
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "Mei",
            "Jun",
            "Jul",
            "Agu",
            "Sep",
            "Okt",
            "Nov",
            "Des"
          ];

    double maxValue = values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        Text(
          isBulanan ? "November" : "2025",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 320,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BarChart(
              BarChartData(
                maxY: maxValue * 1.2, // beri sedikit padding atas
                minY: 0,
                barGroups: List.generate(values.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        width: isBulanan ? 28 : 16,
                        borderRadius: BorderRadius.circular(6),
                        color: _chartColor(i),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxValue * 1.2,
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Text(
                            labels[idx],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 4,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        formatRupiah(rod.toY),
                        const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 400),
              swapAnimationCurve: Curves.easeOut,
            ),
          ),
        ),
      ],
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
