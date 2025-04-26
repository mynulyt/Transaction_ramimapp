import 'package:flutter/material.dart';

class RegularofferPage extends StatefulWidget {
  const RegularofferPage({super.key, required this.operatorName});

  final String operatorName;

  @override
  State<RegularofferPage> createState() => _RegularofferPageState();
}

class _RegularofferPageState extends State<RegularofferPage> {
  String selectedCategory = 'All';
  String searchQuery = '';

  List<Map<String, dynamic>> packages = [
    {
      'title': '60GB + 1500MIN (30 Days)',
      'price': 999,
      'type': 'Bundles',
    },
    {
      'title': '120GB Internet (30 Days)',
      'price': 798,
      'type': 'Internet',
    },
    {
      'title': '5GB Internet (30 Days)',
      'price': 298,
      'type': 'Internet',
    },
    {
      'title': '10GB Internet (30 Days)',
      'price': 397,
      'type': 'Internet',
    },
    {
      'title': '20GB Internet (30 Days)',
      'price': 497,
      'type': 'Internet',
    },
    {
      'title': '100 Minutes (7 Days)',
      'price': 99,
      'type': 'Minutes',
    },
    {
      'title': 'Super Call Rate (30 Days)',
      'price': 59,
      'type': 'Call Rate',
    },
    {
      'title': 'SMS Pack 500 (30 Days)',
      'price': 49,
      'type': 'SMS',
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredPackages = packages.where((pkg) {
      bool matchCategory =
          selectedCategory == 'All' || pkg['type'] == selectedCategory;
      bool matchSearch =
          pkg['title'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(widget.operatorName,
            style: const TextStyle(color: Colors.white)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          backgroundImage: AssetImage('images/robi.png'),
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
                            hintStyle: TextStyle(fontSize: 16),
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: filteredPackages.isEmpty
          ? const Center(child: Text('No packages found'))
          : SingleChildScrollView(
              child: Column(
                children: filteredPackages.map((pkg) {
                  return buildPackageItem(
                    title: pkg['title'],
                    price: pkg['price'],
                    type: pkg['type'],
                  );
                }).toList(),
              ),
            ),
    );
  }

  // Build each category button
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

  // Build package item card
  Widget buildPackageItem({
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  showBuyConfirmationDialog(title, price);
                },
                child: const Text('Buy',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show confirmation dialog when Buy button pressed
  void showBuyConfirmationDialog(String title, int price) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Text('Do you want to buy "$title" for $price BDT?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Successfully purchased "$title"!')),
                );
              },
              child: const Text(
                'Buy',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        );
      },
    );
  }
}
