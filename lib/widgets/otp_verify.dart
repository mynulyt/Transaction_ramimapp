import 'package:flutter/material.dart';
import 'package:ramimapp/Database/Auth_services/auth_services.dart';
import 'package:ramimapp/main.dart';

class OtpVerifyPage extends StatelessWidget {
  final String verificationId;
  final TextEditingController otpController = TextEditingController();

  OtpVerifyPage({super.key, required this.verificationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter OTP"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await AuthService()
                      .signInWithOtp(verificationId, otpController.text);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid OTP")),
                  );
                }
              },
              child: const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
