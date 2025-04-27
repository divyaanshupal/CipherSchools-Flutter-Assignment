import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();  //its a singleton property
  static Database? _database;

  DatabaseHelper._init();  //init prevents creating multiple objects

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      return await openDatabase(
        join(await getDatabasesPath(), 'tracker.db'),  //determine the patha where database file of sqflite is stored 
        version: 2,
        onCreate: (db, version) async {
          //creating the transaction table
          await db.execute('''
            CREATE TABLE transactions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              amount REAL NOT NULL,
              date TEXT NOT NULL,
              type TEXT NOT NULL,  
              category TEXT,
              wallet TEXT,
              description TEXT
            )
          ''');
          //creating the balance table
          await db.execute('''
            CREATE TABLE balance (
              id INTEGER PRIMARY KEY,
              balance REAL DEFAULT 0,
              income REAL DEFAULT 0,
              expense REAL DEFAULT 0
            )
          ''');

          // Insert initial balance
          await db.insert("balance", {'id': 1, 'balance': 0, 'income': 0, 'expense': 0});
          
          await db.execute('''
            CREATE TABLE user_data (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id TEXT,
              is_logged_in INTEGER DEFAULT 0
            )
          ''');
        },
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 2) {
              // Add the user_data table if upgrading from an older version
              await db.execute('''
              CREATE TABLE user_data (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT,
                is_logged_in INTEGER DEFAULT 0
              )
            ''');
            }
          },
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }
  Future<void> saveUserData(String userId, bool isLoggedIn) async {
    final db = await database;
    await db.delete('user_data'); // Clear any existing data
    await db.insert('user_data', {
      'user_id': userId,
      'is_logged_in': isLoggedIn ? 1 : 0,
    });
  }

  // Get user ID
  Future<String?> getUserId() async {
    final db = await database;
    final result = await db.query('user_data', limit: 1);  //limit 1 is used so that querry can return only one row 
    if (result.isNotEmpty) {
      return result.first['user_id'] as String?;
    }
    return null;
  }

  //check wether the user is logged in
  Future<bool> isLoggedIn() async {
    final db = await database;
    final result = await db.query('user_data', limit: 1);
    if (result.isNotEmpty) {
      return result.first['is_logged_in'] == 1;
    }
    return false;
  }

  // Clear user data (for logout)
  Future<void> clearUserData() async {
    final db = await database;
    await db.delete('user_data');
  }

  //to insert the transaction
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    try {
      final db = await database;
      final double amount = transaction['amount'];
      final String type = transaction['type'];

      // Fetch the current balance, income, and expense
      List<Map<String, dynamic>> balanceData = await db.query("balance", limit: 1);
      double currentBalance = balanceData.first["balance"] ?? 0.0;
      double currentIncome = balanceData.first["income"] ?? 0.0;
      double currentExpense = balanceData.first["expense"] ?? 0.0;

      // Update the balance, income, and expense based on the transaction type
      if (type == 'Income') {
        currentBalance += amount;
        currentIncome += amount; // Update income
      } else if (type == 'Expense') {
        currentBalance -= amount;
        currentExpense += amount; // Update expense
      }

      // Update the balance table
      await db.update(
        "balance",
        {
          "balance": currentBalance,
          "income": currentIncome,
          "expense": currentExpense,
        },
        where: "id = 1",
      );

      print("Updated Balance: $currentBalance, Income: $currentIncome, Expense: $currentExpense"); // Debug print

      // Insert the transaction
      return await db.insert('transactions', transaction);    //db.insert to insert the data into the database 
    } catch (e) {
      print('Error inserting transaction: $e');
      return -1;
    }
  }

  // ✅ Get balance
  Future<double> getBalance() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query("balance", limit: 1);   //db.query to fetch the data from the database

    if (result.isNotEmpty) {
      return result.first["balance"] ?? 0.0;
    }
    return 0.0;
  }

// ✅ Update balance
  Future<void> updateBalance(double newBalance) async {
    final db = await database;
    await db.update(                //db.update to update the database
      "balance",
      {"balance": newBalance},
      where: "id = 1",
    );
  }

  // ✅ Get income
  Future<double> getIncome() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query("balance", limit: 1);

    if (result.isNotEmpty) {
      return result.first["income"] ?? 0.0;
    }
    return 0.0;
  }

  // ✅ Get expense
  Future<double> getExpense() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query("balance", limit: 1);

    if (result.isNotEmpty) {
      return result.first["expense"] ?? 0.0;
    }
    return 0.0;
  }

  // ✅ Update income
  Future<void> updateIncome(double newIncome) async {
    final db = await database;
    await db.update(
      "balance",
      {"income": newIncome},
      where: "id = 1",
    );
  }

  // ✅ Update expense
  Future<void> updateExpense(double newExpense) async {
    final db = await database;
    await db.update(
      "balance",
      {"expense": newExpense},
      where: "id = 1",
    );
  }

  // ✅ Fetch all transactions
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    try {
      final db = await instance.database;
      return await db.query('transactions', orderBy: 'date DESC');
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  // ✅ Delete a transaction
  Future<int> deleteTransaction(int id) async {
    try {
      final db = await database;
      return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting transaction: $e');
      return -1;
    }
  }

  // ✅ Update a transaction
  Future<int> updateTransaction(int id, Map<String, dynamic> transaction) async {
    try {
      final db = await instance.database;
      return await db.update('transactions', transaction, where: 'id = ?', whereArgs: [id]);  //WhereArgs is usded to transfer the data securily to the place holder , and prevent us from the sql injection
    } catch (e) {
      print('Error updating transaction: $e');
      return -1;
    }
  }

}
