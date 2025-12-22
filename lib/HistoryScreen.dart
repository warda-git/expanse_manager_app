import 'package:flutter/material.dart';
import 'Models/dbservicesModel.dart';
import 'dbServices.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Stream<List<Expense>> _expenseStream;

  @override
  void initState() {
    super.initState();
    _expenseStream = DBService.expenseStream;
    DBService.fetchExpenses(); // Initial fetch
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan.shade50,
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.blue.shade400,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Expense>>(
                stream: _expenseStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No history found.'));
                  } else {
                    final expenses = snapshot.data!;
                    return ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        final isIncome = expense.type == 'Income';
                        return _HistoryTile(
                          title: expense.title,
                          subtitle: expense.category,
                          amount:
                              '${isIncome ? '+' : '-'} Rs ${expense.amount.toStringAsFixed(0)}',
                          date: expense.date.toLocal().toString().split(' ')[0],
                          color: isIncome ? Colors.green : Colors.red,
                          icon: _getIconForCategory(expense.category),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'medical':
        return Icons.local_hospital;
      case 'shopping':
        return Icons.shopping_bag;
      case 'rent':
        return Icons.home;
      case 'income':
        return Icons.arrow_upward;
      case 'internet':
        return Icons.wifi;
      default:
        return Icons.category;
    }
  }
}

// ===== History Tile Widget =====
class _HistoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final String date;
  final Color color;
  final IconData icon;

  const _HistoryTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$subtitle • $date',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
