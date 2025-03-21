import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'leaner.dart';
import 'hirer.dart';

class UserPreferenceScreen extends StatefulWidget {
  const UserPreferenceScreen({Key? key}) : super(key: key);

  @override
  _UserPreferenceScreenState createState() => _UserPreferenceScreenState();
}

class _UserPreferenceScreenState extends State<UserPreferenceScreen> {
  String? selectedRole;
  
  // Modern color scheme
  final Color _primaryColor = const Color(0xFF3D59AB);
  final Color _backgroundColor = const Color(0xFFFAFAFA);
  final Color _cardColor = Colors.white;
  final Color _textPrimaryColor = const Color(0xFF2C3550);
  final Color _textSecondaryColor = const Color(0xFF717790);

  void _navigateToScreen() {
    if (selectedRole == null) return;
    
    final Widget nextScreen = selectedRole == 'learner' 
        ? const LearnerScreen() 
        : const HiringScreen();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Choose Your Role',
          style: GoogleFonts.poppins(
            color: _textPrimaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: _backgroundColor,
        iconTheme: IconThemeData(color: _textPrimaryColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              
              // Header section
              Text(
                'Welcome to AI Learning',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textPrimaryColor,
                ),
              ),
              
              Text(
                'Please select your role to continue',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: _textSecondaryColor,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Role selection options
              _buildRoleOption(
                icon: Icons.school_rounded,
                title: 'Learner',
                description: 'Learn and build projects with like-minded individuals.',
                value: 'learner',
              ),
              
              const SizedBox(height: 16),
              
              _buildRoleOption(
                icon: Icons.business_center_rounded,
                title: 'Hiring',
                description: 'For professional companies seeking talent.',
                value: 'hiring',
              ),
              
              const Spacer(),
              
              // Continue button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: selectedRole != null ? _navigateToScreen : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    disabledBackgroundColor: _primaryColor.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required IconData icon,
    required String title,
    required String description,
    required String value,
  }) {
    bool isSelected = selectedRole == value;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? _primaryColor.withOpacity(0.1) : _cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? _primaryColor : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedRole = value;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : _primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? _primaryColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? _primaryColor : _textSecondaryColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}