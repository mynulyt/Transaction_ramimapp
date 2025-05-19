import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ramimapp/button-pages/user_to_user_pay.dart';

class UsersMyUser extends StatefulWidget {
  final String currentUserPhone;

  const UsersMyUser({super.key, required this.currentUserPhone});

  @override
  _UsersMyUserState createState() => _UsersMyUserState();
}

class _UsersMyUserState extends State<UsersMyUser> {
  String _searchText = '';
  final Map<String, bool> _visibleCards = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text('My User', style: TextStyle(color: Colors.white)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _buildSearchField('Search by name or phone', (value) {
                  setState(() {
                    _searchText = value.toLowerCase();
                  });
                }, Icons.search),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('reference', isEqualTo: widget.currentUserPhone)
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
            final name = data['name']?.toLowerCase() ?? '';
            final phone = data['phone']?.toLowerCase() ?? '';
            return name.contains(_searchText) || phone.contains(_searchText);
          }).toList();

          if (users.isEmpty) {
            return const Center(
                child: Text('No users found under your reference'));
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
                  _buildUserHeader(user, initials, docId),
                  if (_visibleCards[docId] == true) _buildUserDetailsCard(user),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchField(
      String hint, Function(String) onChanged, IconData icon) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: Icon(icon, color: Colors.green),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildUserHeader(
      Map<String, dynamic> user, String initials, String docId) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.green.shade400,
          child: Text(initials, style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['name'] ?? '',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(user['phone'] ?? '',
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Spacer(),
                  Text(user['status'] ?? 'Inactive',
                      style: const TextStyle(color: Colors.green)),
                ],
              ),
              Row(
                children: [
                  Text('Last login: ${user['lastLogin'] ?? 'N/A'}'),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _visibleCards[docId] == true
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                    ),
                    onPressed: () {
                      setState(() {
                        _visibleCards[docId] = !(_visibleCards[docId] ?? false);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetailsCard(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserToUserTransferConfirmPage(
                            receiverName: user['name'],
                            receiverPhone: user['phone'],
                          ),
                        ),
                      );
                    },
                    child: const Text('Payment',
                        style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty) return parts[0][0].toUpperCase();
    return '';
  }
}
