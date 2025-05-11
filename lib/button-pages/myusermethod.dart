import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyUserMethod extends StatefulWidget {
  const MyUserMethod({super.key});

  @override
  _MyUserMethodState createState() => _MyUserMethodState();
}

class _MyUserMethodState extends State<MyUserMethod> {
  String _searchText = '';
  Map<String, bool> _visibleCards = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text(''),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
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
                  hintText: 'Search',
                  suffixIcon: Icon(Icons.search, color: Colors.green),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(), // Collection name
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

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final docId = users[index].id;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.green, size: 40),
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
                                  icon: const Icon(Icons.arrow_drop_down),
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
                              ...[
                                'Main: ৳${user['main'] ?? '0.00'}',
                                'Due: ৳${user['due'] ?? '0.00'}',
                                'Advance: ৳${user['advance'] ?? '0.00'}',
                              ].map((e) => Text(e)),
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
                                    onPressed: () {},
                                    child: const Text('Payment',
                                        style: TextStyle(color: Colors.green)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side:
                                          const BorderSide(color: Colors.green),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: const Text('Edit',
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
}
