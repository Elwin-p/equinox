import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signuppage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Equinox Home',
          style: TextStyle(
            color: Color(0xFF3D59AB), // Deep Blue
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF7F7F7),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF3D59AB)), // Deep Blue
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignUpPage()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Welcome to Equinox!",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333), // Dark Charcoal
          ),
        ),
      ),
    );
  }
}
