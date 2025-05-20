// Add this in your sales_services.dart or create a new service file
import 'package:cloud_firestore/cloud_firestore.dart';

class CashService {
  static Future<void> updateTotalCash() async {
    try {
      // Get all users' balances
      final usersQuery =
          await FirebaseFirestore.instance.collection('users').get();

      double totalCash = 0;

      for (final doc in usersQuery.docs) {
        final userData = doc.data();
        final balance =
            double.tryParse(userData['main']?.toString() ?? '0') ?? 0;
        totalCash += balance;
      }

      // Store in TotalCash collection
      await FirebaseFirestore.instance
          .collection('TotalCash')
          .doc('total_amount')
          .set({
        'amount': totalCash,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating total cash: $e');
    }
  }

  static Future<double> getTotalCash() async {
    final doc = await FirebaseFirestore.instance
        .collection('TotalCash')
        .doc('total_amount')
        .get();

    return (doc.data()?['amount'] as num?)?.toDouble() ?? 0;
  }
}
