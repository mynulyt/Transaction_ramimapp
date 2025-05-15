import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransferConfirmPage extends StatefulWidget {
  const TransferConfirmPage({super.key});

  @override
  _TransferConfirmPageState createState() => _TransferConfirmPageState();
}

class _TransferConfirmPageState extends State<TransferConfirmPage> {
  final TextEditingController _receiverIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedMethod;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _selectedMethod = args;
    }
  }

  Future<void> _submitTransfer() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final senderUid = user.uid;
    final receiverId = _receiverIdController.text.trim();
    final amountStr = _amountController.text.trim();
    final description = _descriptionController.text.trim();

    if (receiverId.isEmpty || amountStr.isEmpty || _selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    try {
      // Check if receiver exists (optional, assuming receiverId is uid or phone)
      final receiverDoc =
          await _firestore.collection('users').doc(receiverId).get();
      if (!receiverDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receiver not found')),
        );
        return;
      }

      // Add transfer request to Firestore
      await _firestore.collection('transfers').add({
        'senderId': senderUid,
        'receiverId': receiverId,
        'method': _selectedMethod,
        'amount': amount,
        'description': description,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer request submitted')),
      );

      _receiverIdController.clear();
      _amountController.clear();
      _descriptionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Confirmation'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedMethod != null)
              Text(
                'Method: $_selectedMethod',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            _buildTextField(_receiverIdController, 'Receiver User ID'),
            const SizedBox(height: 10),
            _buildTextField(_amountController, 'Amount'),
            const SizedBox(height: 10),
            _buildTextField(_descriptionController, 'Description (optional)'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Submit Request',
                style: TextStyle(fontSize: 16),
              ),
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
