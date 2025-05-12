import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TakaSendPage extends StatefulWidget {
  final String selectedMethod;

  const TakaSendPage({super.key, required this.selectedMethod});

  @override
  _TakaSendPageState createState() => _TakaSendPageState();
}

class _TakaSendPageState extends State<TakaSendPage> {
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
              Icon(Icons.lock, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text("Enter PIN"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Please enter your secure PIN to confirm this request.",
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
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text("Submit"),
              onPressed: () async {
                await _verifyPinAndSendRequest();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyPinAndSendRequest() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();

    if (!userDoc.exists || !userDoc.data()!.containsKey('pin')) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN not set. Please register properly.')),
      );
      return;
    }

    final correctPin = userDoc['pin'];
    final enteredPin = pinController.text;

    if (enteredPin == correctPin) {
      await _sendRequestToAdmin();
      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent to admin successfully!')),
      );
    } else {
      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN. Try again.')),
      );
    }

    pinController.clear();
  }

  Future<void> _sendRequestToAdmin() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown';

    final request = {
      'method': widget.selectedMethod,
      'number': numberController.text.trim(),
      'amount': double.tryParse(amountController.text) ?? 0,
      'description': descriptionController.text.trim(),
      'uid': currentUser.uid,
      'email': currentUser.email,
      'name': userName, // ✅ add user's name here
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    };

    await _firestore.collection('moneyRequests').add(request);

    numberController.clear();
    amountController.clear();
    descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send via ${widget.selectedMethod}"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0, left: 16.0, right: 16.0),
        child: Column(
          children: [
            TextField(
              controller: numberController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "${widget.selectedMethod} Number",
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showPinDialog,
              child: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}
