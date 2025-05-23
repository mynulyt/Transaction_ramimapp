import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ramimapp/button-pages/sales_services.dart';

class RegularBuyRequestPage extends StatefulWidget {
  const RegularBuyRequestPage({super.key});

  @override
  State<RegularBuyRequestPage> createState() => _RegularBuyRequestPageState();
}

class _RegularBuyRequestPageState extends State<RegularBuyRequestPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String currentUserId;
  late String currentUserEmail;

  @override
  void initState() {
    super.initState();
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      currentUserId = currentUser.uid;
      currentUserEmail = currentUser.email ?? '';
    } else {
      currentUserId = '';
      currentUserEmail = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId.isEmpty && currentUserEmail.isEmpty) {
      // No logged-in user, show message
      return Scaffold(
        appBar: AppBar(
          title: const Text('Regular Offer Buy Requests'),
          centerTitle: true,
          backgroundColor: Colors.blue[800],
        ),
        body: const Center(
          child: Text('You need to be logged in to see your requests.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regular Offer Buy Requests'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .doc('regular_buy_requests')
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // Filter docs where uid or userEmail matches current user
          final filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final uid = data['uid']?.toString() ?? '';
            final email = data['userEmail']?.toString() ?? '';
            return uid == currentUserId || email == currentUserEmail;
          }).toList();

          if (filteredDocs.isEmpty) {
            return const Center(
                child: Text('No regular buy requests found for you.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final data = filteredDocs[index].data() as Map<String, dynamic>;
              final docId = filteredDocs[index].id;
              return _buildRequestCard(context, docId, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(
      BuildContext context, String docId, Map<String, dynamic> data) {
    final operator = data['operator'] ?? 'Unknown';
    final priceStr = data['price']?.toString() ?? '0';
    final name = data['userName'] ?? 'N/A';
    final internet = data['internet'] ?? 'N/A';
    final minutes = data['minutes'] ?? 'N/A';
    final sms = data['sms'] ?? 'N/A';
    final term = data['term'] ?? 'N/A';
    final offerType = data['offerType'] ?? 'N/A';
    final number = data['rechargeNumber'] ?? 'N/A';
    final email = data['userEmail'] ?? '';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$operator Offer',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Internet', internet),
              _buildInfoRow('Minutes', minutes),
              _buildInfoRow('SMS', sms),
              _buildInfoRow('Price', '$priceStr ৳'),
              _buildInfoRow('Name', name),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recharge Number: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: SelectableText(
                        number,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildInfoRow('Email', email),
              _buildInfoRow('Term', term),
              _buildInfoRow('Offer Type', offerType),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Accept',
                      Colors.green[100]!,
                      () => _handleAccept(
                          context,
                          docId,
                          data,
                          priceStr,
                          name,
                          operator,
                          internet,
                          minutes,
                          sms,
                          term,
                          offerType,
                          number,
                          email),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      'Edit',
                      Colors.blue[100]!,
                      () => _showUpdateDialog(context, docId, data),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      'Cancel',
                      Colors.red[100]!,
                      () => _handleCancel(context, docId),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAccept(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
    String priceStr,
    String name,
    String operator,
    String internet,
    String minutes,
    String sms,
    String term,
    String offerType,
    String number,
    String email,
  ) async {
    try {
      final requestedAmount = double.tryParse(priceStr) ?? 0.0;
      final uid = data['uid']?.toString();

      DocumentSnapshot userDoc;
      if (uid != null && uid.isNotEmpty) {
        userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
      } else {
        // try email lookup
        final emailQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        if (emailQuery.docs.isNotEmpty) {
          userDoc = emailQuery.docs.first;
        } else {
          // try phone lookup
          final phoneQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('phone', isEqualTo: number)
              .limit(1)
              .get();
          if (phoneQuery.docs.isNotEmpty) {
            userDoc = phoneQuery.docs.first;
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('User not found.')));
            return;
          }
        }
      }

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('User not found.')));
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentBalance =
          double.tryParse(userData['main']?.toString() ?? '0') ?? 0.0;

      if (currentBalance < requestedAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insufficient balance.')));
        return;
      }

      final newBalance = currentBalance - requestedAmount;

      // Update user balance
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userDoc.id)
          .update({'main': newBalance.toStringAsFixed(2)});

      // Add transaction history
      await FirebaseFirestore.instance.collection('TransactionHistory').add({
        'uid': userDoc.id,
        'userName': name,
        'operator': operator,
        'price': requestedAmount,
        'rechargeNumber': number,
        'email': email,
        'offerType': offerType,
        'term': term,
        'internet': internet,
        'minutes': minutes,
        'sms': sms,
        'timestamp': FieldValue.serverTimestamp(),
        'action': 'buy_offer_accepted',
      });

      // Record in Total Sales
      await SalesService.recordSale(
        collectionName: 'regular_buy_requests',
        docId: docId,
        type: 'regular_offer',
        requestData: data,
        amount: requestedAmount,
        userId: userDoc.id,
        userName: name,
        userEmail: email,
        userPhone: number,
      );

      // Delete the request
      await FirebaseFirestore.instance
          .collection('requests')
          .doc('regular_buy_requests')
          .collection('items')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer recorded in sales')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _handleCancel(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc('regular_buy_requests')
        .collection('items')
        .doc(docId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offer cancelled.')),
    );
  }

  // New method: Show dialog to update price (or other fields)
  void _showUpdateDialog(
      BuildContext context, String docId, Map<String, dynamic> data) {
    final TextEditingController priceController =
        TextEditingController(text: data['price']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Price'),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'New Price'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPrice = priceController.text.trim();
                if (newPrice.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Price cannot be empty')),
                  );
                  return;
                }
                final priceNum = double.tryParse(newPrice);
                if (priceNum == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid price value')),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('requests')
                      .doc('regular_buy_requests')
                      .collection('items')
                      .doc(docId)
                      .update({'price': priceNum.toStringAsFixed(2)});
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Price updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Update failed: $e')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
