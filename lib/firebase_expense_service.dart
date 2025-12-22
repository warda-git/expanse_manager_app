import 'package:cloud_firestore/cloud_firestore.dart';
import 'Models/dbservicesModel.dart'; // Make sure the path is correct

class FirebaseExpenseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Static method to sync an expense to Firestore
  static Future<void> syncExpense(Expense expense) async {
    try {
      // Use the corrected toMap() method
      await _firestore.collection('expenses').add(expense.toMap());
    } catch (e) {
      throw Exception('Failed to sync expense to Firebase: $e');
    }
  }
}
