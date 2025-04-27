import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker/database/DatabaseHelper.dart';

class AddTransactionScreen extends StatefulWidget {
  final Function  onTransactionAdded; // Callback function
  AddTransactionScreen({required this.onTransactionAdded});
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String selectedTransactionType = "Expense";
  String? selectedCategory;
  String? selectedWallet;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Add Transaction", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "How much?",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          SizedBox(height: 10),

          // 🔥 Amount Input Field
          Container(
            width: 200,
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,     //keyboard of only digits
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],       //only allow the digits to get input
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "₹0",
                hintStyle: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ),
          ),

          SizedBox(height: 20),

          // 🔥 White Container for Fields
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // 🔥 Transaction Type Dropdown
                  _buildDropdown("Transaction Type", ["Expense", "Income"], selectedTransactionType, (value) {
                    setState(() {
                      selectedTransactionType = value!;
                      selectedCategory = null;
                      selectedWallet = null;
                    });
                  }),

                  SizedBox(height: 10),

                  // 🔥 Show Category & Wallet only if "Expense" is selected
                  if (selectedTransactionType == "Expense") ...[
                    _buildDropdown("Category", ["Food", "Shopping", "Bills"], selectedCategory, (value) {
                      setState(() => selectedCategory = value);
                    }),
                    SizedBox(height: 10),
                  ],

                  // 🔥 Description Field
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                  ),

                  SizedBox(height: 10),

                  if (selectedTransactionType == "Expense") ...[        //... is known as spead operator , if true then will insert other many widgets inside the widget tree
                    _buildDropdown("Wallet", ["Cash", "Bank", "Credit Card"], selectedWallet, (value) {
                      setState(() => selectedWallet = value);
                    }),
                    SizedBox(height: 10),
                  ],

                  Spacer(),

                  // 🔥 Continue Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _saveTransaction,
                    child: Text("Continue", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Function to Save Transaction
  void _saveTransaction() async {
    final db = DatabaseHelper.instance;

    // Validate input
    if (_amountController.text.isEmpty) {
      _showSnackbar("Amount cannot be empty");
      return;
    }

    double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      _showSnackbar("Enter a valid amount");
      return;
    }

    if (selectedTransactionType == "Expense" && (selectedCategory == null || selectedWallet == null)) {
      _showSnackbar("Please select a category and wallet");
      return;
    }

    try {
      double currentBalance = await db.getBalance();

      if (selectedTransactionType == "Income") {
        currentBalance += amount;
      } else {
        if (amount > currentBalance) {
          _showSnackbar("Insufficient balance");
          return;
        }
        currentBalance -= amount;
      }

      Map<String, dynamic> newTransaction = {
        'title': _descriptionController.text,
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'type': selectedTransactionType, // Ensure this is either "Income" or "Expense"
        'category': selectedTransactionType == 'Income' ? null : selectedCategory,
        'wallet': selectedTransactionType == 'Income' ? null : selectedWallet,
        'description': _descriptionController.text,
      };
      print("🔹 Saving Transaction: $newTransaction");

      await db.insertTransaction(newTransaction);
      widget.onTransactionAdded();
      await db.updateBalance(currentBalance);

       // Call the callback to notify HomeScreen

      Navigator.pop(context); // Go back to the home screen
    } catch (e) {
      _showSnackbar("Error saving transaction: ${e.toString()}");
    }
  }

  // 🔥 Function to Build Dropdown
  Widget _buildDropdown(String hint, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(border: OutlineInputBorder(), labelText: hint),
      value: selectedValue,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // 🔥 Function to Show Snackbar Messages
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
