import 'package:flutter/material.dart';

class TransferMethodPage extends StatelessWidget {
  const TransferMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> transferMethods = [
      {
        'name': 'bKash',
        'image': 'images/bkash_logo.png',
      },
      {
        'name': 'Nagad',
        'image': 'images/nagad.jpg',
      },
      {
        'name': 'Rocket',
        'image': 'images/rocket.png',
      },
      {
        'name': 'Upay',
        'image': 'images/upay.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Transfer Method'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transferMethods.length,
        itemBuilder: (context, index) {
          final method = transferMethods[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Image.asset(
                method['image']!,
                width: 40,
                height: 40,
              ),
              title: Text(
                method['name']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to the next screen with selected method
                Navigator.pushNamed(
                  context,
                  '/transferDetails',
                  arguments: method['name'],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
