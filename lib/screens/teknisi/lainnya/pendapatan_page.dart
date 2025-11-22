import 'package:flutter/material.dart';

class PendapatanPage extends StatefulWidget {
  const PendapatanPage({super.key});

  @override
  State<PendapatanPage> createState() => _PendapatanPageState();
}

class _PendapatanPageState extends State<PendapatanPage> {
  bool isMingguan = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4481),
        foregroundColor: Colors.white,
        title: const Text("Pendapatan"),
      ),

      body: Column(
        children: [
          const SizedBox(height: 16),

          // =====================
          // TOGGLE BUTTON
          // =====================
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _toggleButton("Mingguan", isMingguan, () {
                setState(() => isMingguan = true);
              }),
              const SizedBox(width: 10),
              _toggleButton("Bulanan", !isMingguan, () {
                setState(() => isMingguan = false);
              }),
            ],
          ),

          const SizedBox(height: 20),

          // =====================
          // GRAFIK
          // =====================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _grafikPendapatan(),
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================
  // BUTTON CUSTOM
  // ===================================================
  Widget _toggleButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0C4481) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF0C4481)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF0C4481),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ===================================================
  // GRAFIK (FAKE DATANYA, NANTI BISA KAMU ISI)
  // ===================================================
  Widget _grafikPendapatan() {
    List<String> labels = isMingguan
        ? ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"]
        : ["M1", "M2", "M3", "M4", "M5", "M6", "M7"];

    List<double> values = isMingguan
        ? [100, 150, 180, 120, 200, 140, 160]
        : [500, 700, 400, 900, 600, 800, 750];

    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.cyan,
      Colors.teal,
    ];

    // mencari nilai terbesar untuk scaling grafik
    double maxValue = values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMingguan ? "Pendapatan Mingguan" : "Pendapatan Bulanan",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        const SizedBox(height: 12),

        // GRID + GRAPH
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Stack(
              children: [
                // ================================
                // GARIS GRID
                // ================================
                Positioned.fill(
                  child: Column(
                    children: List.generate(5, (i) {
                      return Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black12, width: 0.7),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // ================================
                // CHART
                // ================================
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: labels.length,
                  itemBuilder: (_, i) {
                    double barHeight = (values[i] / maxValue) * 220; // scaling

                    return Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // NIlai
                          Text(
                            values[i].toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // BAR DARI BAWAH DENGAN ANIMASI
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutBack,
                                width: 28,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: colors[i % colors.length],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          // LABEL
                          Text(
                            labels[i],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
