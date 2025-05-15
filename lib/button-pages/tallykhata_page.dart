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
        _buildStatItem("images/received.png", 'Total Received',
            '৳${stats['totalReceived'] ?? '0'}'),
        _buildStatItem(Icons.card_travel_outlined, 'Today\'s Sales',
            '৳${stats['todaysSales'] ?? '0'}'),
        _buildStatItem(
            "images/iwg.png", 'I will give', '৳${stats['iWillGive'] ?? '0'}'),
        _buildStatItem(
            Icons.money, 'Total Cash', '৳${stats['totalCash'] ?? '0'}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
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

          Stream stream;

          if (role == 'admin') {
            stream = FirebaseFirestore.instance
                .collection('accountStats')
                .snapshots();
          } else {
            stream = FirebaseFirestore.instance
                .collection("accountStats")
                .doc(uid)
                .snapshots();
          }

          return StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: Text('No data found.'));
              }

              if (role == 'admin' && snapshot.data is QuerySnapshot) {
                final docs = (snapshot.data as QuerySnapshot).docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final userStats =
                        docs[index].data() as Map<String, dynamic>;
                    final balance = userStats['balance']?.toString() ?? '0.00';

                    return Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Account Balance',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "৳$balance",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.indigo),
                          _buildStatsGrid(userStats),
                        ],
                      ),
                    );
                  },
                );
              } else if (role == 'user' && snapshot.data is DocumentSnapshot) {
                final userStats = (snapshot.data as DocumentSnapshot).data()
                    as Map<String, dynamic>;
                final balance = userStats['balance']?.toString() ?? '0.00';

                return SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Account Balance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "৳$balance",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.indigo),
                        _buildStatsGrid(userStats),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(
                    child: Text('Invalid role or no data found.'));
              }
            },
          );
        },
      ),
    );
  }
}
