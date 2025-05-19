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
        title: const Text('My Transactions'),
        centerTitle: true,
        backgroundColor: Colors.pink[700],
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchUserTransactions(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final data = transactions[index];
              return _buildTransactionCard(
                name: data['name'] ?? 'Transaction',
                amount: data['amount'].toString(),
                date: data['date'] ?? '',
                type: data['type'] ?? '',
                tmi: data['tmi'] ?? '',
                isPositive: data['isPositive'] ?? false,
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
                    DateFormat('dd MMM yyyy, hh:mm a')
                        .format(DateTime.parse(date)),
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
    if (name.contains('Request')) return Icons.request_page;
    if (name.contains('Recharge')) return Icons.phone_android;
    if (name.contains('Offer')) return Icons.local_offer;
    if (name.contains('Transfer')) return Icons.send;
    if (name.contains('Admin')) return Icons.admin_panel_settings;
    if (name.contains('Income')) return Icons.download;
    return Icons.swap_horiz;
  }

  Stream<List<Map<String, dynamic>>> fetchUserTransactions(String? uid) {
    if (uid == null) return Stream.value([]);

    // Combine all transaction streams
    return Stream.merge([
      _getMoneyRequests(uid),
      _getRechargeRequests(uid),
      _getOfferPurchases(uid),
      _getTransfers(uid),
      _getAdminAdded(uid),
      _getReceivedMoney(uid),
    ]).map((transactions) {
      // Sort by date (newest first)
      transactions.sort((a, b) =>
          DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      return transactions;
    });
  }

  Stream<List<Map<String, dynamic>>> _getMoneyRequests(String uid) {
    return FirebaseFirestore.instance
        .collection('moneyRequests')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'name': 'Money Request',
                'amount': data['amount']?.toString() ?? '0',
                'date': formatTimestamp(data['timestamp']),
                'type': data['method'] ?? 'Payment',
                'tmi': data['note'] ?? '',
                'isPositive': false,
              };
            }).toList());
  }

  Stream<List<Map<String, dynamic>>> _getRechargeRequests(String uid) {
    return FirebaseFirestore.instance
        .collection('rechargeRequests')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'name': 'Recharge',
                'amount': data['amount']?.toString() ?? '0',
                'date': formatTimestamp(data['timestamp']),
                'type': data['operator'] ?? 'Mobile',
                'tmi': data['number'] ?? '',
                'isPositive': false,
              };
            }).toList());
  }

  Stream<List<Map<String, dynamic>>> _getOfferPurchases(String uid) {
    return FirebaseFirestore.instance
        .collection('requests')
        .doc('regular_buy_requests')
        .collection('items')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'name': 'Offer Purchase',
                'amount': data['price']?.toString() ?? '0',
                'date': formatTimestamp(data['submittedAt']),
                'type': data['operator'] ?? 'Offer',
                'tmi': data['details'] ?? '',
                'isPositive': false,
              };
            }).toList());
  }

  Stream<List<Map<String, dynamic>>> _getTransfers(String uid) {
    return FirebaseFirestore.instance
        .collection('transfer_requests')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'name': 'Balance Transfer',
                'amount': data['amount']?.toString() ?? '0',
                'date': formatTimestamp(data['timestamp']),
                'type': 'To ${data['receiverName'] ?? 'User'}',
                'tmi': data['note'] ?? '',
                'isPositive': false,
              };
            }).toList());
  }

  Stream<List<Map<String, dynamic>>> _getAdminAdded(String uid) {
    return FirebaseFirestore.instance
        .collection('admin_added_balance')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'name': 'Admin Adjustment',
                'amount': data['amount']?.toString() ?? '0',
                'date': formatTimestamp(data['timestamp']),
                'type': data['note'] ?? 'Balance adjustment',
                'tmi': '',
                'isPositive': true,
              };
            }).toList());
  }

  Stream<List<Map<String, dynamic>>> _getReceivedMoney(String uid) {
    return FirebaseFirestore.instance
        .collection('received_money')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'name': 'Received Money',
                'amount': data['amount']?.toString() ?? '0',
                'date': formatTimestamp(data['timestamp']),
                'type': 'From ${data['senderName'] ?? 'User'}',
                'tmi': data['note'] ?? '',
                'isPositive': true,
              };
            }).toList());
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return DateTime.now().toIso8601String();
    return timestamp.toDate().toIso8601String();
  }
}
