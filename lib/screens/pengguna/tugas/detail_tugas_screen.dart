import 'package:flutter/material.dart';
import 'dart:math' as math;

class OrderDetailScreen extends StatefulWidget {
  final String name;
  final String service;
  final String estimate;
  final String price;
  final String imageUrl;

  const OrderDetailScreen({
    super.key,
    required this.name,
    required this.service,
    required this.estimate,
    required this.price,
    required this.imageUrl,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 🔹 0 = Menunggu, 1 = Pengerjaan, 2 = Selesai
  int currentStep = 1;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔹 Widget langkah status
  Widget _buildStep(int index, String label) {
    bool isActive = index <= currentStep;
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              if (index != 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: Colors.grey.shade400,
                  ),
                ),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isActive ? Colors.black : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              if (index != 2)
                Expanded(
                  child: Container(
                    height: 2,
                    color: Colors.grey.shade400,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xFF0A4CA7),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // === GEAR BAGIAN ATAS (ikut scroll) ===
              Stack(
                alignment: Alignment.center,
                children: [
                  // Gear samar besar
                  Opacity(
                    opacity: 0.2,
                    child: Image.asset(
                      'assets/images/gearsbg.jpg',
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Gear biru berputar
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * math.pi,
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/images/cog.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // === PROGRESS STATUS BAR ===
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStep(0, "Menunggu"),
                      _buildStep(1, "Pengerjaan"),
                      _buildStep(2, "Selesai"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "19 Sep 25 17:00",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // === PROFIL TEKNISI ===
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(widget.imageUrl),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.service,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // === INFORMASI PESANAN ===
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Informasi Pesanan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Teknisi: ${widget.name}\n'
                  'Layanan: ${widget.service}\n'
                  'Estimasi: ${widget.estimate}\n'
                  'Harga: ${widget.price}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 30),

              // === STATUS PESANAN ===
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Status Pesanan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentStep == 0
                      ? 'Menunggu konfirmasi teknisi...'
                      : currentStep == 1
                          ? 'Sedang diproses oleh teknisi...'
                          : 'Pesanan telah selesai!',
                  style:
                      const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
