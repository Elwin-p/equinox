import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this package for Poppins font
import 'homepage.dart';
import 'signuppage.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      // Use pushAndRemoveUntil for more efficient navigation
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } catch (e) {
      // More professional error handling with SnackBar instead of print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define text styles once for reuse - more efficient
    final headingStyle = GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF3D59AB),
    );
    
    final subheadingStyle = GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF3D59AB),
    );
    
    final bodyTextStyle = GoogleFonts.poppins(
      fontSize: 16,
      color: const Color(0xFF333333),
    );
    
    final buttonTextStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Slightly lighter background for professional look
      appBar: AppBar(
        elevation: 0, // Remove shadow for modern, clean look
        title: Text('Sign In', style: headingStyle),
        backgroundColor: const Color(0xFFFAFAFA),
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60), // Reduced spacing for efficiency
                
                Text('Welcome Back', style: subheadingStyle),
                const SizedBox(height: 8),
                
                Text('Sign in to your account to continue', style: bodyTextStyle),
                const SizedBox(height: 40),
                
                // Email Field with improved decoration
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: GoogleFonts.poppins(color: const Color(0xFF3D59AB)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF3D59AB), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: bodyTextStyle,
                ),
                const SizedBox(height: 20),
                
                // Password Field with improved decoration
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.poppins(color: const Color(0xFF3D59AB)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF3D59AB), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: bodyTextStyle,
                ),
                const SizedBox(height: 12),
                
                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF3D59AB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Sign In Button - more professional look
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _signInAnonymously(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D59AB), // More professional blue instead of coral
                      foregroundColor: Colors.white,
                      elevation: 0, // No shadow for clean look
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Sign In', style: buttonTextStyle),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Sign Up Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: bodyTextStyle,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpPage()),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF3D59AB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}