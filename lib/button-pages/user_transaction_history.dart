import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class UserTransactionHistoryPage extends StatefulWidget {
  const UserTransactionHistoryPage({super.key});

  @override
  State<UserTransactionHistoryPage> createState() =>
      _UserTransactionHistoryPageState();
}

class _UserTransactionHistoryPageState
    extends State<UserTransactionHistoryPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final transactions = await fetchAllTransactions(user);
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load transactions: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Transaction History'),
        centerTitle: true,
        backgroundColor: Colors.pink[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTransactions,
          ),
        ],
      ),
      body: _buildTransactionList(),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_transactions.isEmpty) {
      return const Center(child: Text('No transactions found.'));
    }

    return RefreshIndicator(
      onRefresh: _fetchTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final data = _transactions[index];
          return _buildTransactionCard(
            name: data['name'] ?? 'Unknown',
            amount: data['amount'].toString(),
            date: data['date'] ?? '',
            type: data['type'] ?? '',
            tmi: data['tmi'] ?? '',
            isPositive: data['isPositive'] ?? true,
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
    final parsedDate = DateTime.tryParse(date);
    final formattedDate = parsedDate != null
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(parsedDate)
        : date;

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
                    formattedDate,
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

  Future<List<Map<String, dynamic>>> fetchAllTransactions(User user) async {
    final List<Map<String, dynamic>> transactions = [];
    final uid = user.uid;
    final email = user.email;
    final phone = user.phoneNumber;

    // Helper function to add transaction with common fields
    void addTransaction({
      required String name,
      required dynamic amount,
      required dynamic timestamp,
      String type = '',
      String tmi = '',
      bool isPositive = false,
    }) {
      transactions.add({
        'name': name,
        'amount': amount is String ? double.parse(amount) : amount,
        'date': formatTimestamp(timestamp is Timestamp ? timestamp : null),
        'type': type,
        'tmi': tmi,
        'isPositive': isPositive,
      });
    }

    try {
      //Money request query
      final moneyQuery = FirebaseFirestore.instance
          .collection('moneyRequests')
          .where('uid', isEqualTo: uid);
      final moneySnap = await moneyQuery.get();
      for (var doc in moneySnap.docs) {
        final data = doc.data();
        addTransaction(
          name: 'Money Request',
          amount: data['amount'],
          timestamp: data['timestamp'],
          type: data['method'] ?? 'Money',
          tmi: data['note'] ?? '',
          isPositive: false,
        );
      }

      // Recharge Request
      final rechargeQuery = FirebaseFirestore.instance
          .collection('rechargeRequests')
          .where('uid', isEqualTo: uid);
      final rechargeSnap = await rechargeQuery.get();
      for (var doc in rechargeSnap.docs) {
        final data = doc.data();
        addTransaction(
          name: 'Recharge Request',
          amount: data['amount'],
          timestamp: data['timestamp'],
          type: data['operator'] ?? 'Recharge',
          tmi: data['note'] ?? '',
          isPositive: false,
        );
      }

      // Offer Buy
      final offerQuery = FirebaseFirestore.instance
          .collection('requests')
          .doc('regular_buy_requests')
          .collection('items')
          .where('userId', isEqualTo: uid);
      final offerSnap = await offerQuery.get();
      for (var doc in offerSnap.docs) {
        final data = doc.data();
        addTransaction(
          name: 'Offer Buy',
          amount: data['price'],
          timestamp: data['submittedAt'],
          type: data['operator'] ?? 'Offer',
          tmi: data['details'] ?? '',
          isPositive: false,
        );
      }

      // Transfer
      final transferQuery = FirebaseFirestore.instance
          .collection('transfer_requests')
          .where('userId', isEqualTo: uid);
      final transferSnap = await transferQuery.get();
      for (var doc in transferSnap.docs) {
        final data = doc.data();
        addTransaction(
          name: 'Transfer',
          amount: data['amount'],
          timestamp: data['timestamp'],
          type: 'Balance Transfer',
          tmi: data['note'] ?? '',
          isPositive: false,
        );
      }

      // Admin Added
      final adminQuery = FirebaseFirestore.instance
          .collection('admin_added_balance')
          .where('userId', isEqualTo: uid);
      final adminSnap = await adminQuery.get();
      for (var doc in adminSnap.docs) {
        final data = doc.data();
        addTransaction(
          name: 'Admin Added',
          amount: data['amount'],
          timestamp: data['timestamp'],
          type: data['note'] ?? 'Added by Admin',
          tmi: '',
          isPositive: true,
        );
      }

      // Income / Received
      final receivedQuery = FirebaseFirestore.instance
          .collection('received_money')
          .where('userId', isEqualTo: uid);
      final receivedSnap = await receivedQuery.get();
      for (var doc in receivedSnap.docs) {
        final data = doc.data();
        addTransaction(
          name: 'Income',
          amount: data['amount'],
          timestamp: data['timestamp'],
          type: data['source'] ?? 'Received',
          tmi: '',
          isPositive: true,
        );
      }

      // Sort all by date (latest first)
      transactions.sort((a, b) =>
          DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

      return transactions;
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return DateTime.now().toIso8601String();
    final dt = timestamp.toDate();
    return dt.toIso8601String();
  }
}
