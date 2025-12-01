import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';
import '../../../config/base_url.dart';

class AddServiceModal extends StatefulWidget {
  final Function(dynamic newService) onServiceAdded;

  const AddServiceModal({Key? key, required this.onServiceAdded}) : super(key: key);

  @override
  State<AddServiceModal> createState() => _AddServiceModalState();
}

class _AddServiceModalState extends State<AddServiceModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceMinCtrl = TextEditingController();
  final _priceMaxCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  bool _isSubmitting = false;
  
  // Dropdown state
  bool _isLoadingKategori = true;
  List<Map<String, dynamic>> _kategoriList = [];
  int? _selectedKategoriId;

  bool _isLoadingKeahlian = false;
  List<Map<String, dynamic>> _keahlianList = [];
  int? _selectedKeahlianId;

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  Future<void> _fetchKategori() async {
    print("DEBUG: _fetchKategori called");
    try {
      final resp = await ApiService.fetchKategori();
      print("DEBUG: _fetchKategori response: $resp");
      if (resp['statusCode'] == 200 && resp['data'] != null) {
        final List list = (resp['data']['data'] ?? resp['data']) as List? ?? [];
        print("DEBUG: Kategori list length: ${list.length}");
        if (mounted) {
          setState(() {
            _kategoriList = list.map((e) => {'id': e['id_kategori'], 'nama': e['nama_kategori']}).cast<Map<String, dynamic>>().toList();
            _isLoadingKategori = false;
          });
        }
      } else {
        print("DEBUG: Fetch kategori failed or empty data");
        if (mounted) setState(() => _isLoadingKategori = false);
      }
    } catch (e) {
      print("DEBUG: Error fetching kategori: $e");
      if (mounted) setState(() => _isLoadingKategori = false);
    }
  }

  Future<void> _fetchKeahlian(int kategoriId) async {
    setState(() {
      _isLoadingKeahlian = true;
      _keahlianList = [];
      _selectedKeahlianId = null;
    });
    
    try {
      final resp = await ApiService.fetchKeahlian(kategoriId: kategoriId);
      if (resp['statusCode'] == 200 && resp['data'] != null) {
        final List list = (resp['data']['data'] ?? resp['data']) as List? ?? [];
        if (mounted) {
          setState(() {
            _keahlianList = list.map((e) => {'id': e['id_keahlian'], 'nama': e['nama_keahlian']}).cast<Map<String, dynamic>>().toList();
            _isLoadingKeahlian = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingKeahlian = false);
      }
    } catch (e) {
      print("DEBUG: Error fetching keahlian: $e");
      if (mounted) setState(() => _isLoadingKeahlian = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (img != null) {
        setState(() => _pickedImage = img);
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal akses gallery: ${e.message}")));
    }
  }

  Future<void> _submit() async {
    print("DEBUG: Submit pressed");
    if (!_formKey.currentState!.validate()) {
      print("DEBUG: Validation failed");
      return;
    }
    
    final min = _priceMinCtrl.text.trim().isEmpty ? null : int.parse(_priceMinCtrl.text.trim());
    final max = _priceMaxCtrl.text.trim().isEmpty ? null : int.parse(_priceMaxCtrl.text.trim());
    
    if (min != null && max != null && min > max) {
      print("DEBUG: Price validation failed. Min: $min, Max: $max");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harga Min tidak boleh lebih besar dari Harga Max")));
      return;
    }

    if (_selectedKeahlianId == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih Keahlian terlebih dahulu")));
       return;
    }

    print("DEBUG: Starting submission...");
    setState(() => _isSubmitting = true);

    try {
      print("DEBUG: Calling API...");
      final resp = await ApiService.uploadKeahlianTeknisi(
        idKeahlian: _selectedKeahlianId,
        nama: _nameCtrl.text.trim(), // Optional if using ID, but good to send
        hargaMin: min,
        hargaMax: max,
        deskripsi: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        gambarFile: _pickedImage != null ? File(_pickedImage!.path) : null,
      );
      print("DEBUG: API Response: $resp");

      if (mounted) {
        setState(() => _isSubmitting = false);
        
        // Accept 200 or 201 as success
        if ((resp['statusCode'] == 200 || resp['statusCode'] == 201) || 
            (resp['data'] is Map && (resp['data']['success'] == true))) {
          print("DEBUG: Success condition met");
          final data = resp['data']['data'] ?? resp['data'];
          
          try {
            widget.onServiceAdded(data);
          } catch (e) {
            print("DEBUG: Error in onServiceAdded callback: $e");
          }
          
          print("DEBUG: Closing modal");
          if (mounted) Navigator.of(context).pop(); 
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Layanan berhasil ditambahkan")));
        } else {
          print("DEBUG: Failed. Status: ${resp['statusCode']}");
          final msg = (resp['data'] is Map) ? (resp['data']['message'] ?? resp['data'].toString()) : 'Gagal menambahkan layanan';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $msg')));
        }
      }
    } catch (e) {
      print("DEBUG: Exception caught: $e");
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            const Text("Tambah Layanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Kategori Dropdown
            _isLoadingKategori
                ? const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LinearProgressIndicator())
                : DropdownButtonFormField<int>(
                    value: _selectedKategoriId,
                    decoration: const InputDecoration(labelText: "Pilih Kategori"),
                    items: _kategoriList.map((k) => DropdownMenuItem<int>(value: k['id'] as int, child: Text(k['nama'].toString()))).toList(),
                    onChanged: (v) {
                      setState(() => _selectedKategoriId = v);
                      if (v != null) _fetchKeahlian(v);
                    },
                    validator: (v) => v == null ? "Pilih kategori" : null,
                  ),
            const SizedBox(height: 8),

            // Keahlian Dropdown
            _isLoadingKeahlian
                ? const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LinearProgressIndicator())
                : DropdownButtonFormField<int>(
                    value: _selectedKeahlianId,
                    decoration: const InputDecoration(labelText: "Pilih Keahlian"),
                    items: _keahlianList.map((k) => DropdownMenuItem<int>(value: k['id'] as int, child: Text(k['nama'].toString()))).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedKeahlianId = v;
                        // Auto-fill name if selected
                        if (v != null) {
                          final k = _keahlianList.firstWhere((e) => e['id'] == v, orElse: () => {});
                          if (k.isNotEmpty) _nameCtrl.text = k['nama'];
                        }
                      });
                    },
                    validator: (v) => v == null ? "Pilih keahlian" : null,
                  ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _nameCtrl, 
              decoration: const InputDecoration(labelText: "Nama Layanan"), 
              validator: (v) => (v == null || v.trim().isEmpty) ? "Nama wajib diisi" : null
            ),
            const SizedBox(height: 8),
            
            TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: "Deskripsi"), maxLines: 2),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextFormField(controller: _priceMinCtrl, decoration: const InputDecoration(labelText: "Harga Min"), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly],)),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _priceMaxCtrl, decoration: const InputDecoration(labelText: "Harga Max"), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly],)),
            ]),
            const SizedBox(height: 12),
            
            Align(alignment: Alignment.centerLeft, child: Text("Gambar Layanan", style: TextStyle(fontSize: 13, color: Colors.grey[800]))),
            const SizedBox(height: 6),
            Row(children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text("Pilih Gambar"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C4481), foregroundColor: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(_pickedImage?.name ?? "Belum ada gambar terpilih", overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 12),
            if (_pickedImage != null) ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_pickedImage!.path), height: 120, width: double.infinity, fit: BoxFit.cover)),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () {
                  try {
                    _submit();
                  } catch (e) {
                    print("DEBUG: Error triggering submit: $e");
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C4481), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                child: _isSubmitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Simpan"),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
