import 'package:cineverse/core/bakong/bakong_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bakong_khqr/core/khqr_curency.dart';



class DonationController extends ChangeNotifier {
final BakongService _service = BakongService();


String qrCode = "";
double amount = 0;
KhqrCurrency currency = KhqrCurrency.usd;
String? error;


Future<void> generate(double newAmount, KhqrCurrency newCurrency) async {
try {
amount = newAmount;
currency = newCurrency;
error = null;
qrCode = await _service.generateDonationQR(
amount: amount,
currency: currency,
);
if (qrCode.isEmpty) {
error = "Failed to generate QR code";
}
notifyListeners();
} catch (e) {
error = "Error: $e";
qrCode = "";
notifyListeners();
}
}

void clearError() {
error = null;
notifyListeners();
}
}