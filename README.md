Expense Tracker App - README
Overview
This Expense Tracker is a Flutter application designed to help users manage their finances by tracking income and expenses. The app provides features like transaction recording, balance tracking, and transaction history visualization.

Features
1-User Authentication

    a)-Email/Password login
    b)-Google Sign-In
    c)-Persistent login session

2-Transaction Management

    a)-Add income/expense transactions
    b)-Categorize expenses (Food, Shopping, Bills)
    c)-Select payment method (Cash, Bank, Credit Card)
    d)-Add descriptions to transactions

3-Financial Overview

    a)-Current balance display
    b)-Total income and expense tracking

4-Transaction History

    a)-View all transactions in a list
    b)-Swipe-to-delete functionality
    c)-Detailed transaction view

5-User Profile

    a)-Profile picture and name display
    b)-Account settings
    c)-Logout functionality

Technical Stack
    Frontend: Flutter (Dart)
    Database:
        Local: SQLite (via sqflite package)
        Cloud: Firebase Firestore (for user data)
    Authentication: Firebase Authentication
    State Management: Built-in Flutter state management (setState)

Database Structure
The app uses two main databases:
->Local SQLite Database (tracker.db)
    ->Tables:
        transactions: Stores all financial transactions
        balance: Stores current balance, total income, and total expenses
        user_data: Stores user authentication state
->Firebase Firestore
    ->Collections:
        users: Stores user profile information
        data: Additional user data storage

Screens
->Splash Screen: Shows app logo and checks login status
->Login/Signup Screens: Handle user authentication
->Home Screen:
    Displays current balance
    Shows income/expense totals
    Recent transactions list
    Navigation to other screens
->Add Transaction Screen: Form for adding new transactions
->Transaction History Screen: Complete list of all transactions
->Profile Screen: User profile and settings


Dependencies
firebase_auth: For authentication
cloud_firestore: For cloud data storage
firebase_storage: For profile picture storage
google_sign_in: For Google Sign-In
sqflite: For local database
path: For database path handling


NOTE- Google Authentication doesn't properly in the emulator , to test it please use the physical device 
