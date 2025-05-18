import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePin extends StatefulWidget {
  const ChangePin({super.key});

  @override
  State<ChangePin> createState() => _ChangePinState();
}

class _ChangePinState extends State<ChangePin> {
  final TextEditingController oldPinController = TextEditingController();
  final TextEditingController newPinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();

  bool isLoading = false;

  void _changePin() async {
    final String oldPin = oldPinController.text.trim();
    final String newPin = newPinController.text.trim();
    final String confirmPin = confirmPinController.text.trim();

    if (oldPin.isEmpty || newPin.isEmpty || confirmPin.isEmpty) {
      _showMessage("All fields are required");
      return;
    }

    if (newPin != confirmPin) {
      _showMessage("New PIN and Confirmation PIN do not match");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      String storedPin = userDoc.get('pin');

      if (oldPin != storedPin) {
        _showMessage("Old PIN does not match");
        setState(() {
          isLoading = false;
        });
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'pin': newPin});

      _showMessage("PIN updated successfully");
      oldPinController.clear();
      newPinController.clear();
      confirmPinController.clear();
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          "Change Pin",
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Column(
            children: [
              const SizedBox(height: 50),
              _buildPinField("Enter Old Pin", oldPinController),
              const SizedBox(height: 20),
              _buildPinField("Enter New Pin", newPinController),
              const SizedBox(height: 20),
              _buildPinField("Enter Confirmation Pin", confirmPinController),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isLoading ? null : _changePin,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    side: const BorderSide(color: Colors.indigo),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Change Pin",
                          style: TextStyle(color: Colors.indigo, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: Colors.grey.shade200,
        prefixIcon: const Icon(Icons.pin, color: Colors.indigo),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
