import 'package:flutter/material.dart';

class BalanceToggleButton extends StatefulWidget {
  final double balance;
  const BalanceToggleButton({super.key, required this.balance});

  @override
  _BalanceToggleButtonState createState() => _BalanceToggleButtonState();
}

class _BalanceToggleButtonState extends State<BalanceToggleButton> {
  bool showBalance = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          showBalance = !showBalance;
        });
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
        backgroundColor: Colors.indigo,
      ),
      child: Text(
        showBalance
            ? "৳${widget.balance.toStringAsFixed(2)}"
            : "Tap to\nShow Balance",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
