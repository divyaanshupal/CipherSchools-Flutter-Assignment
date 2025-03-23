import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracker/screens/SignUp_Screen.dart';
import 'package:tracker/screens/splash_screen.dart';
import 'package:tracker/screens/home_screen.dart'; // Import your HomeScreen
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple, // Example primary color
        scaffoldBackgroundColor: Colors.white, // Example background color
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show a loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  SplashScreen();
          }
          // Handle errors
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          // If user is authenticated, redirect to the main app screen
          else if (snapshot.hasData) {
            return HomeScreen();
          }
          // If user is not authenticated, redirect to the sign-up screen
          else {
            return SignUpScreen();
          }
        },
      ),
    );
  }
}