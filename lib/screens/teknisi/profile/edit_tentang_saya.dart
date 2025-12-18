import 'package:flutter/material.dart';

class EditTentangSayaPage extends StatefulWidget {
  final String currentText;

  const EditTentangSayaPage({
    super.key,
    required this.currentText,
  });

  @override
  State<EditTentangSayaPage> createState() => _EditTentangSayaPageState();
}

class _EditTentangSayaPageState extends State<EditTentangSayaPage> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.currentText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Tentang Saya")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,      // WAJIB ADA
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Tulis tentang saya...",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text); // WAJIB
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
