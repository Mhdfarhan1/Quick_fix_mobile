import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/category_model.dart';
import '../../../models/service_model.dart';
import '../../../config/base_url.dart';
import 'car_category_screen.dart';
import 'electronics_category_screen.dart';
import 'motorcycle_category_screen.dart';
import '../pencarian/halaman_pencarian.dart';

class HousingCategoryScreen extends StatefulWidget {
  const HousingCategoryScreen({super.key});

  @override
  State<HousingCategoryScreen> createState() => _HousingCategoryScreenState();
}

class _HousingCategoryScreenState extends State<HousingCategoryScreen> {
  late Future<List<CategoryModel>> _categoriesFuture;
  late Future<List<ServiceModel>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
    // Search for "Renovasi" as confirmed by logs
    _servicesFuture = _fetchServicesForCategory("Renovasi");
  }

  Future<List<CategoryModel>> _fetchCategories() async {
    try {
      final response = await ApiService.fetchKategori();
      if (response['statusCode'] == 200) {
        final dynamic responseData = response['data'];
        
        if (responseData is List) {
          return responseData.map((json) => CategoryModel.fromJson(json)).toList();
        } else if (responseData is Map<String, dynamic>) {
           if (responseData.containsKey('data') && responseData['data'] is List) {
             return (responseData['data'] as List).map((json) => CategoryModel.fromJson(json)).toList();
           } else {
             print("API Response is a Map but doesn't contain 'data' list: $responseData");
             return [];
           }
        } else {
          print("Unexpected API response format: $responseData");
          return [];
        }
      } else {
        throw Exception('Failed to load categories: ${response['data']['message']}');
      }
    } catch (e) {
      print("Error fetching categories: $e");
      return []; 
    }
  }

  Future<List<ServiceModel>> _fetchServicesForCategory(String categoryName) async {
    try {
      final categories = await _fetchCategories();
      
      final category = categories.firstWhere(
        (c) => c.nama.toLowerCase().contains(categoryName.toLowerCase()),
        orElse: () => CategoryModel(id: -1, nama: 'Unknown'),
      );

      if (category.id == -1) {
        print("DEBUG: Category '$categoryName' NOT FOUND in list.");
        return [];
      }

      print("DEBUG: Found category '${category.nama}' with ID ${category.id}. Fetching services...");

      final response = await ApiService.fetchKeahlian(kategoriId: category.id);
      if (response['statusCode'] == 200) {
        final dynamic responseData = response['data'];
        List<ServiceModel> services = [];
        if (responseData is List) {
            services = responseData.map((json) => ServiceModel.fromJson(json)).toList();
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data') && responseData['data'] is List) {
            services = (responseData['data'] as List).map((json) => ServiceModel.fromJson(json)).toList();
        }
        
        return services;
      } else {
        throw Exception('Failed to load services: ${response['data']['message']}');
      }
    } catch (e) {
      print("Error fetching services: $e");
      return [];
    }
  }

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
            _buildServicesHeader("Layanan Renovasi"),
            _buildServices(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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

  Widget _buildMainCategories() {
    return FutureBuilder<List<CategoryModel>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Tidak ada kategori"));
        }

        final categories = snapshot.data!;

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
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryItem(categories[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(CategoryModel category) {
    IconData iconData = Icons.help_outline; // Default icon
    Color color = const Color(0xFF1976D2);
    
    final name = category.nama.toLowerCase();

    // Match icons with dashboard (home_page.dart)
    if (name.contains("mobil")) {
      iconData = Icons.directions_car;
      color = const Color(0xFF1976D2);
    } else if (name.contains("motor")) {
      iconData = Icons.motorcycle; // Updated from two_wheeler
      color = const Color(0xFF0C4481);
    } else if (name.contains("elektronik")) {
      iconData = Icons.electrical_services;
      color = const Color(0xFF1976D2);
    } else if (name.contains("renovasi") || name.contains("rumah")) {
      iconData = Icons.home_repair_service; // Updated from home
      color = const Color(0xFF0C4481);
    }

    return Material(
      borderRadius: BorderRadius.circular(8),
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          print("Kategori ${category.nama} dipilih");
          final n = category.nama.toLowerCase();
          
          if (n.contains("mobil")) {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CarCategoryScreen()));
          } else if (n.contains("motor")) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MotorcycleCategoryScreen()));
          } else if (n.contains("elektronik")) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ElectronicsCategoryScreen()));
          } else if (n.contains("renovasi") || n.contains("rumah")) {
            // Already here
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                iconData,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildServices() {
    return FutureBuilder<List<ServiceModel>>(
      future: _servicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Tidak ada layanan tersedia"),
          ));
        }

        final services = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildServiceCard(services[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          print("Layanan ${service.judul} dipilih");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HalamanPencarian(searchQuery: service.judul),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.judul,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF0C4481),
                ),
              ),
              if (service.deskripsi != null && service.deskripsi!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  service.deskripsi!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}