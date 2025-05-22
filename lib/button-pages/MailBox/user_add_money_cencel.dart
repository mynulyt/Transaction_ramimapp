import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMoneyRequestPageCancle extends StatefulWidget {
  const AddMoneyRequestPageCancle({super.key});

  @override
  State<AddMoneyRequestPageCancle> createState() =>
      _AddMoneyRequestPageCancleState();
}

class _AddMoneyRequestPageCancleState extends State<AddMoneyRequestPageCancle> {
  final String adminId = 'mynulalam';
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    currentUserId = user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Add Money Requests'),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('addMoneyRequests')
            .where('userId', isEqualTo: currentUserId)
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
            padding: const EdgeInsets.all(8),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              final docId = requests[index].id;

              final userId = data['userId'] ?? '';
              final requestedAmount = data['amount'] ?? 0;
              final userName = data['name'] ?? 'Unknown';
              final method = data['method'] ?? 'N/A';
              final senderNumber = data['senderNumber'] ?? 'N/A';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),
                builder: (context, userSnapshot) {
                  String accountNumber = 'Unknown';
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    accountNumber = userData['phone'] ?? 'Unknown';
                  }

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  userName,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _infoRow(
                              'Amount:', '৳$requestedAmount', Colors.green),
                          _infoRow('Method:', method),
                          _infoRow('Sender Number:', senderNumber),
                          _infoRow('User Account Number:', accountNumber),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel',
                                style: TextStyle(fontSize: 22)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: () {
                              _handleCancelRequest(context, docId);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow(String title, String value, [Color? valueColor]) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: '$title ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          TextSpan(
              text: value,
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }

  Future<void> _handleCancelRequest(BuildContext context, String docId) async {
    final pin = await showDialog<String>(
      context: context,
      builder: (context) => const PinVerificationDialog(),
    );

    if (pin == null) return;

    try {
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('AdminPanel')
          .doc(adminId)
          .get();

      final adminPin = adminSnapshot['pin'] ?? '';

      if (pin != adminPin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect PIN")),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('addMoneyRequests')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request cancelled")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}

class PinVerificationDialog extends StatefulWidget {
  const PinVerificationDialog({super.key});

  @override
  State<PinVerificationDialog> createState() => _PinVerificationDialogState();
}

class _PinVerificationDialogState extends State<PinVerificationDialog> {
  final TextEditingController _pinController = TextEditingController();
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Admin PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter your PIN',
              errorText: _showError ? 'PIN is required' : null,
            ),
          ),
        ],
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
    );
  }
}
