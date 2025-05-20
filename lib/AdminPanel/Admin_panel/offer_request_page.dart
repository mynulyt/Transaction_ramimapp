import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramimapp/button-pages/sales_services.dart';

class RegularBuyRequestPage extends StatelessWidget {
  const RegularBuyRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          if (docs.isEmpty) {
            return const Center(child: Text('No regular buy requests found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
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
                  const SizedBox(width: 12),
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

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        '$title: $value',
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.5),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
