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
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _currentUserEmail = _currentUser!.email;
      deleteOldTransactions();
    }
  }

  // delete transaction for 1 month
  Future<void> deleteOldTransactions() async {
    if (_currentUser == null) return;

    final DateTime oneMonthAgo =
        DateTime.now().subtract(const Duration(days: 30));
    try {
      // Get transactions matching either uid, userId, or email
      final QuerySnapshot snapshot = await _firestore
          .collection('TransactionHistory')
          .where('timestamp', isLessThan: Timestamp.fromDate(oneMonthAgo))
          .get();

      final List<QueryDocumentSnapshot> userDocs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['uid'] == _currentUser!.uid ||
            data['userId'] == _currentUser!.uid ||
            data['email'] == _currentUserEmail ||
            data['userEmail'] == _currentUserEmail;
      }).toList();

      for (QueryDocumentSnapshot doc in userDocs) {
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
        final snapshot =
            await _firestore.collection('TransactionHistory').get();

        final List<QueryDocumentSnapshot> userDocs = snapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['uid'] == _currentUser!.uid ||
              data['userId'] == _currentUser!.uid ||
              data['email'] == _currentUserEmail ||
              data['userEmail'] == _currentUserEmail;
        }).toList();

        for (QueryDocumentSnapshot doc in userDocs) {
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
        stream: _firestore.collection('TransactionHistory').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter transactions to only show current user's
          final transactions = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['uid'] == _currentUser!.uid ||
                data['userId'] == _currentUser!.uid ||
                data['email'] == _currentUserEmail ||
                data['userEmail'] == _currentUserEmail;
          }).toList();

          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          // Sort by timestamp descending
          transactions.sort((a, b) {
            final aTime =
                (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            final bTime =
                (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            return (bTime ?? Timestamp.now())
                .compareTo(aTime ?? Timestamp.now());
          });

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final data = transactions[index].data() as Map<String, dynamic>;

              final userName = data['userName'] ?? data['name'] ?? 'User';
              final amount = data['amount']?.toString() ??
                  data['price']?.toString() ??
                  '0';
              final method = data['method'] ?? '';
              final status = data['status'] ?? 'N/A';
              final action = data['action'] ?? '';
              final rechargeNumber = data['rechargeNumber'] ??
                  data['accountNumber'] ??
                  data['number'] ??
                  '';
              final operator = data['operator'] ?? '';
              final type = data['type'] ?? data['offerType'] ?? '';
              final description = data['description'] ?? '';
              final timestamp = data['timestamp'] as Timestamp?;
              final formattedDate = timestamp != null
                  ? DateFormat('dd MMM yyyy, hh:mm a')
                      .format(timestamp.toDate())
                  : 'Unknown date';

              // Additional fields specific to your data structure
              final internet = data['internet'] ?? '';
              final minutes = data['minutes'] ?? '';
              final sms = data['sms'] ?? '';
              final term = data['term'] ?? '';
              final balanceAfter = data['balanceAfter'] ?? '';

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
                        Text('Number: $rechargeNumber'),
                      if (operator.isNotEmpty && operator != 'N/A')
                        Text('Operator: $operator'),
                      if (method.isNotEmpty && method != 'N/A')
                        Text('Method: $method'),
                      if (description.isNotEmpty && description != 'N/A')
                        Text('Description: $description'),
                      if (internet.isNotEmpty) Text('Internet: $internet'),
                      if (minutes.isNotEmpty) Text('Minutes: $minutes'),
                      if (sms.isNotEmpty) Text('SMS: $sms'),
                      if (term.isNotEmpty) Text('Term: $term'),
                      if (balanceAfter.isNotEmpty)
                        Text('Balance After: $balanceAfter'),
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
                          color: status == 'confirmed' || status == 'Approved'
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color: status == 'confirmed' || status == 'Approved'
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
