import 'package:flutter/material.dart';
import '../models/payout.dart';
import '../services/api_payout.dart';

class PayoutProvider with ChangeNotifier {
  List<Payout> _payouts = [];
  bool _isLoading = false;

  List<Payout> get payouts => _payouts;
  bool get isLoading => _isLoading;

  /// 🔄 Mengambil daftar payout teknisi
  Future<void> fetchPayouts(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiPayoutService.getPayoutByTeknisi(token);
      _payouts = data;
    } catch (e) {
      debugPrint("Error Fetch Payouts: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 💸 Mengajukan permintaan pencairan
  Future<bool> requestPayout({
    required String token,
    required int totalDibayar,
  }) async {
    try {
      bool result = await ApiPayoutService.requestPayout(
        token: token,
        totalDibayar: totalDibayar,
      );
      if (result) {
        await fetchPayouts(token); // Refresh data setelah request
      }
      return result;
    } catch (e) {
      debugPrint("Error Request Payout: $e");
      return false;
    }
  }
}
