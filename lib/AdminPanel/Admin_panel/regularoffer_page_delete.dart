import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegularofferDeletePage extends StatefulWidget {
  final String operatorName; // <-- Add this
  const RegularofferDeletePage(
      {super.key,
      required this.operatorName,
      required String operatorImagePath});

  @override
  State<RegularofferDeletePage> createState() => _RegularofferDeletePageState();
}

class _RegularofferDeletePageState extends State<RegularofferDeletePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("${widget.operatorName} Regular Offers"),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('operators')
            .doc(widget.operatorName) // dynamic operator
            .collection('regular')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Regular Offers Found",
                  style: TextStyle(color: Colors.white)),
            );
          }

          final regularOffers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: regularOffers.length,
            itemBuilder: (context, index) {
              final offer = regularOffers[index];
              final data = offer.data() as Map<String, dynamic>;
              final docId = offer.id;

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['offerType'] ?? '',
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Internet: ${data['internet']}",
                          style: const TextStyle(color: Colors.white)),
                      Text("Minutes: ${data['minutes']}",
                          style: const TextStyle(color: Colors.white)),
                      Text("SMS: ${data['sms']}",
                          style: const TextStyle(color: Colors.white)),
                      Text("Term: ${data['term']}",
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteOffer(docId),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteOffer(String docId) async {
    try {
      await _firestore
          .collection('operators')
          .doc(widget.operatorName)
          .collection('regular')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer Deleted Successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting offer: $e')),
      );
    }
  }
}
