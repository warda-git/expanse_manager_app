class Expense {
  final String? id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type;
  final DateTime createdAt;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    required this.createdAt,
  });

  // Convert Expense object to a map for sqflite or Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(), // Convert DateTime to String
      'category': category,
      'type': type,
      'createdAt': createdAt.toIso8601String(), // Convert DateTime to String
    };
  }

  // Create an Expense object from a map (from sqflite)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id']?.toString(),
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']), // Parse String to DateTime
      category: map['category'],
      type: map['type'],
      createdAt: DateTime.parse(map['createdAt']), // Parse String to DateTime
    );
  }

  // Create an Expense object from a Firestore document
  factory Expense.fromFirestore(Map<String, dynamic> firestore, String id) {
    return Expense(
      id: id,
      title: firestore['title'],
      amount: firestore['amount'],
      date: DateTime.parse(firestore['date']), // Parse String to DateTime
      category: firestore['category'],
      type: firestore['type'],
      createdAt: DateTime.parse(firestore['createdAt']), // Parse String to DateTime
    );
  }
}
