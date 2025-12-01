import 'teknisi_service.dart';

class ApiTeknisi {
  final TeknisiService _svc = TeknisiService();

  // Ambil semua teknisi
  Future<List<dynamic>> getListTeknisi() async {
    return await _svc.getTeknisiList();
  }

  // Ambil detail teknisi berdasarkan ID
  Future<Map<String, dynamic>?> getTeknisiById(int id) async {
    return await _svc.getTeknisiById(id);
  }
}
