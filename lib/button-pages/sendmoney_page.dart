import 'package:flutter/material.dart';
import 'package:ramimapp/button-pages/takasendpage.dart';

class SendMoneyPage extends StatelessWidget {
  const SendMoneyPage({Key? key}) : super(key: key);

  void navigateToSendPage(BuildContext context, String method) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakaSendPage(selectedMethod: method),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Money")),
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0, left: 80),
        child: Column(
          children: [
            Row(
              children: [
                buildGridButton("Bkash", 'images/bkash.jpg', () {
                  navigateToSendPage(context, "Bkash");
                }),
                const SizedBox(width: 60),
                buildGridButton("Nagad", 'images/nagad.jpg', () {
                  navigateToSendPage(context, "Nagad");
                }),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                buildGridButton("Rocket", 'images/rocket.png', () {
                  navigateToSendPage(context, "Rocket");
                }),
                const SizedBox(width: 60),
                buildGridButton("Upay", 'images/upay.png', () {
                  navigateToSendPage(context, "Upay");
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGridButton(String label, String imagePath, VoidCallback onTap) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.white,
            elevation: 4,
          ),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
