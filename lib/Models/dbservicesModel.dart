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

  // Converts the Expense object to a Map for database storage.
  // Note: Both sqflite and Firestore can handle this same map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(), // Always store dates as text
      'category': category,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Creates an Expense object from a database map.
  // This works for both sqflite and Firestore.
  factory Expense.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return Expense(
      id: (map['id'] ?? documentId)?.toString(),
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']), // Always parse text back to DateTime
      category: map['category'],
      type: map['type'],
      createdAt: DateTime.parse(map['createdAt']), 
    );
  }
}
