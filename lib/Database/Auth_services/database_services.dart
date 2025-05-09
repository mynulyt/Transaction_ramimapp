// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference offersCollection =
      FirebaseFirestore.instance.collection('offers');

  Future<void> submitOffer(Map<String, dynamic> offerData) async {
    try {
      await offersCollection.add(offerData);
    } catch (e) {
      throw Exception('Failed to submit offer: $e');
    }
  }
}
