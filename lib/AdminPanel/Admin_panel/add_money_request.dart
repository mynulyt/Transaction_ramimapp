import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMoneyRequestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Money Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('addMoneyRequests')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No requests found'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              final docId = requests[index].id;
              final userId = data['userId'] ?? '';
              final requestedAmount = data['amount'] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      data['name'] != null && data['name'].isNotEmpty
                          ? data['name'][0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  title: Text(data['name'] ?? 'Unknown'),
                  subtitle: Text('Request: ৳$requestedAmount'),
                  trailing: IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      confirmAddMoneyRequest(
                          context, docId, userId, requestedAmount);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> confirmAddMoneyRequest(
    BuildContext context,
    String docId,
    String userId,
    int requestedAmount,
  ) async {
    final pin = await showDialog<String>(
      context: context,
      builder: (context) => PinVerificationDialog(),
    );

    if (pin == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found")),
        );
        return;
      }

      final userPin = userDoc['pin'] ?? '';
      final currentBalance = userDoc['mainBalance'] ?? 0;

      if (pin == userPin) {
        // Update user balance
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'mainBalance': currentBalance + requestedAmount});

        // Delete the request document
        await FirebaseFirestore.instance
            .collection('addMoneyRequests')
            .doc(docId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request approved and balance updated")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect PIN")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}

class PinVerificationDialog extends StatefulWidget {
  @override
  State<PinVerificationDialog> createState() => _PinVerificationDialogState();
}

class _PinVerificationDialogState extends State<PinVerificationDialog> {
  final TextEditingController _pinController = TextEditingController();
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter PIN to Confirm'),
      content: TextField(
        controller: _pinController,
        obscureText: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'PIN',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_pinController.text.trim().isEmpty) {
              setState(() => _showError = true);
            } else {
              Navigator.pop(context, _pinController.text.trim());
            }
          },
          child: const Text('Confirm'),
        ),
      ],
      contentPadding: const EdgeInsets.all(20),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10),
      // Show error message inside the dialog if needed
      semanticLabel: _showError ? 'PIN is required' : null,
    );
  }
}
