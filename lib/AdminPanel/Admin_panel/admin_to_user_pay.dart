import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminToUserTransferConfirmPage extends StatefulWidget {
  final String? receiverName;
  final String? receiverPhone;

  const AdminToUserTransferConfirmPage({
    super.key,
    this.receiverName,
    this.receiverPhone,
  });

  @override
  _AdminToUserTransferConfirmPageState createState() =>
      _AdminToUserTransferConfirmPageState();
}

class _AdminToUserTransferConfirmPageState
    extends State<AdminToUserTransferConfirmPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _adminUid = 'mynulalam'; // <-- Change to your admin UID
  String? _receiverUid;

  @override
  void initState() {
    super.initState();
    if (widget.receiverPhone != null) {
      _phoneController.text = widget.receiverPhone!;
      _fetchUserByPhone(widget.receiverPhone!);
    }
    if (widget.receiverName != null) {
      _usernameController.text = widget.receiverName!;
    }
  }

  Future<void> _fetchUserByPhone(String phone) async {
    final snapshot = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs.first.data();
      setState(() {
        _usernameController.text = userData['name'] ?? '';
        _receiverUid = snapshot.docs.first.id;
      });
    } else {
      setState(() {
        _usernameController.clear();
        _receiverUid = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User not found")));
    }
  }

  Widget _buildField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text,
      bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  void _showPinDialog() {
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter your PIN"),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'PIN',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitTransfer(pinController.text.trim());
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTransfer(String enteredPin) async {
    if (_receiverUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receiver not found')),
      );
      return;
    }

    final amountStr = _amountController.text.trim();
    final description = _descriptionController.text.trim();

    if (amountStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount')),
      );
      return;
    }

    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    try {
      // Get admin data using fixed UID
      final senderDocRef = _firestore.collection('users').doc(_adminUid);
      final senderSnapshot = await senderDocRef.get();

      if (!senderSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin not found')),
        );
        return;
      }

      final senderData = senderSnapshot.data();
      final storedPin = senderData?['pin'];

      if (storedPin == null || storedPin != enteredPin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect PIN')),
        );
        return;
      }

      // Receiver data
      final receiverDocRef = _firestore.collection('users').doc(_receiverUid);
      final receiverSnapshot = await receiverDocRef.get();
      final receiverData = receiverSnapshot.data();

      if (receiverData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receiver not found')),
        );
        return;
      }

      final receiverMain =
          double.tryParse(receiverData['main'].toString()) ?? 0;

      // Admin unlimited balance – skip checking and deduction

      // Run Firestore Transaction
      await _firestore.runTransaction((transaction) async {
        transaction.update(receiverDocRef, {
          'main': (receiverMain + amount).toStringAsFixed(2),
        });

        final transferRef = _firestore.collection('transfers').doc();
        transaction.set(transferRef, {
          'senderId': _adminUid,
          'receiverId': _receiverUid,
          'amount': amount,
          'description': description,
          'status': 'completed',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer successful')),
      );

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
        title: const Text("Confirm Transfer"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildField(_phoneController, "Receiver Phone",
                keyboardType: TextInputType.phone, readOnly: true),
            const SizedBox(height: 12),
            _buildField(_usernameController, "Username", readOnly: true),
            const SizedBox(height: 12),
            _buildField(_amountController, "Amount",
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildField(_descriptionController, "Description (optional)"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_receiverUid != null) {
                  _showPinDialog();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Valid receiver not selected')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Submit Transfer",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
