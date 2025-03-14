import 'package:flutter/material.dart';
import 'signinpage.dart'; // Import SignInPage screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Navigate to SignInPage after 2 seconds (only if widget is mounted)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInPage()), 
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F7F7), // Light Neutral background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image(
              image: AssetImage('assets/logo.png'), // Fixed asset path
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20), // Spacing
            // Welcome Text
            Text(
              'Equal Access. Infinte Growth.',
              style: TextStyle(
                color: Color(0xFF333333), // Dark Charcoal text
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
