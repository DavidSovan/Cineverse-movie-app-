import 'package:flutter/material.dart';
import 'package:flutter_bakong_payway/flutter_bakong_payway.dart';

class DonationViewModel extends ChangeNotifier {
  final FlutterBakongPayway _bakong = FlutterBakongPayway();

  /// State
  String? qrData;
  String? md5;
  String? error;
  bool loading = false;

  KHQRCurrency currency = KHQRCurrency.usd;
  String platform = 'Unknown';

  /// Controllers
  final TextEditingController amountController =
      TextEditingController(text: '1');

  DonationViewModel() {
    loadPlatform();
  }

  Future<void> loadPlatform() async {
    try {
      platform = await _bakong.getPlatformVersion() ?? 'Unknown';
    } catch (_) {
      platform = 'Error';
    }
    notifyListeners();
  }

  void setCurrency(KHQRCurrency value) {
    currency = value;
    notifyListeners();
  }

  Future<void> generateQR() async {
    final amount = double.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      error = 'Please enter a valid amount';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    qrData = null;
    md5 = null;
    notifyListeners();

    try {
      final double finalAmount =
          currency == KHQRCurrency.khr ? amount.roundToDouble() : amount;

      final result = await _bakong.generateIndividualQR(
        IndividualInfo(
          accountId: 'sovan_david@bkrt',
          merchantName: 'David',
          acquiringBank: 'ABA Bank',
          currency: currency,
          amount: finalAmount,
          accountInformation: 'Donation',
        ),
      );

      qrData = result?.qr;
      md5 = result?.md5;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
