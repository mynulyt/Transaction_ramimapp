import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserTransactionHistoryPage extends StatefulWidget {
  const UserTransactionHistoryPage({super.key});

  @override
  State<UserTransactionHistoryPage> createState() =>
      _UserTransactionHistoryPageState();
}

class _UserTransactionHistoryPageState
    extends State<UserTransactionHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      deleteOldTransactions();
    }
  }

  // Delete transactions older than 1 month for current user
  Future<void> deleteOldTransactions() async {
    if (_currentUser == null) return;

    final DateTime oneMonthAgo =
        DateTime.now().subtract(const Duration(days: 30));
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('TransactionHistory')
          .where('userId', isEqualTo: _currentUser!.uid)
          .where('timestamp', isLessThan: Timestamp.fromDate(oneMonthAgo))
          .get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await _firestore.collection('TransactionHistory').doc(doc.id).delete();
      }
    } catch (e) {
      debugPrint('Error deleting old transactions: $e');
    }
  }

  // Delete all transactions for current user with confirmation
  Future<void> deleteAllTransactions() async {
    if (_currentUser == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text(
            "Are you sure you want to delete all your transactions?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete All"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final snapshot = await _firestore
            .collection('TransactionHistory')
            .where('userId', isEqualTo: _currentUser!.uid)
            .get();

        for (QueryDocumentSnapshot doc in snapshot.docs) {
          await _firestore
              .collection('TransactionHistory')
              .doc(doc.id)
              .delete();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All your transactions deleted.")),
        );
      } catch (e) {
        debugPrint("Error deleting all transactions: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.indigo,
        body: const Center(
          child: Text(
            'Please sign in to view transaction history',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        title: const Text(
          'Your Transaction History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Delete All",
            onPressed: deleteAllTransactions,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('TransactionHistory')
            .where('userId', isEqualTo: _currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!.docs;

          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final data = transactions[index].data() as Map<String, dynamic>;

              final userName = data['userName'] ?? data['name'] ?? 'User';
              final amount = data['amount']?.toString() ?? '0';
              final method = data['method'] ?? '';
              final status = data['status'] ?? 'N/A';
              final action = data['action'] ?? '';
              final rechargeNumber = data['rechargeNumber'] ?? '';
              final operator = data['operator'] ?? '';
              final type = data['type'] ?? '';
              final number = data['number'] ?? '';
              final timestamp = data['timestamp'] as Timestamp?;
              final formattedDate = timestamp != null
                  ? DateFormat('dd MMM yyyy, hh:mm a')
                      .format(timestamp.toDate())
                  : 'Unknown date';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.orangeAccent,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (type.isNotEmpty && type != 'N/A') Text('Type: $type'),
                      if (action.isNotEmpty && action != 'N/A')
                        Text('Action: $action'),
                      if (rechargeNumber.isNotEmpty && rechargeNumber != 'N/A')
                        Text('Recharge: $rechargeNumber'),
                      if (operator.isNotEmpty && operator != 'N/A')
                        Text('Operator: $operator'),
                      if (number.isNotEmpty && number != 'N/A')
                        Text('Number: $number'),
                      if (method.isNotEmpty && method != 'N/A')
                        Text('Method: $method'),
                      if (formattedDate != 'Unknown date')
                        Text('Date: $formattedDate'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '৳ $amount',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'Approved'
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color: status == 'Approved'
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
