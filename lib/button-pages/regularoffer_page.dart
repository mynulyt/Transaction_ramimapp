import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegularofferBuyPage extends StatefulWidget {
  final String operatorName;
  final String operatorImagePath;

  const RegularofferBuyPage({
    super.key,
    required this.operatorName,
    required this.operatorImagePath,
  });

  @override
  State<RegularofferBuyPage> createState() => _RegularofferBuyPageState();
}

class _RegularofferBuyPageState extends State<RegularofferBuyPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedCategory = 'All';
  String searchQuery = '';

  String _getOperatorCode(String name) {
    switch (name.toLowerCase()) {
      case 'banglalink':
        return 'BLK';
      case 'teletalk':
        return 'TLK';
      case 'grameenphone':
        return 'GP';
      case 'robi':
        return 'Robi';
      case 'airtel':
        return 'Airtel';
      default:
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final operatorCode = _getOperatorCode(widget.operatorName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(widget.operatorName,
            style: const TextStyle(color: Colors.white)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: CircleAvatar(
                          backgroundImage: AssetImage(widget.operatorImagePath),
                          radius: 18,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            suffixIcon: Icon(Icons.search, color: Colors.green),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      categoryButton('All'),
                      categoryButton('Minutes'),
                      categoryButton('Internet'),
                      categoryButton('Bundles'),
                      categoryButton('Call Rate'),
                      categoryButton('SMS'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('operators')
            .doc(operatorCode)
            .collection('regular')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Regular Offers Found"));
          }

          final offers = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final title = data['offerType']?.toString() ?? '';
            final type = _getType(data);
            return (selectedCategory == 'All' || selectedCategory == type) &&
                title.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          if (offers.isEmpty) {
            return const Center(child: Text("No packages found"));
          }

          return ListView.builder(
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final data = offers[index].data() as Map<String, dynamic>;
              final docId = offers[index].id;
              return buildPackageCard(data, docId, operatorCode);
            },
          );
        },
      ),
    );
  }

  String _getType(Map<String, dynamic> data) {
    final internet = (data['internet'] ?? '').toString();
    final minutes = (data['minutes'] ?? '').toString();
    final sms = (data['sms'] ?? '').toString();
    final callRate = (data['callRate'] ?? '').toString();

    if (internet.isNotEmpty && minutes.isNotEmpty) return 'Bundles';
    if (internet.isNotEmpty) return 'Internet';
    if (minutes.isNotEmpty) return 'Minutes';
    if (sms.isNotEmpty) return 'SMS';
    if (callRate.isNotEmpty) return 'Call Rate';

    return 'Others';
  }

  Widget categoryButton(String text) {
    bool isSelected = selectedCategory == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.white : Colors.green.shade700,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.green.shade700 : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget buildPackageCard(
      Map<String, dynamic> data, String docId, String operatorCode) {
    String submittedAt = 'N/A';
    if (data['submittedAt'] != null && data['submittedAt'] is Timestamp) {
      final dateTime = (data['submittedAt'] as Timestamp).toDate();
      submittedAt =
          "${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['offerType'] ?? 'No Title',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['price'] != null
                      ? '${data['price']} BDT'
                      : 'Price not available',
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
                Text(_getType(data),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _buildDetailChip("Internet", data['internet']),
                _buildDetailChip("Minutes", data['minutes']),
                _buildDetailChip("SMS", data['sms']),
                _buildDetailChip("Call Rate", data['callRate']),
                _buildDetailChip("Validity", data['validity']),
                _buildDetailChip("Terms", data['term']),
                _buildDetailChip("Submitted", submittedAt),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () => _showPinDialog(data),
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: const Text('Buy',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade400),
      ),
      child: Text(
        "$label: ${value.toString()}",
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  void _showPinDialog(Map<String, dynamic> offerData) {
    final TextEditingController pinController = TextEditingController();
    final TextEditingController numberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Recharge Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Enter recharge number',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter your PIN',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final enteredPin = pinController.text.trim();
              final rechargeNumber = numberController.text.trim();

              if (rechargeNumber.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter a recharge number')),
                );
                return;
              }

              final currentUserId = FirebaseAuth.instance.currentUser?.uid;

              if (currentUserId != null) {
                final userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUserId)
                    .get();

                final savedPin = userDoc.data()?['pin'];
                final userName = userDoc.data()?['name'] ?? 'Unknown';
                final userEmail = userDoc.data()?['email'] ?? 'Unknown';

                if (enteredPin == savedPin) {
                  await FirebaseFirestore.instance
                      .collection('requests')
                      .doc('regular_buy_requests')
                      .collection('items')
                      .add({
                    ...offerData,
                    'requestedAt': Timestamp.now(),
                    'userId': currentUserId,
                    'rechargeNumber': rechargeNumber,
                    'userName': userName,
                    'userEmail': userEmail,
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request sent successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid PIN')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User not authenticated')),
                );
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
