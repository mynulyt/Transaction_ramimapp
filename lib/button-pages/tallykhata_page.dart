import 'package:flutter/material.dart';
import 'package:ramimapp/widgets/drawer.dart';

class TallyKhataPage extends StatelessWidget {
  const TallyKhataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TallyKhataScreen();
  }
}

class TallyKhataScreen extends StatelessWidget {
  const TallyKhataScreen({super.key});

  Widget _buildStatItem(dynamic iconOrImage, String title, String value) {
    Widget iconWidget;

    if (iconOrImage is IconData) {
      iconWidget = Icon(iconOrImage, color: Colors.green);
    } else if (iconOrImage is String) {
      iconWidget = Image.asset(
        iconOrImage,
        width: 24,
        height: 24,
      );
    } else {
      iconWidget = const Icon(Icons.help_outline, color: Colors.red);
    }

    return Container(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(title),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Ramim Pay'),
        centerTitle: true,
      ),
      drawer: buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text(
                        'Account Balance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "৳0.00",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.green),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    children: [
                      _buildStatItem(
                          "images/received.png", 'Total Received', '৳0'),
                      _buildStatItem(
                          Icons.card_travel_outlined, 'Today\'s Sales', '৳0'),
                      _buildStatItem("images/iwg.png", 'I will give', '৳0'),
                      _buildStatItem(Icons.money, 'Total Cash', '৳0'),
                      _buildStatItem(Icons.receipt, 'Today\'s Receipts', '৳0'),
                      _buildStatItem(Icons.payment, 'Today\'s Payments', '৳0'),
                      _buildStatItem(
                          Icons.calendar_today, 'Due collection', '৳0'),
                      _buildStatItem(Icons.coffee, 'Today\'s Expenses', '৳0'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
