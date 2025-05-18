import 'package:flutter/material.dart';
import 'package:ramimapp/button-pages/takasendpage.dart';

class SendMoneyPage extends StatelessWidget {
  const SendMoneyPage({super.key});

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
      appBar: AppBar(title: const Text('Select Payment Method')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildGridButton("Bkash", 'images/bkash.jpg', () {
                      navigateToSendPage(context, "Bkash");
                    }),
                    const SizedBox(width: 40),
                    buildGridButton("Nagad", 'images/nagad.jpg', () {
                      navigateToSendPage(context, "Nagad");
                    }),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildGridButton("Rocket", 'images/rocket.png', () {
                      navigateToSendPage(context, "Rocket");
                    }),
                    const SizedBox(width: 40),
                    buildGridButton("Upay", 'images/upay.png', () {
                      navigateToSendPage(context, "Upay");
                    }),
                  ],
                ),
              ],
            ),
          ),
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
