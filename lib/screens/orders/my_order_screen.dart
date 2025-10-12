import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../tugas/detail_tugas_screen.dart'; // ✅ pastikan file ini ada

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> ongoingOrders = [
    {
      "name": "Barji Jegel",
      "rating": 4.3,
      "service": "Pembersihan AC",
      "estimate": "35 Menit",
      "price": "Rp 50.000,-",
      "imageUrl":
          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
    },
    {
      "name": "Beno Arsudito",
      "rating": 4.5,
      "service": "Perbaikan TV",
      "estimate": "1 Jam",
      "price": "Rp 110.000,-",
      "imageUrl":
          "https://images.unsplash.com/photo-1603415526960-f7e0328c63b1",
    },
    {
      "name": "Hasan Ali",
      "rating": 4.2,
      "service": "Perbaikan Atap Rumah",
      "estimate": "35 Menit",
      "price": "Rp 189.000,-",
      "imageUrl":
          "https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget orderCard({
    required String name,
    required double rating,
    required String service,
    required String estimate,
    required String price,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(20),
        shadowColor: Colors.black26,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade100, width: 2),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(imageUrl),
                ),
              ),
              const SizedBox(width: 14),

              // Info utama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Service",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      service,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Estimasi Waktu: $estimate",
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54),
                    ),
                  ],
                ),
              ),

              // Tombol kanan
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(
                          name: name,
                          service: service,
                          estimate: estimate,
                          price: price,
                          imageUrl: imageUrl,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Lihat Status",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                  const SizedBox(height: 12),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTab(String title, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0A4CA7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    "Pesanan",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),

            // TABBAR
            Container(
              margin: const EdgeInsets.only(top: 12),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF0A4CA7),
                indicatorWeight: 3,
                tabs: [
                  buildTab("Pesanan Berlangsung", ongoingOrders.length),
                  buildTab("Pesanan Selesai", 0),
                ],
              ),
            ),

            // TABBAR VIEW
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView.builder(
                    itemCount: ongoingOrders.length,
                    itemBuilder: (context, index) {
                      final order = ongoingOrders[index];
                      return orderCard(
                        name: order["name"],
                        rating: order["rating"],
                        service: order["service"],
                        estimate: order["estimate"],
                        price: order["price"],
                        imageUrl: order["imageUrl"],
                      );
                    },
                  ),
                  // Pesanan selesai (kosong)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          "assets/lottie/empty.json",
                          width: 200,
                          height: 200,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Belum ada pesanan selesai",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
}
