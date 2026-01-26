import 'package:flutter/material.dart';
import 'package:flutter_bakong_khqr/core/khqr_curency.dart';


class DonationDrawer extends StatefulWidget {
final Function(double, KhqrCurrency) onGenerate;


const DonationDrawer({super.key, required this.onGenerate});


@override
State<DonationDrawer> createState() => _DonationDrawerState();
}


class _DonationDrawerState extends State<DonationDrawer> {
final _amountCtrl = TextEditingController();
KhqrCurrency _currency = KhqrCurrency.usd;


@override
Widget build(BuildContext context) {
return Drawer(
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
const SizedBox(height: 40),
const Text("💖 Donate", style: TextStyle(fontSize: 22)),
const SizedBox(height: 20),
TextField(
controller: _amountCtrl,
keyboardType: TextInputType.number,
decoration: const InputDecoration(
labelText: "Amount (leave empty for open)",
border: OutlineInputBorder(),
),
),
const SizedBox(height: 16),
DropdownButtonFormField<KhqrCurrency>(
value: _currency,
items: const [
DropdownMenuItem(value: KhqrCurrency.usd, child: Text("USD")),
DropdownMenuItem(value: KhqrCurrency.khr, child: Text("KHR")),
],
onChanged: (v) => setState(() => _currency = v as KhqrCurrency),
decoration: const InputDecoration(border: OutlineInputBorder()),
),
const Spacer(),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () {
final amount = double.tryParse(_amountCtrl.text) ?? 0;
widget.onGenerate(amount, _currency);
Navigator.pop(context);
},
child: const Text("Generate QR"),
),
),
],
),
),
);
}
}