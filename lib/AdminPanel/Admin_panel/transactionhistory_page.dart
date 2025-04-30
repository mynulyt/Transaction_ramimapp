import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTransactionCard(
            context,
            name: "John Doe",
            amount: "+\$500.00",
            date: "Today, 10:30 AM",
            type: "Money Received",
            isPositive: true,
          ),
          _buildTransactionCard(
            context,
            name: "Amazon Purchase",
            amount: "-\$120.50",
            date: "Yesterday, 2:15 PM",
            type: "Shopping",
            isPositive: false,
          ),
          _buildTransactionCard(
            context,
            name: "Sarah Smith",
            amount: "+\$200.00",
            date: "Mar 15, 9:45 AM",
            type: "Payment Received",
            isPositive: true,
          ),
          _buildTransactionCard(
            context,
            name: "Electric Bill",
            amount: "-\$85.75",
            date: "Mar 12, 11:20 AM",
            type: "Utility Payment",
            isPositive: false,
          ),
          _buildTransactionCard(
            context,
            name: "Mike Johnson",
            amount: "+\$350.00",
            date: "Mar 10, 4:30 PM",
            type: "Invoice Payment",
            isPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context, {
    required String name,
    required String amount,
    required String date,
    required String type,
    required bool isPositive,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}