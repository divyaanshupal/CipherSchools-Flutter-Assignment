import 'package:flutter/material.dart';
import 'package:tracker/database/DatabaseHelper.dart';
import 'package:tracker/screens/FileScreen.dart';
import 'AddTransaction.dart';
import 'ProfileScreen.dart';
import 'TransactionHistory.dart';


class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _transactions = [];
  double _currentBalance = 0;
  double _totalIncome = 0; // Add this variable
  double _totalExpense = 0;
  bool _isLoading = true;

  void _loadBalance() async {
    final db = DatabaseHelper.instance;
    double balance = await db.getBalance();
    double income = await db.getIncome(); // Fetch income
    double expense = await db.getExpense(); // Fetch expense
    setState(() {
      _currentBalance = balance;
      _totalIncome = income;
      _totalExpense = expense;
      _isLoading = false; // Data has been loaded
    });
  }


  void _loadTransactions() async {
    final db = DatabaseHelper.instance;
    final data = await db.fetchTransactions();
    print("Fetched Transactions: $data"); // Debug print
    setState(() {
      _transactions = data;
    });
  }





  double _calculateTotalIncome(List<Map<String, dynamic>> transactions) {
    return transactions
        .where((transaction) => transaction['type'] == 'Income')
        .fold(0.0, (sum, transaction) => sum + (transaction['amount'] as double));
  }

  double _calculateTotalExpenses(List<Map<String, dynamic>> transactions) {
    return transactions
        .where((transaction) => transaction['type'] == 'Expense')
        .fold(0.0, (sum, transaction) => sum + (transaction['amount'] as double));
  }

  Future<double> getIncome() async {
    final db = DatabaseHelper.instance; // Access the DatabaseHelper instance
    final database = await db.database; // Access the database property
    List<Map<String, dynamic>> result = await database.query("balance", limit: 1);
    if (result.isNotEmpty) {
      return result.first["income"] ?? 0.0;
    }
    return 0.0;
  }

  Future<double> getExpense() async {
    final db = DatabaseHelper.instance; // Access the DatabaseHelper instance
    final database = await db.database; // Access the database property
    List<Map<String, dynamic>> result = await database.query("balance", limit: 1);
    if (result.isNotEmpty) {
      return result.first["expense"] ?? 0.0;
    }
    return 0.0;
  }

  @override
  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadBalance(); // Fetch the balance when the screen loads
  }

  String selectedMonth = "October";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage("assets/profile.jpg"),
            ),
          ),
        ),
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedMonth, // Variable storing the currently selected month
            onChanged: (String? newValue) {
              setState(() {
                selectedMonth = newValue!;
              });
            },
            items: [
              "January", "February", "March", "April", "May", "June",
              "July", "August", "September", "October", "November", "December"
            ].map<DropdownMenuItem<String>>((String month) {
              return DropdownMenuItem<String>(
                value: month,
                child: Text(
                  month,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              );
            }).toList(),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          )
        ],
      )
      ,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Centers the column's content vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Aligns text in the center horizontally
                children: [
                  Text(
                    "Account Balance",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "\₹${_currentBalance.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceCard(
                  "Income",
                  "\₹${_totalIncome.toStringAsFixed(2)}", // Use _totalIncome
                  Colors.green,
                  "assets/income_download.png",
                ),
                SizedBox(width: 16),
                _buildBalanceCard(
                  "Expenses",
                  "\₹${_totalExpense.toStringAsFixed(2)}", // Use _totalExpense
                  Colors.red,
                  "assets/income_upload.png",
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            // Add the "Recent Transaction" and "See All" button here
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Transaction",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                TextButton(
                  onPressed: () {
                    // Add functionality for "See All" button
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TransactionHistoryScreen()),
                    );
                    print("See All button pressed");
                  },
                  child: Text(
                    "See All",
                    style: TextStyle(color: Colors.purple, fontSize: 16),
                  ),
                ),
                SizedBox(width:10),
                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>FilterScreen(transactions: _transactions,),));
                }, child: Text('Filter'),style: ElevatedButton.styleFrom(backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,),)
              ],
            ),
            SizedBox(width: 10,),
            SizedBox(height: 10),
            _buildTransactionSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen(
              onTransactionAdded:(){
                _loadTransactions(); // Ensure this is called to refresh the list
                _loadBalance();
              }
            )),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.compare_arrows), label: "Transaction"),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "Budget"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color color, String imagePath) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 24,  // Adjust size as needed
              height: 24,
            ),
            SizedBox(width: 8),  // Space between icon and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  amount,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
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



  Widget _buildTransactionSection() {
    return Expanded(
      child: _transactions.isEmpty
          ? Center(
        child: Text(
          "No transactions yet.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return _buildTransactionTile(
            transaction['category'] ?? 'Income',
            transaction['description'] ?? 'No description',
            transaction['amount'].toStringAsFixed(2),
            _getIconPath(transaction['category']),
            transaction['type'],
            transaction['id'], // Pass the transaction ID
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(String title, String subtitle, String amount, String iconPath, String type, int id) {
    return Dismissible(
      key: Key(id.toString()), // Unique key for each transaction
      direction: DismissDirection.endToStart, // Swipe from right to left
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red, // Background color when swiping
        child: Icon(Icons.delete, color: Colors.white), // Delete icon
      ),
      onDismissed: (direction) async {
        // Delete the transaction from the database
        final db = DatabaseHelper.instance;
        await db.deleteTransaction(id);

        // Update the account balance, income, and expense
        double transactionAmount = double.parse(amount);
        if (type == 'Income') {
          _currentBalance -= transactionAmount;
          _totalIncome -= transactionAmount;
        } else {
          _currentBalance += transactionAmount;
          _totalExpense -= transactionAmount;
        }

        // Update the database with the new balance, income, and expense
        await db.updateBalance(_currentBalance);
        await db.updateIncome(_totalIncome);
        await db.updateExpense(_totalExpense);

        // Refresh the UI
        _loadTransactions();
        _loadBalance();
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // 🔹 Transaction Icon with Colored Background
              CircleAvatar(
                radius: 25,
                backgroundColor: type == 'Expense' ? Colors.redAccent.withOpacity(0.2) : Colors.greenAccent.withOpacity(0.2),
                child: Image.asset(iconPath, height: 28),
              ),
              SizedBox(width: 12),

              // 🔹 Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 🔹 Amount & Expense/Income Indicator
              Text(
                type == 'Expense' ? "- ₹${amount}" : "+ ₹${amount}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: type == 'Expense' ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
