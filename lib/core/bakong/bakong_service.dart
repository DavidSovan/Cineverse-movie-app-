import 'package:flutter/foundation.dart';
import 'package:flutter_bakong_khqr/flutter_bakong_khqr.dart';
import 'package:flutter_bakong_khqr/core/khqr_curency.dart';


class BakongService {
final FlutterBakongKhqr _bakong = FlutterBakongKhqr();


Future<String> generateDonationQR({
required double amount,
required KhqrCurrency currency,
}) async {
try {
final response = await _bakong.generateKhqrIndividual(
bakongAccountId: "sovan_david@bkrt", 
acquiringBank: "ABA Bank",
merchantName: "Sovan Donation",
currency: currency,
amount: amount == 0 ? 0 : amount,
);
debugPrint("✅ Bakong API Success");
debugPrint("response.qrCode: ${response.qrCode}");
debugPrint("QR length: ${response.qrCode.length}");
if (response.qrCode.isEmpty) {
throw Exception("QR code generation failed: empty response");
}
return response.qrCode;
} catch (e) {
debugPrint("❌ Bakong QR Error: $e");
throw Exception("Failed to generate QR: $e");
}
}
}