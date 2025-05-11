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

    return Container(
      child: ListTile(
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
      ),
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

          return StreamBuilder(
            stream: (role == 'admin')
                ? FirebaseFirestore.instance
                    .collection('accountStats')
                    .snapshots() // For admin, fetch all user data
                : FirebaseFirestore.instance
                    .collection("accountStats")
                    .doc(uid)
                    .snapshots(), // For user, fetch their own data
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('No data found.'));
              }

              if (role == 'admin' && snapshot.data is QuerySnapshot) {
                final data = (snapshot.data as QuerySnapshot).docs;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final userStats =
                        data[index].data() as Map<String, dynamic>;
                    final balance = userStats['balance']?.toString() ?? '0.00';
                    final received =
                        userStats['totalReceived']?.toString() ?? '0';
                    final sales = userStats['todaysSales']?.toString() ?? '0';
                    final willGive = userStats['iWillGive']?.toString() ?? '0';
                    final cash = userStats['totalCash']?.toString() ?? '0';

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(12),
                            child: Column(
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
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.5,
                                  children: [
                                    _buildStatItem("images/received.png",
                                        'Total Received', '৳$received'),
                                    _buildStatItem(Icons.card_travel_outlined,
                                        'Today\'s Sales', '৳$sales'),
                                    _buildStatItem("images/iwg.png",
                                        'I will give', '৳$willGive'),
                                    _buildStatItem(
                                        Icons.money, 'Total Cash', '৳$cash'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (role == 'user' && snapshot.data is DocumentSnapshot) {
                final data = snapshot.data as DocumentSnapshot;
                final userStats = data.data() as Map<String, dynamic>;

                final balance = userStats['balance']?.toString() ?? '0.00';
                final received = userStats['totalReceived']?.toString() ?? '0';
                final sales = userStats['todaysSales']?.toString() ?? '0';
                final willGive = userStats['iWillGive']?.toString() ?? '0';
                final cash = userStats['totalCash']?.toString() ?? '0';

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(12),
                        child: Column(
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
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: 2.5,
                              children: [
                                _buildStatItem("images/received.png",
                                    'Total Received', '৳$received'),
                                _buildStatItem(Icons.card_travel_outlined,
                                    'Today\'s Sales', '৳$sales'),
                                _buildStatItem("images/iwg.png", 'I will give',
                                    '৳$willGive'),
                                _buildStatItem(
                                    Icons.money, 'Total Cash', '৳$cash'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
