import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MoneyRechargePage extends StatefulWidget {
  final String operatorName;

  const MoneyRechargePage({super.key, required this.operatorName});

  @override
  _MoneyRechargePageState createState() => _MoneyRechargePageState();
}

class _MoneyRechargePageState extends State<MoneyRechargePage> {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showPinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text("Enter PIN"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Please enter your PIN to confirm recharge request.",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: "6-digit PIN",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
                pinController.clear();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await _verifyPinAndSendRecharge();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyPinAndSendRecharge() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();

    if (!userDoc.exists || !userDoc.data()!.containsKey('pin')) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('PIN not found. Please register properly.')),
      );
      return;
    }

    final correctPin = userDoc['pin'];
    final enteredPin = pinController.text;

    if (enteredPin == correctPin) {
      await _sendRechargeRequestToAdmin();
      Navigator.of(context).pop(); // Close popup
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recharge request sent successfully!')),
      );
    } else {
      Navigator.of(context).pop(); // Close popup
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN.')),
      );
    }

    pinController.clear();
  }

  Future<void> _sendRechargeRequestToAdmin() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    final userData = userDoc.data();
    final fullName =
        userData?['name'] ?? 'Unknown'; // Assumes 'name' field exists
    final aiFile = userData?['aiFile'] ?? 'Not uploaded'; // Optional field

    final rechargeRequest = {
      'operator': widget.operatorName,
      'number': numberController.text.trim(),
      'amount': double.tryParse(amountController.text) ?? 0,
      'description': descriptionController.text.trim(),
      'uid': currentUser.uid,
      'email': currentUser.email,
      'userName': fullName,
      'aiFile': aiFile,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    };

    await _firestore.collection('rechargeRequests').add(rechargeRequest);

    numberController.clear();
    amountController.clear();
    descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.operatorName} Recharge"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 70.0, left: 16.0, right: 16.0),
        child: Column(
          children: [
            TextField(
              controller: numberController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Enter your ${widget.operatorName} number",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Amount",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              textAlign: TextAlign.center,
              maxLines: 6,
              minLines: 4,
              decoration: const InputDecoration(
                hintText: "Description",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showPinDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
