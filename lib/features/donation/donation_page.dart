import 'package:flutter/material.dart';
import 'package:flutter_bakong_khqr/view/bakong_khqr.dart';
import 'package:provider/provider.dart';
import 'donation_drawer.dart';
import 'donation_controller.dart';


class DonationPage extends StatefulWidget {
const DonationPage({super.key});


@override
State<DonationPage> createState() => _DonationPageState();
}


class _DonationPageState extends State<DonationPage> {
final controller = DonationController();


@override
Widget build(BuildContext context) {
return ChangeNotifierProvider.value(
value: controller,
child: Scaffold(
appBar: AppBar(title: const Text("Bakong Donation")),
drawer: DonationDrawer(
onGenerate: controller.generate,
),
body: Center(
child: Consumer<DonationController>(
builder: (context, controller, child) {
return controller.qrCode.isEmpty
? Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(controller.error ?? "Open drawer to donate"),
if (controller.error != null)
TextButton(
onPressed: controller.clearError,
child: const Text("Dismiss"),
)
],
)
: BakongKhqrView(
width: 260,
qr: controller.qrCode,
receiverName: "Sovan Donation",
amount: controller.amount,
currency: controller.currency,
);
},
),
),
),
);
}
}