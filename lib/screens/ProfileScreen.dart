import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tracker/database/DatabaseHelper.dart';

import 'SignUpScreen.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "Loading...";
  String profilePictureUrl = "";

  @override
  void initState() {
    super.initState();
    fetchUsername();
    fetchProfilePicture();
  }

  Future<void> fetchUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['name'] ?? 'Unknown User';
          });
        }
      }
    } catch (e) {
      _showError("Error fetching user data: $e");
    }
  }

  Future<void> fetchProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final ref =
        FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');
        final url = await ref.getDownloadURL();
        setState(() {
          profilePictureUrl = url;
        });
      } catch (e) {
        print("Error fetching profile picture: $e");
      }
    }
  }
  Future<void> _signOut() async {
    try {
      // Sign out from Firebase Authentication
      await FirebaseAuth.instance.signOut();

      // Sign out from Google Sign-In (if applicable)
      await GoogleSignIn().signOut();

      //clear user data from sqflite
      await DatabaseHelper.instance.clearUserData();

      // Navigate to the SignUp Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignUpScreen()),
      );
    } catch (e) {
      _showError("Failed to sign out: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light background
      body: Stack(
        children: [
          // Gradient Header Background
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),

          // Profile Content
          SafeArea(
            child: Column(
              children: [
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // Profile Info
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: profilePictureUrl.isNotEmpty
                            ? NetworkImage(profilePictureUrl)
                            : AssetImage('assets/profile.jpg') as ImageProvider,
                      ),
                      SizedBox(height: 10),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          username,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Text(
                      //   "Flutter Developer",
                      //   style: TextStyle(color: Colors.white70, fontSize: 14),
                      // ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Profile Menu Items
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        profileMenuItem(
                          icon: Icons.account_circle,
                          text: "Account",
                          color: Colors.purple[50]!,
                          onTap: () {},
                        ),
                        profileMenuItem(
                          icon: Icons.settings,
                          text: "Settings",
                          color: Colors.blue[50]!,
                          onTap: () {},
                        ),
                        profileMenuItem(
                          icon: Icons.upload,
                          text: "Export Data",
                          color: Colors.green[50]!,
                          onTap: () {},
                        ),
                        profileMenuItem(
                          icon: Icons.logout,
                          text: "Logout",
                          color: Colors.red[50]!,
                          onTap: _signOut,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget profileMenuItem(
      {required IconData icon, required String text, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            SizedBox(width: 15),
            Text(
              text,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 16),
          ],
        ),
      ),
    );
  }
}
