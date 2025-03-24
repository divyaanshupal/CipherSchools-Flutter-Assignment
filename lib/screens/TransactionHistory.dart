import 'package:flutter/material.dart';
import 'package:tracker/database/DatabaseHelper.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    final db = DatabaseHelper.instance;
    final data = await db.fetchTransactions();
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transaction History", style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100], // Light background for contrast
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
          ? Center(
        child: Text(
          "No transactions found.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: _transactions.length,
          itemBuilder: (context, index) {
            final transaction = _transactions[index];
            return _buildTransactionCard(
              transaction['category'] ?? 'Income',
              transaction['description'] ?? 'No description',
              transaction['amount'].toStringAsFixed(2),
              _getIconPath(transaction['category']),
              transaction['type'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionCard(String title, String subtitle, String amount, String iconPath, String type) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3, // Subtle shadow
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: type == 'Expense' ? Colors.redAccent.withOpacity(0.2) : Colors.greenAccent.withOpacity(0.2),
          child: Image.asset(iconPath, height: 30), // Category icon
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: Text(
          type == 'Expense' ? "- ₹${amount}" : "+ ₹${amount}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: type == 'Expense' ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }

  String _getIconPath(String? category) {
    switch (category?.toLowerCase()) {
      case 'food':
        return "assets/food.png";
      case 'shopping':
        return "assets/shopping.png";
      case 'bills':
        return "assets/subscription.png";
      case 'travel':
        return "assets/travel.png";
      case 'subscription':
        return "assets/subscription.png";
      default:
        return "assets/income.jpg"; // Default icon for income or unknown categories
    }
  }
}
