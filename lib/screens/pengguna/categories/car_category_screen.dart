import 'package:flutter/material.dart';

class CarCategoryScreen extends StatelessWidget {
  const CarCategoryScreen({super.key});

  // Data untuk kategori utama - SAMA DENGAN SEBELUMNYA
  final List<Map<String, dynamic>> mainCategories = const [
    {
      "nama": "Elektronik",
      "icon": Icons.electrical_services,
      "color": Color(0xFF1976D2),
    },
    {
      "nama": "Perumahan", 
      "icon": Icons.home,
      "color": Color(0xFF0C4481),
    },
    {
      "nama": "Otomotif Mobil",
      "icon": Icons.directions_car,
      "color": Color(0xFF1976D2),
    },
    {
      "nama": "Otomotif Motor",
      "icon": Icons.two_wheeler,
      "color": Color(0xFF0C4481),
    },
  ];

  // Data untuk layanan mobil
  final List<Map<String, dynamic>> carServices = const [
    {
      "judul": "Ganti Oli & Filter",
      "gambar": "https://images.unsplash.com/photo-1563720223185-11003d516935?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3",
    },
    {
      "judul": "Service Rem",
      "gambar": "https://images.unsplash.com/photo-1626887347884-31637b352046?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3",
    },
    {
      "judul": "Perbaikan Mesin", 
      "gambar": "https://images.unsplash.com/photo-1603712610496-5362a2c93c90?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3",
    },
    {
      "judul": "Service AC Mobil",
      "gambar": "https://images.unsplash.com/photo-1621342339186-2e90e6cc42fc?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3",
    },
    {
      "judul": "Ganti Ban",
      "gambar": "https://images.unsplash.com/photo-1603712610496-5362a2c93c90?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3",
    },
    {
      "judul": "Tune Up",
      "gambar": "https://images.unsplash.com/photo-1563720223185-11003d516935?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3",
    },
    {
      "judul": "Perbaikan Transmisi",
      "gambar": "https://images.unsplash.com/photo-1626887347884-31637b352046?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3",
    },
    {
      "judul": "Service Kelistrikan",
      "gambar": "https://images.unsplash.com/photo-1603712610496-5362a2c93c90?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Kategori",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0C4481),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(),
            _buildMainCategories(),
            _buildServicesHeader("Layanan Mobil"),
            _buildCarServices(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ------------------- HEADER KATEGORI -------------------
  Widget _buildCategoryHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Text(
        "Pilih Kategori",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0C4481),
        ),
      ),
    );
  }

  // ------------------- KATEGORI UTAMA -------------------
  Widget _buildMainCategories() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3.5,
        ),
        itemCount: mainCategories.length,
        itemBuilder: (context, index) {
          return _buildCategoryItem(mainCategories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: category["color"],
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          print("Kategori ${category['nama']} dipilih");
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                category["icon"],
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category["nama"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------- HEADER LAYANAN -------------------
  Widget _buildServicesHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0C4481),
        ),
      ),
    );
  }

  // ------------------- LAYANAN MOBIL -------------------
  Widget _buildCarServices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: carServices.length,
        itemBuilder: (context, index) {
          return _buildServiceCard(carServices[index]);
        },
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          print("Layanan ${service['judul']} dipilih");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // GAMBAR LAYANAN
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  service["gambar"],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C4481)),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            // JUDUL LAYANAN
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    service["judul"],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF0C4481),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}