import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ramimapp/button-pages/transferconfirm_page.dart';

class UsersMyUser extends StatefulWidget {
  const UsersMyUser({super.key});

  @override
  _UsersMyUserState createState() => _UsersMyUserState();
}

class _UsersMyUserState extends State<UsersMyUser> {
  String _searchText = '';
  String _referenceFilter = ''; // For filtering by reference code
  final Map<String, bool> _visibleCards = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title:
            const Text('All My Users', style: TextStyle(color: Colors.white)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Search by name
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchText = value.toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search by name',
                      suffixIcon: Icon(Icons.search, color: Colors.green),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Filter by reference code
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _referenceFilter = value.trim();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Filter by reference code',
                      suffixIcon: Icon(Icons.filter_alt, color: Colors.green),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (_referenceFilter.isEmpty)
            ? FirebaseFirestore.instance
                .collection('users')
                .where('reference',
                    isGreaterThan: '') // Only users with reference
                .snapshots()
            : FirebaseFirestore.instance
                .collection('users')
                .where('reference', isEqualTo: _referenceFilter)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['name']?.toLowerCase().contains(_searchText) ?? false;
          }).toList();

          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final docId = users[index].id;
              final initials = _getInitials(user['name'] ?? '');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green.shade400,
                        child: Text(initials,
                            style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'] ?? '',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(user['phone'] ?? '',
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Spacer(),
                                Text(user['status'] ?? 'Inactive',
                                    style:
                                        const TextStyle(color: Colors.green)),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                    'Last login: ${user['lastLogin'] ?? 'N/A'}'),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    _visibleCards[docId] == true
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                  ),
                                  color: Colors.black54,
                                  onPressed: () {
                                    setState(() {
                                      _visibleCards[docId] =
                                          !(_visibleCards[docId] ?? false);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_visibleCards[docId] == true) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['email'] ?? '',
                                  style: const TextStyle(color: Colors.red)),
                              Text('Created: ${user['createdAt'] ?? ''}',
                                  style: const TextStyle(color: Colors.green)),
                              const SizedBox(height: 8),
                              Text('Main: ৳${user['main'] ?? '0.00'}'),
                              Text('Due: ৳${user['due'] ?? '0.00'}'),
                              Text('Advance: ৳${user['advance'] ?? '0.00'}'),
                              const SizedBox(height: 8),
                              Text(user['address'] ?? '',
                                  style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side:
                                          const BorderSide(color: Colors.green),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TransferConfirmPage()));
                                    },
                                    child: const Text('Payment',
                                        style: TextStyle(color: Colors.green)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '';
  }
}
