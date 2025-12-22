import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Models/dbservicesModel.dart';

class DBService {
  static Database? _db;

  // Stream controller to broadcast database changes
  static final _expenseStreamController = StreamController<List<Expense>>.broadcast();

  // Public stream for widgets to listen to
  static Stream<List<Expense>> get expenseStream => _expenseStreamController.stream;

  static Future<Database> getDb() async {
    if (_db != null) return _db!;

    String path = join(await getDatabasesPath(), 'expense_manager.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            category TEXT NOT NULL,
            type TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
    // Initial data fetch
    fetchExpenses();
    return _db!;
  }

  // Fetches all expenses and adds them to the stream
  static Future<void> fetchExpenses() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query('expenses', orderBy: 'createdAt DESC');
    final expenses = List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
    _expenseStreamController.add(expenses);
  }

  static Future<void> addExpense(Expense expense) async {
    final db = await getDb();
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // After adding, refetch and notify listeners
    await fetchExpenses();
  }

  static Future<List<Expense>> getExpenses() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query('expenses', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Call this to close the stream when the app is disposed
  static void dispose() {
    _expenseStreamController.close();
  }
}
