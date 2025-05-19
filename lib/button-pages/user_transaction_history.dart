import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class UserTransactionHistoryPage extends StatelessWidget {
  const UserTransactionHistoryPage({super.key});

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
                tmi: data['tmi'] ?? '',
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
    required String tmi,
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
                _getTransactionIcon(name),
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
                  if (tmi.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      tmi,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                  ],
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

  IconData _getTransactionIcon(String name) {
    switch (name) {
      case 'Money Request':
        return Icons.request_page;
      case 'Recharge Request':
        return Icons.phone_android;
      case 'Offer Buy':
        return Icons.local_offer;
      case 'Transfer':
        return Icons.send;
      case 'Admin Added':
        return Icons.add_circle;
      case 'Income':
        return Icons.download;
      default:
        return Icons.swap_horiz;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllTransactions(String? uid) async {
    if (uid == null) return [];

    final List<Map<String, dynamic>> transactions = [];

    // Money Request
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
        'tmi': data['note'] ?? '', // <-- Add TMI here if exists
        'isPositive': false,
      });
    }

    // Recharge Request
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
        'tmi': data['note'] ?? '', // <-- Add TMI here if exists
        'isPositive': false,
      });
    }

    // Offer Buy
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
        'tmi': data['details'] ?? '', // <-- Add TMI here if exists
        'isPositive': false,
      });
    }

    // Transfer
    final transferSnap = await FirebaseFirestore.instance
        .collection('transfer_requests')
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in transferSnap.docs) {
      final data = doc.data();
      transactions.add({
        'name': 'Transfer',
        'amount': data['amount'],
        'date': formatTimestamp(data['timestamp']),
        'type': 'Balance Transfer',
        'tmi': data['note'] ?? '',
        'isPositive': false,
      });
    }

    // Admin Added
    final adminSnap = await FirebaseFirestore.instance
        .collection('admin_added_balance')
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in adminSnap.docs) {
      final data = doc.data();
      transactions.add({
        'name': 'Admin Added',
        'amount': data['amount'],
        'date': formatTimestamp(data['timestamp']),
        'type': data['note'] ?? 'Added by Admin',
        'tmi': '',
        'isPositive': true,
      });
    }

    // Income / Received
    final receivedSnap = await FirebaseFirestore.instance
        .collection('received_money')
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in receivedSnap.docs) {
      final data = doc.data();
      transactions.add({
        'name': 'Income',
        'amount': data['amount'],
        'date': formatTimestamp(data['timestamp']),
        'type': data['source'] ?? 'Received',
        'tmi': '',
        'isPositive': true,
      });
    }

    // Sort all by date (latest first)
    transactions.sort((a, b) =>
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    return transactions;
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    return DateFormat('yyyy-MM-ddTHH:mm:ss')
        .format(dt); // Parseable for sorting
  }
}
