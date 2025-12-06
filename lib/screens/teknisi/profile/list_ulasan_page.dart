import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/review_model.dart';

class ListUlasanPage extends StatefulWidget {
  final List<TechnicianReview> reviews;
  final bool isLoading;

  const ListUlasanPage({
    super.key,
    required this.reviews,
    this.isLoading = false, // selalu false dari parent
  });

  @override
  State<ListUlasanPage> createState() => _ListUlasanPageState();
}


class _ListUlasanPageState extends State<ListUlasanPage> {
  int selectedStar = 0;

  @override
  Widget build(BuildContext context) {
    print("📄 [PAGE] ListUlasanPage dibuka. Total: ${widget.reviews.length}");

    List<TechnicianReview> filtered = selectedStar == 0
        ? widget.reviews
        : widget.reviews.where((r) => r.rating == selectedStar).toList();

    return Scaffold(

      body: Column(
        children: [
          // 🔵 CUSTOM HEADER
          Container(
            height: 100,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF0C4481),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),

                const Text(
                  "Semua Ulasan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 24), 
              ],
            ),
          ),

          // ⭐ FILTER
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Tombol Semua
                  GestureDetector(
                    onTap: () {
                      setState(() => selectedStar = 0);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selectedStar == 0 ? Colors.amber : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: selectedStar == 0
                            ? [
                                const BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      child: const Text(
                        "Semua",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // Tombol rating 1–5
                  ...List.generate(5, (i) {
                    int star = i + 1;
                    bool active = selectedStar == star;

                    return GestureDetector(
                      onTap: () => setState(() => selectedStar = star),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? Colors.amber : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: active
                              ? [
                                  const BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Text(
                              "$star",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.star, size: 18, color: Colors.black),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ⭐ LIST ULASAN (scroll)
          Expanded(
            child: widget.isLoading
                ? _buildShimmerList()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final r = filtered[i];

                      String createdDate = "-";
                      try {
                        if (r.createdAt != null) {
                          createdDate =
                              DateFormat("dd MMM yyyy").format(r.createdAt!);
                        }
                      } catch (_) {}

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.namaPelanggan,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),

                            Row(
                              children: List.generate(
                                5,
                                (x) => Icon(
                                  Icons.star,
                                  size: 18,
                                  color: x < r.rating ? Colors.amber : Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              r.komentar,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              createdDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      )
    );
  }

  // ---------------------------------------------------
  // ⭐ SHIMMER LIST
  // ---------------------------------------------------
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, i) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 120, color: Colors.white),
                const SizedBox(height: 10),

                Row(
                  children: List.generate(
                    5,
                    (_) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      height: 14,
                      width: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Container(height: 12, width: double.infinity, color: Colors.white),
                const SizedBox(height: 6),
                Container(height: 12, width: 200, color: Colors.white),
                const SizedBox(height: 10),

                Container(height: 10, width: 80, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
