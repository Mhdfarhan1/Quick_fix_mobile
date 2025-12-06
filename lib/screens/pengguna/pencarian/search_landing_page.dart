import 'package:flutter/material.dart';
import 'halaman_pencarian.dart'; // pastikan path benar

class SearchLandingPage extends StatefulWidget {
  final String initialQuery;

  const SearchLandingPage({super.key, this.initialQuery = ""});

  @override
  State<SearchLandingPage> createState() => _SearchLandingPageState();
}

class _SearchLandingPageState extends State<SearchLandingPage> {
  late final TextEditingController _searchController;

  // List untuk menyimpan riwayat pencarian
  final List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0C4481),
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 14, left: 4),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Row(
            children: const [
              SizedBox(width: 2),
              Text(
                "Pencarian",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      children: [
        // 🔍 Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (query) {
              if (query.trim().isNotEmpty) {
                setState(() {
                  // tambahkan ke history (hindari duplikat)
                  _searchHistory.remove(query);
                  _searchHistory.insert(0, query);
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HalamanPencarian(searchQuery: query),
                  ),
                );
              }
            },
            decoration: InputDecoration(
              hintText: 'mau perbaiki apa hari ini?',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),

        // 🕑 History
        _buildSearchHistory(),

        const Divider(height: 1, thickness: 8, color: Color(0xFFF0F0F0)),

        // 👀 Recently Viewed
        _buildRecentlyViewed(),
      ],
    );
  }

  Widget _buildSearchHistory() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Riwayat Pencaharian",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // ✅ tampilkan empty state jika kosong
          if (_searchHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: const [
                  Icon(Icons.history, color: Colors.grey, size: 20),
                  SizedBox(width: 12),
                  Text(
                    "Belum ada riwayat pencarian",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            for (var query in _searchHistory) _buildHistoryItem(query),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String query) {
    return InkWell(
      onTap: () {
        // klik history -> jalankan pencarian lagi
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanPencarian(searchQuery: query),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.history, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Text(query, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyViewed() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Riwayat Pencaharian Teknisi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTechnicianCard(
                  "Ahli Perbaikan",
                  "Kendaraan Mobil, Motor, dll",
                  "https://images.unsplash.com/photo-1558611848-73f7eb4001a1?q=80&w=2071&auto-format&fit=crop&ixlib=rb-4.0.3",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(String name, String specialty, String imageUrl) {
    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text("4.9",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          SizedBox(width: 6),
                          Text("Highly Rated",
                              style:
                              TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(specialty,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text("BOOK"),
                        ),
                      ),
                    ],
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
