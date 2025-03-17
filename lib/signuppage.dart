import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signinpage.dart'; // Import SignInPage
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
  ]; // Example countries

  void _signUpAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserPreferenceScreen()),
      );
    } catch (e) {
      print('Anonymous sign-in failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // Light Neutral background
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: Color(0xFF3D59AB),
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ), // Deep Blue heading 
        ),
        backgroundColor: const Color(0xFFF7F7F7),
        iconTheme: const IconThemeData(color: Color(0xFF333333)), // Dark Charcoal
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 90),
                const Text(
                  'Create an Account',
                  style: TextStyle(
                    color: Color(0xFF3D59AB), // Deep Blue
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                // Email Input Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xFF3D59AB)), // Deep Blue
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                ),
                const SizedBox(height: 20),
                // Password Input Field with Visibility Toggle
                TextFormField(
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Color(0xFF3D59AB)), // Deep Blue
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF3D59AB), // Deep Blue
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Phone Number Input Field
                TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Color(0xFF3D59AB)), // Deep Blue
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                ),
                const SizedBox(height: 20),
                // Country Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Country',
                    labelStyle: TextStyle(color: Color(0xFF3D59AB)), // Deep Blue
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  value: _selectedCountry,
                  items: _countries.map((country) {
                    return DropdownMenuItem(
                      value: country,
                      child: Text(country),
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
                      backgroundColor: const Color(0xFFFF7F50), // Coral Orange button
                      foregroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Already have an account? Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(color: Color(0xFF333333)), // Dark Charcoal
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInPage()),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(color: Color(0xFF20B2AA)), // Teal
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
