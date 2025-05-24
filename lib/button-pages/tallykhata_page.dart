import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TallyKhataPage extends StatelessWidget {
  const TallyKhataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TallyKhataScreen();
  }
}

class TallyKhataScreen extends StatelessWidget {
  const TallyKhataScreen({super.key});

  Widget _buildStatItem(dynamic iconOrImage, String title, String value) {
    Widget iconWidget;

    if (iconOrImage is IconData) {
      iconWidget = Icon(iconOrImage, color: Colors.indigo, size: 24);
    } else if (iconOrImage is String) {
      iconWidget = Image.asset(
        iconOrImage,
        width: 24,
        height: 24,
      );
    } else {
      iconWidget = const Icon(Icons.help_outline, color: Colors.red, size: 24);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          iconWidget,
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      children: [
        _buildStatItem(Icons.attach_money, 'Total Sales',
            '৳${stats['totalSales']?.toStringAsFixed(2) ?? '0.00'}'),
        _buildStatItem(Icons.today, 'Today Sales',
            '৳${stats['todaysSales']?.toStringAsFixed(2) ?? '0.00'}'),
        _buildStatItem(Icons.account_balance_wallet, 'Total Transfer',
            '৳${stats['totalTransfer']?.toStringAsFixed(2) ?? '0.00'}'),
        _buildStatItem(Icons.account_balance_wallet, 'Today Transfer',
            '৳${stats['todaysTransfer']?.toStringAsFixed(2) ?? '0.00'}'),
        _buildStatItem(Icons.payments, 'Total Received',
            '৳${stats['totalReceived']?.toStringAsFixed(2) ?? '0.00'}'),
        _buildStatItem(Icons.payments, 'Today Received',
            '৳${stats['todaysReceived']?.toStringAsFixed(2) ?? '0.00'}'),
      ],
    );
  }

  Future<Map<String, dynamic>> _getSalesData(
      String userId, bool isAdmin) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    QuerySnapshot salesQuery;

    if (isAdmin) {
      salesQuery =
          await FirebaseFirestore.instance.collection('TotalSales').get();
    } else {
      salesQuery = await FirebaseFirestore.instance
          .collection('TotalSales')
          .where('userId', isEqualTo: userId)
          .get();
    }

    double totalSales = 0;
    double todaysSales = 0;

    for (final doc in salesQuery.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final timestamp = data['timestamp'] as Timestamp?;

      totalSales += amount;

      if (timestamp != null && timestamp.toDate().isAfter(todayStart)) {
        todaysSales += amount;
      }
    }

