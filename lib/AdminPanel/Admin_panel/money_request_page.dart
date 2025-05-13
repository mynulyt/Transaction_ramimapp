import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MoneyRequestPage extends StatelessWidget {
  const MoneyRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Request'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('moneyRequests')
            .snapshots(), // ✅ Correct collection name
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No money requests found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                                border: Border.all(
                                  color: Colors.green[100]!,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.attach_money,
                                size: 30,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Email: ${data['email'] ?? 'N/A'}'),
                                  Text('Amount: ${data['amount'] ?? 'N/A'}'),
                                  Text('Method: ${data['method'] ?? 'N/A'}'),
                                  Text('Number: ${data['number'] ?? 'N/A'}'),
                                  Text('Note: ${data['description'] ?? ''}'),
                                  Text('Status: ${data['status'] ?? ''}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                  'Accept', const Color(0xFFC8E6C9), () async {
                                await FirebaseFirestore.instance
                                    .collection('moneyRequests')
                                    .doc(docId)
                                    .delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Money request accepted.')),
                                );
                              }),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                  'Cancel', const Color(0xFFFFCDD2), () async {
                                await FirebaseFirestore.instance
                                    .collection('moneyRequests')
                                    .doc(docId)
                                    .delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Money request cancelled.')),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.3),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
