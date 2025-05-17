import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMoneyRequestPage extends StatelessWidget {
  const AddMoneyRequestPage({super.key});

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
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row with avatar and name
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

                          // Amount row
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                    text: 'Amount: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87)),
                                TextSpan(
                                    text: '৳$requestedAmount',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.green,
                                        fontSize: 16)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Method row
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                    text: 'Method: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87)),
                                TextSpan(
                                    text: method,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black87)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Sender Number row
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                    text: 'Sender Number: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87)),
                                TextSpan(
                                    text: senderNumber,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black87)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Account Number row (user phone)
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                    text: 'User Account Number: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87)),
                                TextSpan(
                                    text: accountNumber,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black87)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Buttons row at bottom
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text(
                                    'Confirm',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {
                                    _handleRequestAction(context, docId, userId,
                                        requestedAmount, true);
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.cancel_outlined),
                                  label: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {
                                    _handleRequestAction(context, docId, userId,
                                        requestedAmount, false);
                                  },
                                ),
                              ),
                            ],
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

  Future<void> _handleRequestAction(BuildContext context, String docId,
      String userId, dynamic requestedAmount, bool isConfirm) async {
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
      final mainBalanceStr = userDoc['main'] ?? '0';

      if (pin == userPin) {
        if (isConfirm) {
          double currentBalance = double.tryParse(mainBalanceStr) ?? 0.0;
          double amountToAdd;

          if (requestedAmount is String) {
            amountToAdd = double.tryParse(requestedAmount) ?? 0.0;
          } else if (requestedAmount is int) {
            amountToAdd = requestedAmount.toDouble();
          } else if (requestedAmount is double) {
            amountToAdd = requestedAmount;
          } else {
            amountToAdd = 0.0;
          }

          double updatedBalance = currentBalance + amountToAdd;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'main': updatedBalance.toStringAsFixed(2),
          });
        }

        await FirebaseFirestore.instance
            .collection('addMoneyRequests')
            .doc(docId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isConfirm
                ? "Request approved and balance updated"
                : "Request cancelled"),
          ),
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
      title: const Text('Enter PIN to Confirm'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'PIN',
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
      contentPadding: const EdgeInsets.all(20),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}
