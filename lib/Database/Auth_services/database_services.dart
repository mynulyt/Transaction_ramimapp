// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference offersCollection =
      FirebaseFirestore.instance.collection('offers');

  Future<void> submitOffer(Map<String, dynamic> offerData) async {
    try {
      // Debug line to ensure operator value
      print("Submitting Offer with Operator: ${offerData['operator']}");
      await offersCollection.add(offerData);
    } catch (e) {
      throw Exception('Failed to submit offer: $e');
    }
  }

  Future<List<Map<String, String>>> fetchUniqueOperators() async {
    // Dummy data or real Firebase Firestore call
    return [
      {'name': 'Grameenphone', 'image': 'assets/images/gp.png'},
      {'name': 'Robi', 'image': 'assets/images/robi.png'},
      {'name': 'Banglalink', 'image': 'assets/images/banglalink.png'},
    ];
  }

  Future<List<String>> fetchOperatorNames() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('operators').get();
    return snapshot.docs.map((doc) => doc['name'].toString()).toList();
  }

  Future<List<String>> getOperators() async {
    try {
      final snapshot = await offersCollection.get();
      final operators = snapshot.docs
          .map((doc) => doc['operator'] as String)
          .toSet()
          .toList();
      return operators;
    } catch (e) {
      throw Exception('Failed to fetch operators: $e');
    }
  }

  Future<void> deleteOffer(String docId) async {
    try {
      await offersCollection.doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete offer: $e');
    }
  }
}
