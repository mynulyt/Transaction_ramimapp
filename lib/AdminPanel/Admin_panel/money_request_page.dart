import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ramimapp/button-pages/sales_services.dart';

class MoneyRequestPage extends StatefulWidget {
  const MoneyRequestPage({super.key});

  @override
  State<MoneyRequestPage> createState() => _MoneyRequestPageState();
}

class _MoneyRequestPageState extends State<MoneyRequestPage> {
  Future<void> _showPinAndNumberDialog(
      BuildContext context, String docId, Map<String, dynamic> data) async {
    final pinController = TextEditingController();
    final numberController = TextEditingController(text: data['number'] ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter PIN and Number'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: pinController,
                  decoration: const InputDecoration(
                    labelText: 'PIN',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter PIN';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: numberController,
                  decoration: const InputDecoration(
                    labelText: 'Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final pin = pinController.text.trim();
                  final number = numberController.text.trim();

                  // Store PIN and Number in Firestore
                  await FirebaseFirestore.instance
                      .collection('pinNumberRecords')
                      .add({
                    'uid': data['uid'],
                    'name': data['name'] ?? 'Unknown',
                    'email': data['email'] ?? '',
                    'pin': pin,
                    'number': number,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  Navigator.of(context).pop(); // close dialog

                  // Proceed with acceptance logic
                  await _finalizeAccept(context, docId, data);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAccept(
      BuildContext context, String docId, Map<String, dynamic> data) async {
    // Show PIN + Number input dialog first
    await _showPinAndNumberDialog(context, docId, data);
  }

  Future<void> _finalizeAccept(
      BuildContext context, String docId, Map<String, dynamic> data) async {
    try {
      final uid = data['uid'];
      final requestedAmount =
          double.tryParse(data['amount']?.toString() ?? '0') ?? 0.0;
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final currentBalance =
            double.tryParse(userData['main']?.toString() ?? '0') ?? 0.0;

        if (currentBalance >= requestedAmount) {
          final newBalance = currentBalance - requestedAmount;

          // Update user balance
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .update({'main': newBalance.toStringAsFixed(2)});

          // Add to Transaction History
          await FirebaseFirestore.instance
              .collection('TransactionHistory')
              .add({
            'uid': uid,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'amount': requestedAmount,
            'method': data['method'] ?? '',
            'number': data['number'] ?? '',
            'description': data['description'] ?? '',
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'Money Request Accepted',
          });

          // Record in Total Sales
          await SalesService.recordSale(
            collectionName: 'moneyRequests',
            docId: docId,
            type: 'money_request',
            requestData: data,
            amount: requestedAmount,
            userId: uid,
            userName: data['name'] ?? 'Unknown',
            userEmail: data['email'] ?? '',
            userPhone: data['number'] ?? '',
          );

          // Create entry in Total Cash collection
          await FirebaseFirestore.instance.collection('Total Cash').add({
            'uid': uid,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'amount': requestedAmount,
            'method': data['method'] ?? '',
            'number': data['number'] ?? '',
            'description': data['description'] ?? '',
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'Money Request',
            'status': 'Completed',
          });

          // Delete the request
          await FirebaseFirestore.instance
              .collection('moneyRequests')
              .doc(docId)
              .delete();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Request accepted and recorded in Total Cash')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Insufficient balance in user account.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found.')),
        );
      }
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
        title: const Text(
          'Money Request Page',
        ),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('moneyRequests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No money requests found.'));
          }
          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name at top
                      Text(
                        data['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),

                      // Info rows with icons
                      Row(
                        children: [
                          const Icon(Icons.attach_money,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'Amount: ${data['amount'] ?? ''}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.payment,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'Method: ${data['method'] ?? ''}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          SelectableText.rich(
                            TextSpan(
                              text: 'Number: ',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                              children: [
                                TextSpan(
                                  text: '${data['number'] ?? ''}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.description,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Description: ${data['description'] ?? ''}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),

                      // Buttons below, centered horizontally
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () =>
                                _handleAccept(context, doc.id, data),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              child: Text(
                                'Accept',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('moneyRequests')
                                  .doc(doc.id)
                                  .delete();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
