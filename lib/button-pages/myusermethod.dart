import 'package:flutter/material.dart';

class MyUserMethod extends StatefulWidget {
  const MyUserMethod({super.key});

  @override
  _MyUserMethodState createState() => _MyUserMethodState();
}

class _MyUserMethodState extends State<MyUserMethod> {
  bool _isCardVisible = false; // This will control the visibility of the card

  void _toggleCardVisibility() {
    setState(() {
      _isCardVisible = !_isCardVisible; // Toggle the card visibility
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text(''),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: Icon(Icons.search, color: Colors.green),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person, color: Colors.green, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'জেসমিন',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text('01963696783',
                          style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 4),
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('VIP'),
                          Spacer(),
                          Text('Active', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          const Text('Last login: 01-01-1970 6:00 AM'),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_down),
                            color: Colors.black54,
                            onPressed:
                                _toggleCardVisibility, // Call toggle function on click
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isCardVisible) // Only show the card if it's visible
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('sanjidllc466@gmail.com',
                            style: TextStyle(color: Colors.red)),
                        const Text('Created: 22-04-2025 12:19 PM',
                            style: TextStyle(color: Colors.green)),
                        const SizedBox(height: 8),
                        ...[
                          'Main: ৳0.00',
                          'Drive: ৳0.00',
                          'Bank: ৳0.00',
                          'Shop: ৳0.00',
                          'Due: ৳0.00',
                          'Advance: ৳0.00',
                        ].map((e) => Text(e)),
                        const SizedBox(height: 8),
                        const Text(
                          'খুলনা,মেহেদিবাগ,সুবিশালহাস,ghfh,chgc',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Payment',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Edit',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
