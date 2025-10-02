import 'package:flutter/material.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(rating.toString(),
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Text("Service", style: TextStyle(color: Colors.grey[700])),
                Text(service,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                Text("Estimasi Waktu : $estimate",
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12)),
                onPressed: () {},
                child: const Text("Lihat Status"),
              ),
              const SizedBox(height: 6),
              Text(price,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A4CA7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Text("My Order",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
            const SizedBox(height: 12),

            // TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.blue[100],
                ),
                tabs: const [
                  Tab(text: "Ongoing Orders"),
                  Tab(text: "Completed Orders"),
                ],
              ),
            ),

            // TabBar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Ongoing Orders
                  ListView(
                    children: [
                      orderCard(
                        name: "Ahmad Sahroji",
                        rating: 4.5,
                        service: "Perbaikan mesin cuci",
                        estimate: "1 Jam 35 Menit",
                        price: "Rp 85.000,-",
                        imageUrl:
                            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                      ),
                      orderCard(
                        name: "Barji Jegel",
                        rating: 4.3,
                        service: "Pembersihan AC",
                        estimate: "35 Menit",
                        price: "Rp 50.000,-",
                        imageUrl:
                            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                      ),
                      orderCard(
                        name: "Beno Arsudito",
                        rating: 4.5,
                        service: "Perbaikan TV",
                        estimate: "1 Jam",
                        price: "Rp 110.000,-",
                        imageUrl:
                            "https://images.unsplash.com/photo-1603415526960-f7e0328c63b1?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                      ),
                      orderCard(
                        name: "Hasan Ali",
                        rating: 4.2,
                        service: "Perbaikan atap rumah",
                        estimate: "35 Menit",
                        price: "Rp 189.000,-",
                        imageUrl:
                            "https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                      ),
                    ],
                  ),

                  // Completed Orders
                  Center(
                      child: Text("Belum ada pesanan selesai",
                          style: TextStyle(color: Colors.white, fontSize: 16))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
