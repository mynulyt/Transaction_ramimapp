import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramimapp/button-pages/sales_services.dart';

class MoneyRequestPage extends StatelessWidget {
  const MoneyRequestPage({super.key});

  // New function to calculate and store total cash
  Future<void> _updateTotalCash() async {
    try {
      final users = await FirebaseFirestore.instance.collection('users').get();
      double total = 0;

      for (final doc in users.docs) {
        final balance =
            double.tryParse(doc.data()['main']?.toString() ?? '0') ?? 0;
        total += balance;
      }

      await FirebaseFirestore.instance
          .collection('TotalCash')
          .doc('total')
          .set({
        'amount': total,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating total cash: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Request'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Total Cash Display
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('TotalCash')
                .doc('total')
                .snapshots(),
            builder: (context, snapshot) {
              final amount =
                  (snapshot.data?.data()?['amount'] as num?)?.toDouble() ?? 0;
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet,
                      color: Colors.green),
                  title: const Text('Total Cash Available'),
                  trailing: Text(
                    '৳${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              );
            },
          ),
          // Requests List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('moneyRequests')
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
                  return const Center(child: Text('No money requests found.'));
                }

                return RefreshIndicator(
                  onRefresh: _updateTotalCash,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;
                      return _buildRequestCard(context, docId, data);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // All your existing methods remain exactly the same below...
  Widget _buildRequestCard(
      BuildContext context, String docId, Map<String, dynamic> data) {
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
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(
                        color: Colors.green[100]!,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.attach_money,
                      size: 30,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Email: ${data['email'] ?? 'N/A'}'),
                        Text('Amount: ${data['amount'] ?? 'N/A'}'),
                        Text('Method: ${data['method'] ?? 'N/A'}'),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Number: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: SelectableText(
                                data['number'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text('Note: ${data['description'] ?? ''}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Accept',
                      const Color(0xFFC8E6C9),
                      () => _handleAccept(context, docId, data),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Cancel',
                      const Color(0xFFFFCDD2),
                      () => _handleCancel(context, docId),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAccept(
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

          // Update total cash
          await _updateTotalCash();

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

          // Delete the request
          await FirebaseFirestore.instance
              .collection('moneyRequests')
              .doc(docId)
              .delete();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Request accepted and recorded in sales')),
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

  Future<void> _handleCancel(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('moneyRequests')
        .doc(docId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Money request cancelled.')),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.3),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
