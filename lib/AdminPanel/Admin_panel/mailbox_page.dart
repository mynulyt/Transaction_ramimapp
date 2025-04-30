import 'package:flutter/material.dart';
import 'package:ramimapp/AdminPanel/Admin_panel/money_request_page.dart';
import 'package:ramimapp/AdminPanel/Admin_panel/offer_request_page.dart';
import 'package:ramimapp/AdminPanel/Admin_panel/rechagerequest_page.dart';

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
        child: Container(
          height: 300,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMailboxButton(
                    context, 'Money Request', const Color(0xFFB2DFDB)),
                const SizedBox(height: 12),
                _buildMailboxButton(
                    context, 'Recharge Request', const Color(0xFFD7CCC8)),
                const SizedBox(height: 12),
                _buildMailboxButton(
                    context, 'Offer Request', const Color(0xFFE0E0E0)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMailboxButton(BuildContext context, String title, Color color) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            if (title == 'Money Request') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MoneyRequestPage()),
              );
            }
            if (title == 'Recharge Request') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RechargeRequestPage()),
              );
            }
            if (title == 'Offer Request') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OfferRequestPage()),
              );
            }
          },
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
