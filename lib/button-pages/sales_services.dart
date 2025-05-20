// sales_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesService {
  static Future<void> recordSale({
    required String collectionName,
    required String docId,
    required String type,
    required Map<String, dynamic> requestData,
    required double amount,
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
  }) async {
    final saleData = {
      'saleId': docId,
      'collectionSource': collectionName,
      'type': type,
      'amount': amount,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'completed',
      'details': requestData,
    };

    await FirebaseFirestore.instance
        .collection('TotalSales')
        .doc(docId)
        .set(saleData);
  }
}
