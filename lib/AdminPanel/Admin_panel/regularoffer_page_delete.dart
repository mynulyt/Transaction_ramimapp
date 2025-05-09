import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegularofferDeletePage extends StatefulWidget {
  final String operatorName;
  final String operatorImagePath;

  const RegularofferDeletePage({
    Key? key,
    required this.operatorName,
    required this.operatorImagePath,
  }) : super(key: key);

  @override
  _RegularofferDeletePageState createState() => _RegularofferDeletePageState();
}

class _RegularofferDeletePageState extends State<RegularofferDeletePage> {
  String selectedCategory = 'All';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.operatorName),
        backgroundColor: Colors.green.shade700,
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
                          backgroundColor: Colors.white,
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
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
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
                  scrollDirection: Axis.horizontal,
                  child: Row(
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
        stream: FirebaseFirestore.instance
            .collection('regular_offers')
            .where('operator', isEqualTo: widget.operatorName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No packages found'));
          }

          final filteredPackages = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final matchCategory =
                selectedCategory == 'All' || data['type'] == selectedCategory;
            final matchSearch =
                data['title'].toLowerCase().contains(searchQuery.toLowerCase());
            return matchCategory && matchSearch;
          }).toList();

          return ListView(
            children: filteredPackages.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return buildPackageItem(
                id: doc.id,
                title: data['title'],
                price: data['price'],
                type: data['type'],
              );
            }).toList(),
          );
        },
      ),
    );
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
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

  Widget buildPackageItem({
    required String id,
    required String title,
    required int price,
    required String type,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$price BDT',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold)),
                Text(type,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  confirmDelete(id, title);
                },
                child: const Text('Delete',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void confirmDelete(String id, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Do you want to delete "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseFirestore.instance
                    .collection('regular_offers')
                    .doc(id)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "$title" successfully')),
                );
              },
              child:
                  const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
