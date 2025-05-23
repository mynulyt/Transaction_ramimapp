import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:ramimapp/button-pages/sales_services.dart';

class RechargeRequestPage extends StatelessWidget {
  const RechargeRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recharge Request'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rechargeRequests')
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
            return const Center(child: Text('No recharge requests found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
              return _buildRequestCard(context, docId, data);
            },
          );
        },
      ),
    );
  }

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
                        color: Colors.orange[100]!,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.phone_android,
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
                          data['operator'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Name: ${data['userName'] ?? 'N/A'}'),
                        Text('Amount: ${data['amount'] ?? 'N/A'}'),
                        Text('Email: ${data['email'] ?? 'N/A'}'),
                        Row(
                          children: [
                            const Text('Number: ',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            SelectableText(
                              data['number'] ?? 'N/A',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w400),
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: data['number'] ?? ''));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Number copied')));
                              },
                            ),
                          ],
                        ),
                        Text('Note: ${data['description'] ?? 'N/A'}'),
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
                      const Color(0xFFD7CCC8),
                      () => _handleAccept(context, docId, data),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Cancel',
                      const Color(0xFFEF9A9A),
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
      final requestedAmount =
          double.tryParse(data['amount']?.toString() ?? '0') ?? 0.0;
      final uid = data['uid'] as String;
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('User not found.')));
        return;
      }

      final userData = userDoc.data()!;
      final currentBalance =
          double.tryParse(userData['main']?.toString() ?? '0') ?? 0.0;

      if (currentBalance < requestedAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insufficient user balance.')));
        return;
      }

      final newBalance = currentBalance - requestedAmount;

      // Update user balance
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'main': newBalance.toStringAsFixed(2)});

      // Add transaction history
      await FirebaseFirestore.instance.collection('TransactionHistory').add({
        'uid': uid,
        'userName': data['userName'] ?? '',
        'operator': data['operator'] ?? '',
        'amount': requestedAmount,
        'number': data['number'] ?? '',
        'email': data['email'] ?? '',
        'description': data['description'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'Recharge',
      });

      // Record in Total Sales
      await SalesService.recordSale(
        collectionName: 'rechargeRequests',
        docId: docId,
        type: 'recharge',
        requestData: data,
        amount: requestedAmount,
        userId: uid,
        userName: data['userName'] ?? 'Unknown',
        userEmail: data['email'] ?? '',
        userPhone: data['number'] ?? '',
      );

      // Delete the request
      await FirebaseFirestore.instance
          .collection('rechargeRequests')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recharge recorded in sales')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _handleCancel(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('rechargeRequests')
        .doc(docId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recharge request cancelled.')),
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
