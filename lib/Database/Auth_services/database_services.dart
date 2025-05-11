// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  Future<void> submitOffer(Map<String, dynamic> offerData) async {
    try {
      final operator = offerData['operator']; // e.g., "Robi"
      await FirebaseFirestore.instance
          .collection('operators')
          .doc(operator)
          .collection('regular')
          .add({
        'internet': offerData['internet'].toString(),
        'minutes': offerData['minutes'].toString(),
        'sms': offerData['sms'].toString(),
        'term': offerData['term'].toString(),
        'price': offerData['price'].toString(),
        'operator': operator.toString(),
        'offerType': offerData['offerType'].toString(),
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to submit offer: $e');
    }
  }

  Future<List<Map<String, String>>> fetchUniqueOperators() async {
    // Optional for UI
    return [
      {'name': 'Grameenphone', 'image': 'assets/images/gp.png'},
      {'name': 'Robi', 'image': 'assets/images/robi.png'},
      {'name': 'Banglalink', 'image': 'assets/images/banglalink.png'},
      {'name': 'Teletalk', 'image': 'assets/images/teletalk.png'},
    ];
  }

  Future<List<String>> fetchOperatorNames() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('operators').get();
    return snapshot.docs.map((doc) => doc.id.toString()).toList();
  }

  Future<List<String>> getOperators() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('operators').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Failed to fetch operators: $e');
    }
  }

  Future<void> deleteOffer(String operator, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('operators')
          .doc(operator)
          .collection('regular')
          .doc(docId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete offer: $e');
    }
  }
}
