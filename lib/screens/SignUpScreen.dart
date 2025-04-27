import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tracker/screens/HomeScreen.dart';

import '../database/DatabaseHelper.dart';
import 'LoginScreen.dart';
class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _isChecked = false;
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // To show loading state
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please accept the terms and conditions.")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with Firebase Authentication
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Store user data in Firestore under the 'users' collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': Timestamp.now(),
        });



        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign up successful!")),
        );

        // Navigate to the home screen or login screen
        //Navigator.pop(context); // Go back to the previous screen
      } on FirebaseAuthException catch (e) {
        // Handle errors
        String errorMessage = "An error occurred. Please try again.";
        if (e.code == 'weak-password') {
          errorMessage = "The password is too weak.";
        } else if (e.code == 'email-already-in-use') {
          errorMessage = "The email is already in use.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An unexpected error occurred.")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return; // User canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
      );
      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Save user ID and login status to Sqflite
      await DatabaseHelper.instance.saveUserData(userCredential.user!.uid, true);

      // Store user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': googleUser.displayName ?? "Google User",
        'email': googleUser.email,
        'createdAt': Timestamp.now(),
      });

      // Store the username in the 'data' collection
      await FirebaseFirestore.instance
          .collection('data')
          .doc(userCredential.user!.uid)
          .set({
        'name': googleUser.displayName ?? "Google User",
        'createdAt': Timestamp.now(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-Up successful!")),
      );

      // Navigate to the home screen or login screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen())); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing in with Google: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey, // Form key for validation
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔙 Back Arrow
                const SizedBox(height: 10),

                // 📝 Sign Up Title
                const Center(
                  child: Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Name Field
                _buildTextField("Name", false, controller: _nameController),
                const SizedBox(height: 12),

                // 🔹 Email Field
                _buildTextField("Email", false, controller: _emailController),
                const SizedBox(height: 12),

                // 🔹 Password Field with Toggle Visibility
                _buildTextField("Password", true, controller: _passwordController),
                const SizedBox(height: 12),

                // ✅ Terms & Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      activeColor: Colors.purple,
                      onChanged: (bool? value) {
                        setState(() {
                          _isChecked = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: "By signing up, you agree to the ",
                          children: [
                            TextSpan(
                              text: "Terms of Service",
                              style: const TextStyle(
                                  color: Colors.purple, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: const TextStyle(
                                  color: Colors.purple, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 🚀 Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign Up", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 OR with Divider
                const Center(
                  child: Text("Or with", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 12),

                // 🟢 Google Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading?null:_signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/google_icon.png', height: 24), // 🔄 Add Google Icon
                        const SizedBox(width: 10),
                        const Text("Sign Up with Google", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Already have an account?
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to Login Screen
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()),);
                    },
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(
                          color: Colors.purple, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, bool isPassword, {required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "This field is required.";
        }
        if (hint == "Email" && !value.contains("@")) {
          return "Please enter a valid email.";
        }
        if (hint == "Password" && value.length < 6) {
          return "Password must be at least 6 characters.";
        }
        return null;
      },
    );
  }
}