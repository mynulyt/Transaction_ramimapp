import 'package:flutter/material.dart';

class BalanceButtonRow extends StatefulWidget {
  @override
  _BalanceButtonRowState createState() => _BalanceButtonRowState();
}

class _BalanceButtonRowState extends State<BalanceButtonRow> {
  bool _showBalance = false;
  double _balance = 1234.56; // You can set your balance here.

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _showBalance = !_showBalance;
              });
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: Color.fromARGB(255, 169, 123, 167),
            ),
            child: Text(
              _showBalance ? "\$$_balance" : "Tap for\nBalance",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 110),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(value: false, onChanged: (_) {}),
                const Text("Advance"),
              ],
            ),
            Row(
              children: [
                Checkbox(value: false, onChanged: (_) {}),
                const SizedBox(width: 5),
                const Text("Due"),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
