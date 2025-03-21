import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage.dart'; // Import the new HomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  String _selectedLevel = 'Beginner';
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    
    _controller.forward();
    
    // Set default values
    _skillController.text = "Flutter Development";
    _hoursController.text = "2";
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _skillController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _navigateToHomeScreen() {
    // Get values from form
    final skill = _skillController.text.isEmpty ? "Flutter Development" : _skillController.text;
    final hours = int.tryParse(_hoursController.text) ?? 2;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomePage(
          skill: skill,
          hoursPerDay: hours,
          //level: _selectedLevel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF2D31FA);
    final Color accentColor = const Color(0xFFFF8C32);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Logo and Title
                  const Center(
                    child: Icon(
                      Icons.school,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Equinox',
                          textStyle: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                      displayFullTextOnTap: true,
                    ),
                  ),
                  Center(
                    child: Text(
                      "AI-Powered Learning Paths",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Form to collect user preferences
                  Text(
                    "What would you like to learn?",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Skill input field
                  TextFormField(
                    controller: _skillController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: "E.g., Flutter, Machine Learning, Web Dev",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.code),
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Hours per day input
                  TextFormField(
                    controller: _hoursController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: "Hours per day (1-8)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.timer_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Level selection dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLevel,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: _levels.map((String level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Row(
                              children: [
                                Icon(
                                  level == 'Beginner' ? Icons.school_outlined :
                                  level == 'Intermediate' ? Icons.trending_up :
                                  Icons.emoji_events_outlined,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  level,
                                  style: GoogleFonts.poppins(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLevel = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _navigateToHomeScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        "Generate Learning Path",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}