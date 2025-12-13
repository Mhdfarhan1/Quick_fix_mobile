import '../services/api_service.dart'; // Pastikan path import ini sesuai dengan lokasi api_service.dart Anda

class TeknisiStatusService {

  // Fungsi untuk mengecek status verifikasi teknisi
  Future<Map<String, dynamic>> checkStatus() async {
    try {
      final response = await ApiService.request(
        method: 'GET',
        endpoint: '/teknisi/verifikasi/status',
      );

      return response;
    } catch (e) {
      // Jika error, kita kembalikan map kosong atau throw error agar bisa ditangani di UI
      print("Error di TeknisiStatusService: $e");
      return {'statusCode': 500, 'message': e.toString()};
    }
  }
}