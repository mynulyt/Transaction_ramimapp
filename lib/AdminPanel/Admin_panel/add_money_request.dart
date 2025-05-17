import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMoneyRequestPage extends StatelessWidget {
  const AddMoneyRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Money Requests'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .doc('add_money_requests')
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No add money requests found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              final priceStr = data['price']?.toString() ?? '0';
              final name = data['userName'] ?? 'N/A';
              final email = data['userEmail'] ?? '';
              final uid = data['uid']?.toString();

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Money Request',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Amount', '$priceStr ৳'),
                        _buildInfoRow('Name', name),
                        _buildInfoRow('Email', email),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                'Accept',
                                Colors.green[100]!,
                                () async {
                                  try {
                                    final addAmount =
                                        double.tryParse(priceStr) ?? 0.0;

                                    if (uid == null || uid.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'User ID not found for this request.')));
                                      return;
                                    }

                                    DocumentReference userRef =
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(uid);

                                    DocumentSnapshot userDoc =
                                        await userRef.get();

                                    if (!userDoc.exists) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('User not found.')));
                                      return;
                                    }

                                    final userData =
                                        userDoc.data() as Map<String, dynamic>;
                                    final currentBalance = double.tryParse(
                                            userData['main']?.toString() ??
                                                '0') ??
                                        0.0;

                                    final newBalance =
                                        currentBalance + addAmount;

                                    // Update user's main balance
                                    await userRef.update({
                                      'main': newBalance.toStringAsFixed(2),
                                    });

                                    // Add transaction history here
                                    await FirebaseFirestore.instance
                                        .collection('transactions')
                                        .add({
                                      'userId': uid,
                                      'amount': addAmount,
                                      'type': 'Add Money',
                                      'details':
                                          'Money added by admin approval',
                                      'date': Timestamp.now(),
                                    });

                                    // Delete the add money request after acceptance
                                    await FirebaseFirestore.instance
                                        .collection('requests')
                                        .doc('add_money_requests')
                                        .collection('items')
                                        .doc(docId)
                                        .delete();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Money added successfully.')));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                'Cancel',
                                Colors.red[100]!,
                                () async {
                                  await FirebaseFirestore.instance
                                      .collection('requests')
                                      .doc('add_money_requests')
                                      .collection('items')
                                      .doc(docId)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Add money request cancelled.'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        '$title: $value',
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.5),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
