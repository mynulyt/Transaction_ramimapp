import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Transaction History'),
        centerTitle: true,
        backgroundColor: Colors.pink[700],
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAllTransactions(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTransactions = snapshot.data ?? [];

          if (allTransactions.isEmpty) {
            return const Center(child: Text('No transaction history found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: allTransactions.length,
            itemBuilder: (context, index) {
              final data = allTransactions[index];

              return _buildTransactionCard(
                name: data['name'] ?? 'Unknown',
                amount: data['amount'].toString(),
                date: data['date'] ?? '',
                type: data['type'] ?? '',
                isPositive: data['isPositive'] ?? true,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard({
    required String name,
    required String amount,
    required String date,
    required String type,
    required bool isPositive,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPositive ? Colors.green[100] : Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              '${isPositive ? '+' : '-'}৳$amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllTransactions(String? uid) async {
    if (uid == null) return [];

    final List<Map<String, dynamic>> transactions = [];

    final moneySnap = await FirebaseFirestore.instance
        .collection('moneyRequests')
        .where('uid', isEqualTo: uid)
        .get();
    for (var doc in moneySnap.docs) {
      final data = doc.data();
      transactions.add({
        'name': 'Money Request',
        'amount': data['amount'],
        'date': formatTimestamp(data['timestamp']),
        'type': data['method'] ?? 'Money',
        'isPositive': false,
      });
    }

    final rechargeSnap = await FirebaseFirestore.instance
        .collection('rechargeRequests')
        .where('uid', isEqualTo: uid)
        .get();
    for (var doc in rechargeSnap.docs) {
      final data = doc.data();
      transactions.add({
        'name': 'Recharge Request',
        'amount': data['amount'],
        'date': formatTimestamp(data['timestamp']),
        'type': data['operator'] ?? 'Recharge',
        'isPositive': false,
      });
    }

    final offerSnap = await FirebaseFirestore.instance
        .collection('requests')
        .doc('regular_buy_requests')
        .collection('items')
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in offerSnap.docs) {
      final data = doc.data();
      transactions.add({
        'name': 'Offer Buy',
        'amount': data['price'],
        'date': formatTimestamp(data['submittedAt']),
        'type': data['operator'] ?? 'Offer',
        'isPositive': false,
      });
    }

    final transferSnap = await FirebaseFirestore.instance
        .collection('transfer_requests')
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in transferSnap.docs) {
      final data = doc.data();
      transactions.add({
        'name': data['name'] ?? 'Transfer',
        'amount': data['amount'],
        'date': formatTimestamp(data['timestamp']),
        'type': 'Balance Transfer',
        'isPositive': false,
      });
    }

    transactions.sort((a, b) =>
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    return transactions;
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }
}
