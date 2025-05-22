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
      iconWidget = Icon(iconOrImage, color: Colors.indigo);
    } else if (iconOrImage is String) {
      iconWidget = Image.asset(
        iconOrImage,
        width: 24,
        height: 24,
      );
    } else {
      iconWidget = const Icon(Icons.help_outline, color: Colors.red);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconWidget,
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(title),
            ],
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
      childAspectRatio: 2.5,
      children: [
        _buildStatItem(Icons.attach_money, 'Total Sales',
            '৳${stats['totalSales']?.toStringAsFixed(2) ?? '0.00'}'),
        _buildStatItem(Icons.today, 'Today\'s Sales',
            '৳${stats['todaysSales']?.toStringAsFixed(2) ?? '0.00'}'),
        _buildStatItem(Icons.account_balance_wallet, 'Total Transfer',
            '৳${stats['totalTransfer']?.toStringAsFixed(2) ?? '0.00'}'),
        _buildStatItem(Icons.account_balance_wallet, 'Today\'s Transfer',
            '৳${stats['todaysTransfer']?.toStringAsFixed(2) ?? '0.00'}'),
        _buildStatItem(Icons.payments, 'Total Received',
            '৳${stats['totalReceived']?.toStringAsFixed(2) ?? '0.00'}'),
        _buildStatItem(Icons.payments, 'Today\'s Received',
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

    QuerySnapshot transferQuery;

    if (isAdmin) {
      transferQuery =
          await FirebaseFirestore.instance.collection('Total Transfer').get();
    } else {
      transferQuery = await FirebaseFirestore.instance
          .collection('Total Transfer')
          .where('senderId', isEqualTo: userId)
          .get();
    }

    double totalTransfer = 0;
    double todaysTransfer = 0;

    for (final doc in transferQuery.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final timestamp = data['timestamp'] as Timestamp?;

      totalTransfer += amount;

      if (timestamp != null && timestamp.toDate().isAfter(todayStart)) {
        todaysTransfer += amount;
      }
    }

    return {
      'totalTransfer': totalTransfer,
      'todaysTransfer': todaysTransfer,
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
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No recent transactions found.'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final transaction = snapshot.data!.docs[index];
                final data = transaction.data() as Map<String, dynamic>;
                final amount = data['amount']?.toString() ?? '0';
                final receiverName =
                    data['receiverName']?.toString() ?? 'Unknown';
                final date = (data['timestamp'] as Timestamp?)?.toDate() ??
                    DateTime.now();

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo[100],
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.indigo,
                    ),
                  ),
                  title: Text('Transfer to $receiverName - ৳$amount'),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(date),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