    return {
      'totalSales': totalSales,
      'todaysSales': todaysSales,
    };
  }

  Future<Map<String, dynamic>> _getTransferData(
      String userId, bool isAdmin) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Get sent transfers (as sender)
    QuerySnapshot sentTransferQuery = isAdmin
        ? await FirebaseFirestore.instance.collection('Total Transfer').get()
        : await FirebaseFirestore.instance
            .collection('Total Transfer')
            .where('senderId', isEqualTo: userId)
            .get();

    // Get received transfers (as receiver)
    QuerySnapshot receivedTransferQuery = isAdmin
        ? await FirebaseFirestore.instance.collection('Total Transfer').get()
        : await FirebaseFirestore.instance
            .collection('Total Transfer')
            .where('receiverId', isEqualTo: userId)
            .get();

    double totalTransfer = 0;
    double todaysTransfer = 0;
    double totalReceived = 0;
    double todaysReceived = 0;

    // Calculate sent amounts
    for (final doc in sentTransferQuery.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final timestamp = data['timestamp'] as Timestamp?;

      totalTransfer += amount;

      if (timestamp != null && timestamp.toDate().isAfter(todayStart)) {
        todaysTransfer += amount;
      }
    }

    // Calculate received amounts
    for (final doc in receivedTransferQuery.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final timestamp = data['timestamp'] as Timestamp?;

      totalReceived += amount;

      if (timestamp != null && timestamp.toDate().isAfter(todayStart)) {
        todaysReceived += amount;
      }
    }

    return {
      'totalTransfer': totalTransfer,
      'todaysTransfer': todaysTransfer,
      'totalReceived': totalReceived,
      'todaysReceived': todaysReceived,
    };
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tally Khata'),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("users").doc(uid).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text('User not found.'));
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final role = userData['role'];
          final isAdmin = role == 'admin';

          return FutureBuilder<Map<String, dynamic>>(
            future: Future.wait([
              _getSalesData(uid!, isAdmin),
              _getTransferData(uid, isAdmin),
            ]).then((results) {
              return {
                ...results[0], // sales data
                ...results[1], // transfer data
              };
            }),
            builder: (context, combinedSnapshot) {
              if (combinedSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final combinedData = combinedSnapshot.data ??
                  {
                    'totalSales': 0,
                    'todaysSales': 0,
                    'totalTransfer': 0,
                    'todaysTransfer': 0,
                    'totalReceived': 0,
                    'todaysReceived': 0,
                  };

              Stream statsStream = isAdmin
                  ? FirebaseFirestore.instance
                      .collection('accountStats')
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('accountStats')
                      .doc(uid)
                      .snapshots();

              return StreamBuilder(
                stream: statsStream,
                builder: (context, statsSnapshot) {
                  if (statsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!statsSnapshot.hasData) {
                    return const Center(child: Text('No stats data found.'));
                  }

                  if (isAdmin && statsSnapshot.data is QuerySnapshot) {
                    // Admin view - multiple users
                    final docs = (statsSnapshot.data as QuerySnapshot).docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final userStats =
                            docs[index].data() as Map<String, dynamic>;
                        final completeStats = {
                          ...userStats,
                          ...combinedData,
                        };

                        return _buildUserStatsCard(completeStats);
                      },
                    );
                  } else if (!isAdmin &&
                      statsSnapshot.data is DocumentSnapshot) {
                    // User view - single user
                    final userStats = (statsSnapshot.data as DocumentSnapshot)
                            .data() as Map<String, dynamic>? ??
                        {};
                    final completeStats = {
                      ...userStats,
                      ...combinedData,
                    };

                    return SingleChildScrollView(
                      child: _buildUserStatsCard(completeStats),
                    );
                  } else {
                    return const Center(child: Text('Invalid data format.'));
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserStatsCard(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[800],
            ),
          ),
          const Divider(thickness: 1),
          _buildStatsGrid(stats),
          const SizedBox(height: 16),
          _buildRecentTransactionsList(stats['userId']?.toString()),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsList(String? userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: userId != null
              ? FirebaseFirestore.instance
                  .collection('Total Transfer')
                  .where('senderId', isEqualTo: userId)
                  .orderBy('timestamp', descending: true)
                  .limit(5)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('Total Transfer')
                  .orderBy('timestamp', descending: true)
                  .limit(5)
                  .snapshots(),
          builder: (context, sentSnapshot) {
            if (sentSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return StreamBuilder<QuerySnapshot>(
              stream: userId != null
                  ? FirebaseFirestore.instance
                      .collection('Total Transfer')
                      .where('receiverId', isEqualTo: userId)
                      .orderBy('timestamp', descending: true)
                      .limit(5)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('Total Transfer')
                      .orderBy('timestamp', descending: true)
                      .limit(5)
                      .snapshots(),
              builder: (context, receivedSnapshot) {
                if (receivedSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final sentTransactions = sentSnapshot.data?.docs ?? [];
                final receivedTransactions = receivedSnapshot.data?.docs ?? [];

                if (sentTransactions.isEmpty && receivedTransactions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No recent transactions found.'),
                  );
                }

                // Combine and sort both sent and received transactions by timestamp
                final allTransactions = [
                  ...sentTransactions
                      .map((doc) => {'type': 'sent', 'data': doc.data()}),
                  ...receivedTransactions
                      .map((doc) => {'type': 'received', 'data': doc.data()}),
                ]..sort((a, b) {
                    final aTimestamp = (a['data']
                        as Map<String, dynamic>)['timestamp'] as Timestamp?;
                    final bTimestamp = (b['data']
                        as Map<String, dynamic>)['timestamp'] as Timestamp?;
                    return (bTimestamp ?? Timestamp.now())
                        .compareTo(aTimestamp ?? Timestamp.now());
                  });

                // Take only the last 5 combined transactions
                final recentTransactions = allTransactions.take(5).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = recentTransactions[index];
                    final data = transaction['data'] as Map<String, dynamic>;
                    final isReceived = transaction['type'] == 'received';
                    final amount =
                        (data['amount'] as num?)?.toStringAsFixed(2) ?? '0.00';
                    final otherPartyName = isReceived
                        ? data['senderName']?.toString() ?? 'Unknown'
                        : data['receiverName']?.toString() ?? 'Unknown';
                    final date = (data['timestamp'] as Timestamp?)?.toDate() ??
                        DateTime.now();

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isReceived
                                ? Colors.green[100]
                                : Colors.indigo[100],
                            child: Icon(
                              isReceived
                                  ? Icons.call_received
                                  : Icons.call_made,
                              color: isReceived ? Colors.green : Colors.indigo,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isReceived
                                      ? 'Received from $otherPartyName'
                                      : 'Transfer to $otherPartyName',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '৳$amount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isReceived
                                        ? Colors.green
                                        : Colors.indigo,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM').format(date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
