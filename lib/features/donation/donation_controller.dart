import 'package:flutter/material.dart';
import 'package:flutter_bakong_payway/flutter_bakong_payway.dart';
import 'dart:async';

class DonationViewModel extends ChangeNotifier {
  final FlutterBakongPayway _bakong = FlutterBakongPayway();

  /// State
  String? qrData;
  String? md5;
  DateTime? qrGeneratedAt;
  Timer? _qrTimer;
  int? _qrRemainingSeconds;
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

  int? get qrRemainingSeconds => _qrRemainingSeconds;

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

  void clearError() {
    error = null;
    notifyListeners();
  }

  void _clearQr() {
    _qrTimer?.cancel();
    _qrTimer = null;
    qrData = null;
    md5 = null;
    qrGeneratedAt = null;
    _qrRemainingSeconds = null;
    notifyListeners();
  }

  Future<void> generateQR() async {
    final amount = double.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      error = 'Please enter a valid amount';
      notifyListeners();
      return;
    }

    _qrTimer?.cancel();
    _qrTimer = null;
    loading = true;
    error = null;
    qrData = null;
    md5 = null;
    qrGeneratedAt = null;
    _qrRemainingSeconds = null;
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
      if (qrData != null) {
        qrGeneratedAt = DateTime.now();
        _qrRemainingSeconds = 30;
        _qrTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _qrRemainingSeconds = (_qrRemainingSeconds! - 1);
          if (_qrRemainingSeconds! <= 0) {
            _clearQr();
          } else {
            notifyListeners();
          }
        });
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    amountController.dispose();
    super.dispose();
  }
}
