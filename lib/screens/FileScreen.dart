import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  FilterScreen({required this.transactions});

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? selectedCategory;
  List<Map<String, dynamic>> filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    filteredTransactions = widget.transactions;
  }

  void filterTransactions() {
    if (selectedCategory != null) {
      setState(() {
        filteredTransactions = widget.transactions
            .where((t) => t['category'] == selectedCategory)
            .toList();
      });
    } else {
      setState(() {
        filteredTransactions = widget.transactions;
      });
    }
  }

  // Helper method to get all unique categories from transactions
  List<String> getAvailableCategories() {
    final categories = widget.transactions
        .where((t) => t['category'] != null) // Filter out null categories
        .map((t) => t['category'].toString()) // Convert to string
        .toSet() // Remove duplicates
        .toList(); // Convert back to list

    // Sort alphabetically for better UX
    categories.sort();
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = getAvailableCategories();

    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Transactions'),
        actions: [
          if (selectedCategory != null)
            TextButton(
              onPressed: () {
                setState(() {
                  selectedCategory = null;
                  filteredTransactions = widget.transactions;
                });
              },
              child: Text(
                'Clear',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: Text("Select Category"),
              items: availableCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: filterTransactions,
            child: Text("Apply Filter"),
          ),
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
              child: Text(
                selectedCategory == null
                    ? "No transactions available"
                    : "No transactions in this category",
              ),
            )
                : ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                      vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.money,
                      color: transaction['type'] == 'Expense'
                          ? Colors.red
                          : Colors.green,
                    ),
                    title: Text(
                        transaction['title'] ?? 'No description'),
                    subtitle: Text(transaction['date'] ?? 'No date'),
                    trailing: Text(
                      transaction['type'] == 'Expense'
                          ? "- ₹${transaction['amount']}"
                          : "+ ₹${transaction['amount']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: transaction['type'] == 'Expense'
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}