import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'addExpenseScreen.dart'; // Navigation target
import 'HistoryScreen.dart'; // Navigation target
import 'AnalyticsScreen.dart'; // Navigation target
import 'database_service.dart';
import 'Models/dbservicesModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Expense>> _expenseFuture;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    setState(() {
      _expenseFuture = DatabaseService().getExpenses();
    });
  }

  void _onAddExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
    _loadExpenses(); // Refresh after adding
  }

  void _onHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  void _onAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.teal.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSummaryCard(),
                const SizedBox(height: 25),
                _buildActionButtons(),
                const SizedBox(height: 25),
                _buildRecentExpenses(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'SpendWise',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.teal,
          child: Icon(Icons.pie_chart, color: Colors.white, size: 28),
        )
      ],
    );
  }

  Widget _buildSummaryCard() {
    return FutureBuilder<List<Expense>>(
      future: _expenseFuture,
      builder: (context, snapshot) {
        double totalSpent = 0;
        if (snapshot.hasData) {
          totalSpent = snapshot.data!
              .where((e) => e.type == 'Expense')
              .fold(0, (sum, item) => sum + item.amount);
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hello, User 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 8),
                  Text('You spent ₨ ${totalSpent.toStringAsFixed(0)} this week', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
              const Icon(Icons.trending_up, color: Colors.teal, size: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionButton(context, Icons.add, 'Add Expense', Colors.teal.shade400, (ctx) => _onAddExpense()),
        _actionButton(context, Icons.history, 'History', Colors.blue.shade400, (ctx) => _onHistory()),
        _actionButton(context, Icons.bar_chart, 'Analytics', Colors.cyan.shade400, (ctx) => _onAnalytics()),
      ],
    );
  }

  Widget _buildRecentExpenses() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Expenses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Expense>>(
              future: _expenseFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No expenses yet. Add one!', style: TextStyle(color: Colors.grey)));
                }

                final expenses = snapshot.data!;
                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return _expenseTile(expense);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, Color color, Function(BuildContext) onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expenseTile(Expense expense) {
    final isIncome = expense.type == 'Income';
    final color = isIncome ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(Icons.circle, color: color, size: 12),
              ),
              const SizedBox(width: 10),
              Text(expense.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          Text('${isIncome ? '+' : '-'}₨ ${expense.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ],
      ),
    );
  }
}
