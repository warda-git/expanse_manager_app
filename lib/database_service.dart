import 'package:flutter/foundation.dart' show kIsWeb;
import 'dbServices.dart'; // Your original sqflite service
import 'Models/dbservicesModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class DatabaseService {
  Future<void> addExpense(Expense expense);
  Future<List<Expense>> getExpenses();

  factory DatabaseService() {
    if (kIsWeb) {
      return _FirestoreService();
    } else {
      return _SqfliteService();
    }
  }
}

// Firestore implementation for web
class _FirestoreService implements DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addExpense(Expense expense) async {
    await _firestore.collection('expenses').add(expense.toMap());
  }

  @override
  Future<List<Expense>> getExpenses() async {
    final snapshot = await _firestore.collection('expenses').get();
    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.data(), doc.id))
        .toList();
  }
}

// Sqflite implementation for mobile
class _SqfliteService implements DatabaseService {
  @override
  Future<void> addExpense(Expense expense) async {
    await DBService.addExpense(expense);
  }

  @override
  Future<List<Expense>> getExpenses() async {
    return await DBService.getExpenses();
  }
}
