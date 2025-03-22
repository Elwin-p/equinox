import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signinpage.dart';
import 'userpreference.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String? _selectedCountry;
  final List<String> _countries = [
    'United States', 'United Kingdom', 'Canada', 'India', 'Australia',
    'Germany', 'France', 'Japan', 'China', 'Brazil', 'South Africa'
  ];

  void _signUpAnonymously() async {
  try {
    final FirebaseAuth auth = FirebaseAuth.instance;
    
    // Check if there's an existing user and sign them out
    if (auth.currentUser != null) {
      await auth.signOut();
    }
    
    // Sign in anonymously to generate a new ID
    await auth.signInAnonymously();
    
    // Verify we have a user after signing in
    if (auth.currentUser != null && context.mounted) {
      // Using pushAndRemoveUntil for more efficient navigation
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const UserPreferenceScreen()),
        (route) => false,
      );
    } else {
      throw Exception('Anonymous sign-in failed to create a new user');
    }
  } catch (e) {
    // Professional error handling with SnackBar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing up: ${e.toString()}')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    // Define reusable text styles
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

    // Reusable input decoration
    InputDecoration getInputDecoration(String label) {
      return InputDecoration(
        labelText: label,
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
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Lighter background for professional look
      appBar: AppBar(
        elevation: 0, // Remove shadow for cleaner look
        title: Text('Sign Up', style: headingStyle),
        backgroundColor: const Color(0xFFFAFAFA),
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40), // Reduced space for efficiency
                  
                  Text('Create an Account', style: subheadingStyle),
                  const SizedBox(height: 30),
                  
                  // Email Input Field
                  TextFormField(
                    decoration: getInputDecoration('Email'),
                    style: bodyTextStyle,
                  ),
                  const SizedBox(height: 20),
                  
                  // Password Input Field with Visibility Toggle
                  TextFormField(
                    obscureText: _obscurePassword,
                    decoration: getInputDecoration('Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF3D59AB),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    style: bodyTextStyle,
                  ),
                  const SizedBox(height: 20),
                  
                  // Phone Number Input Field
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: getInputDecoration('Phone Number'),
                    style: bodyTextStyle,
                  ),
                  const SizedBox(height: 20),
                  
                  // Country Dropdown with improved styling
                  DropdownButtonFormField<String>(
                    decoration: getInputDecoration('Select Country'),
                    value: _selectedCountry,
                    style: bodyTextStyle,
                    dropdownColor: Colors.white,
                    items: _countries.map((country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(country, style: bodyTextStyle),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCountry = value;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _signUpAnonymously,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3D59AB), // Professional blue color
                        foregroundColor: Colors.white,
                        elevation: 0, // No shadow for clean look
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Sign Up', style: buttonTextStyle),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Already have an account? Sign In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: bodyTextStyle,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignInPage()),
                          );
                        },
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF3D59AB),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}