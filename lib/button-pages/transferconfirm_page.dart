import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransferConfirmPage extends StatefulWidget {
  const TransferConfirmPage({super.key});

  @override
  _TransferConfirmPageState createState() => _TransferConfirmPageState();
}

class _TransferConfirmPageState extends State<TransferConfirmPage> {
  final TextEditingController _acNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _operatorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _submitRechargeRequest() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userName = userDoc['name'] ?? 'Unknown';

    final acNumber = _acNumberController.text.trim();
    final amount = _amountController.text.trim();
    final operator = _operatorController.text.trim();
    final description = _descriptionController.text.trim();

    if (acNumber.isEmpty || amount.isEmpty || operator.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    await _firestore.collection('rechargeRequests').add({
      'userId': uid,
      'userName': userName,
      'acNumber': acNumber,
      'amount': amount,
      'operator': operator,
      'description': description,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfer request submitted')),
    );

    _acNumberController.clear();
    _amountController.clear();
    _operatorController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_acNumberController, 'AC Number'),
            const SizedBox(height: 10),
            _buildTextField(_amountController, 'Amount'),
            const SizedBox(height: 10),
            _buildTextField(_operatorController, 'Operator'),
            const SizedBox(height: 10),
            _buildTextField(_descriptionController, 'Description (optional)'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRechargeRequest,
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
