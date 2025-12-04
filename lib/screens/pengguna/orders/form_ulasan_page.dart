import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormUlasanPage extends StatefulWidget {
  final int idPemesanan;

  FormUlasanPage({required this.idPemesanan});

  @override
  _FormUlasanPageState createState() => _FormUlasanPageState();
}

class _FormUlasanPageState extends State<FormUlasanPage> {
  double rating = 5.0;
  TextEditingController komentarC = TextEditingController();
  bool loading = false;

  Future<void> submitUlasan() async {
    setState(() => loading = true);

    final response = await http.post(
      Uri.parse("https://api-kamu.com/ulasan"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_pemesanan": widget.idPemesanan,
        "rating": rating,
        "komentar": komentarC.text.isEmpty ? null : komentarC.text
      }),
    );

    setState(() => loading = false);

    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ulasan berhasil dikirim")),
      );
      Navigator.pop(context, true); // kembali dengan status sukses
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Beri Ulasan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rating Teknisi", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),

            RatingBar(
              initialRating: 5.0,
              minRating: 0.5,
              allowHalfRating: true,
              itemSize: 40,
              ratingWidget: RatingWidget(
                full: Icon(Icons.star, color: Colors.amber),
                half: Icon(Icons.star_half, color: Colors.amber),
                empty: Icon(Icons.star_border, color: Colors.grey),
              ),
              onRatingUpdate: (value) {
                setState(() => rating = value);
              },
            ),

            SizedBox(height: 20),
            Text("Komentar (opsional)"),
            TextField(
              controller: komentarC,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tulis komentar...",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submitUlasan,
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Kirim"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
