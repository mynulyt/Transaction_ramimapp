import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        _buildStatItem(Icons.account_balance_wallet, 'Account Balance',
            '৳${stats['balance']?.toStringAsFixed(2) ?? '0.00'}'),
        _buildStatItem(Icons.payments, 'Total Received',
            '৳${stats['totalReceived']?.toStringAsFixed(2) ?? '0.00'}'),
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

  Widget _buildTotalCashList(String? userId, bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Money Requests',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: isAdmin
              ? FirebaseFirestore.instance
                  .collection('Total Cash')
                  .orderBy('timestamp', descending: true)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('Total Cash')
                  .where('uid', isEqualTo: userId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No money requests found.'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final cashData = snapshot.data!.docs[index];
                final data = cashData.data() as Map<String, dynamic>;
                final amount = data['amount']?.toString() ?? '0';
                final method = data['method']?.toString() ?? 'N/A';
                final date = (data['timestamp'] as Timestamp?)?.toDate() ??
                    DateTime.now();
                final status = data['status']?.toString() ?? 'Completed';
                final description = data['description']?.toString() ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo[100],
                      child: const Icon(
                        Icons.attach_money,
                        color: Colors.indigo,
                      ),
                    ),
                    title: Text('৳$amount - $method'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(description),
                        Text(
                          '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        status,
                        style: TextStyle(
                          color: status == 'Completed'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      backgroundColor: status == 'Completed'
                          ? Colors.green[50]
                          : Colors.orange[50],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
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
            future: _getSalesData(uid!, isAdmin),
            builder: (context, salesSnapshot) {
              if (salesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final salesData =
                  salesSnapshot.data ?? {'totalSales': 0, 'todaysSales': 0};

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
                        final combinedStats = {
                          ...userStats,
                          'totalSales': salesData['totalSales'],
                          'todaysSales': salesData['todaysSales'],
                        };

                        return _buildUserStatsCard(combinedStats, isAdmin);
                      },
                    );
                  } else if (!isAdmin &&
                      statsSnapshot.data is DocumentSnapshot) {
                    // User view - single user
                    final userStats = (statsSnapshot.data as DocumentSnapshot)
                            .data() as Map<String, dynamic>? ??
                        {};
                    final combinedStats = {
                      ...userStats,
                      'totalSales': salesData['totalSales'],
                      'todaysSales': salesData['todaysSales'],
                    };

                    return SingleChildScrollView(
                      child: _buildUserStatsCard(combinedStats, isAdmin),
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

  Widget _buildUserStatsCard(Map<String, dynamic> stats, bool isAdmin) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

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
          _buildRecentSalesList(stats['userId']?.toString()),
          const SizedBox(height: 16),
          _buildTotalCashList(uid, isAdmin),
        ],
      ),
    );
  }

  Widget _buildRecentSalesList(String? userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Sales',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: userId != null
              ? FirebaseFirestore.instance
                  .collection('TotalSales')
                  .where('userId', isEqualTo: userId)
                  .orderBy('timestamp', descending: true)
                  .limit(5)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('TotalSales')
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
                child: Text('No recent sales found.'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final sale = snapshot.data!.docs[index];
                final data = sale.data() as Map<String, dynamic>;
                final amount = data['amount']?.toString() ?? '0';
                final type = data['type']?.toString() ?? 'Sale';
                final date = (data['timestamp'] as Timestamp?)?.toDate() ??
                    DateTime.now();

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo[100],
                    child: Icon(
                      _getSaleIcon(type),
                      color: Colors.indigo,
                    ),
                  ),
                  title: Text('$type - ৳$amount'),
                  subtitle: Text(
                    '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}',
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

  IconData _getSaleIcon(String type) {
    switch (type) {
      case 'Sent TK':
        return Icons.attach_money;
      case 'Recharge':
        return Icons.phone_android;
      case 'Regular Offer':
        return Icons.local_offer;
      default:
        return Icons.shopping_cart;
    }
  }
}
