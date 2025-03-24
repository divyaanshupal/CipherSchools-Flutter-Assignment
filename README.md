# Expense Tracker App - README

## Overview
This Expense Tracker is a Flutter application designed to help users manage their finances by tracking income and expenses. The app provides features like transaction recording, balance tracking, and transaction history visualization.

## Features
1. **User Authentication**
   - Email/Password login
   - Google Sign-In
   - Persistent login session

2. **Transaction Management**
   - Add income/expense transactions
   - Categorize expenses (Food, Shopping, Bills)
   - Select payment method (Cash, Bank, Credit Card)
   - Add descriptions to transactions

3. **Financial Overview**
   - Current balance display
   - Total income and expense tracking
   - Monthly transaction filtering

4. **Transaction History**
   - View all transactions in a list
   - Swipe-to-delete functionality
   - Detailed transaction view

5. **User Profile**
   - Profile picture and name display
   - Account settings
   - Logout functionality

## Technical Stack
- **Frontend**: Flutter (Dart)
- **Database**: 
  - Local: SQLite (via `sqflite` package)
  - Cloud: Firebase Firestore (for user data)
- **Authentication**: Firebase Authentication
- **State Management**: Built-in Flutter state management (setState)

## Database Structure
The app uses two main databases:

### Local SQLite Database (`tracker.db`)
- **Tables**:
  - `transactions`: Stores all financial transactions
  - `balance`: Stores current balance, total income, and total expenses
  - `user_data`: Stores user authentication state

### Firebase Firestore
- **Collections**:
  - `users`: Stores user profile information
  - `data`: Additional user data storage

## Screens
1. **Splash Screen**: Shows app logo and checks login status
2. **Login/Signup Screens**: Handle user authentication
3. **Home Screen**: 
   - Displays current balance
   - Shows income/expense totals
   - Recent transactions list
   - Navigation to other screens
4. **Add Transaction Screen**: Form for adding new transactions
5. **Transaction History Screen**: Complete list of all transactions
6. **Profile Screen**: User profile and settings

## Setup Instructions
1. Clone the repository
2. Install Flutter SDK
3. Run `flutter pub get` to install dependencies
4. Set up Firebase project and add configuration files
5. Run the app with `flutter run`

## Dependencies
- `firebase_auth`: For authentication
- `cloud_firestore`: For cloud data storage
- `firebase_storage`: For profile picture storage
- `google_sign_in`: For Google Sign-In
- `sqflite`: For local database
- `path`: For database path handling

## Future Enhancements
1. Add budget tracking features
2. Implement data export/import
3. Add charts for visual spending analysis
4. Support for multiple currencies
5. Recurring transactions feature

## Known Issues
- No error handling for duplicate transactions
- Limited category customization
- No offline sync capability with Firebase

## Contribution
Contributions are welcome! Please fork the repository and submit pull requests for any improvements or bug fixes.

## License
This project is open-source and available under the MIT License.
