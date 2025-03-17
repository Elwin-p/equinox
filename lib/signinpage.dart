import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepage.dart'; // Redirecting to HomePage after sign-in
import 'signuppage.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  HomePage()),
      );
    } catch (e) {
      print("Error signing in anonymously: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // Light Neutral background
      appBar: AppBar(
        title: const Text(
          'Sign In',
          style: TextStyle(
            color: Color(0xFF3D59AB),
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ), // Deep Blue heading
        ),
        backgroundColor: const Color(0xFFF7F7F7),
        iconTheme: const IconThemeData(color: Color(0xFF333333)), // Dark Charcoal
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 160), // Adds space from the top
              
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  color: Color(0xFF3D59AB), // Deep Blue
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              
              const Text(
                'Sign in to continue',
                style: TextStyle(
                  color: Color(0xFF333333), // Dark Charcoal text
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),

              // Dummy Email Input Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Color(0xFF3D59AB)), // Deep Blue
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dummy Password Input Field
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Color(0xFF3D59AB)), // Deep Blue
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Forgot Password (Non-functional for MVP)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Color(0xFF3D59AB)), // Deep Blue
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sign In Button (Triggers Anonymous Sign-In)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _signInAnonymously(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7F50), // Coral Orange button
                    foregroundColor: Colors.white, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sign Up Option (Navigates to SignUpPage)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: Color(0xFF333333)), // Dark Charcoal
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Color(0xFF20B2AA)), // Teal
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30), // Prevents content from being too tight at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
