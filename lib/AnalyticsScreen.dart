import 'package:flutter/material.dart';
import 'Models/dbservicesModel.dart';
import 'dbServices.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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
        title: const Text('Analytics'),
        backgroundColor: Colors.cyan.shade400,
        elevation: 0,
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _expenseStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No expense data to analyze.'));
          } else {
            final expenses = snapshot.data!;
            final double totalSpent = expenses
                .where((e) => e.type != 'Income')
                .map((e) => e.amount)
                .fold(0.0, (sum, amount) => sum + amount);
            final double totalIncome = expenses
                .where((e) => e.type == 'Income')
                .map((e) => e.amount)
                .fold(0.0, (sum, amount) => sum + amount);
            final double balance = totalIncome - totalSpent;

            final categoryNetTotals = <String, double>{};
            for (final expense in expenses) {
              final amount =
                  expense.type == 'Income' ? expense.amount : -expense.amount;
              categoryNetTotals.update(
                expense.category,
                (value) => value + amount,
                ifAbsent: () => amount,
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _summaryCard(
                          title: 'Spent',
                          amount: 'Rs ${totalSpent.toStringAsFixed(0)}',
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 12),
                        _summaryCard(
                          title: 'Income',
                          amount: 'Rs ${totalIncome.toStringAsFixed(0)}',
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _summaryCard(
                      title: 'Balance',
                      amount: 'Rs ${balance.toStringAsFixed(0)}',
                      color: Colors.blueAccent,
                      fullWidth: true,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Category Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...categoryNetTotals.entries.map((entry) {
                      final category = entry.key;
                      final netAmount = entry.value;

                      if (netAmount == 0) {
                        return const SizedBox.shrink();
                      }

                      final isNetIncome = netAmount > 0;

                      return _categoryTile(
                        icon: _getIconForCategory(category),
                        title: category,
                        amount:
                            '${isNetIncome ? '+' : '-'} Rs ${netAmount.abs().toStringAsFixed(0)}',
                        color: isNetIncome ? Colors.green : Colors.red,
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }
        },
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

  Widget _summaryCard({
    required String title,
    required String amount,
    required Color color,
    bool fullWidth = false,
  }) {
    return Expanded(
      flex: fullWidth ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryTile({
    required IconData icon,
    required String title,
    required String amount,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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
