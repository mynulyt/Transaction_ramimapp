// lib/admin_panel/mailbox_page.dart
import 'package:flutter/material.dart';
import 'package:ramimapp/AdminPanel/Admin_panel/rechagerequest_page.dart';
import 'money_request_page.dart';
import 'offer_request_page.dart';

class MailboxPage extends StatelessWidget {
  const MailboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mail Box'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMailboxButton(context, 'Money Request',
                const Color(0xFFB2DFDB), const MoneyRequestPage()),
            const SizedBox(height: 12),
            _buildMailboxButton(context, 'Recharge Request',
                const Color(0xFFD7CCC8), RechargeRequestPage()),
            const SizedBox(height: 12),
            _buildMailboxButton(context, 'Offer Request',
                const Color(0xFFE0E0E0), const RegularBuyRequestPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildMailboxButton(
      BuildContext context, String title, Color color, Widget page) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
        ),
        child: ElevatedButton(
          onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }
}
