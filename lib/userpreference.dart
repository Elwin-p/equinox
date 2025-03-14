import 'package:flutter/material.dart';
import 'leaner.dart';
import 'hirer.dart';

class UserPreferenceScreen extends StatefulWidget {
  @override
  _UserPreferenceScreenState createState() => _UserPreferenceScreenState();
}

class _UserPreferenceScreenState extends State<UserPreferenceScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7), // Light neutral background
      appBar: AppBar(
        title: Text(
          'Choose Your Role',
          style: TextStyle(color: Color(0xFF333333)),
        ),
        backgroundColor: Color(0xFFF7F7F7), // Light neutral background
        iconTheme: IconThemeData(color: Color(0xFF333333)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 100),
            _buildOption(
              title: 'Learner',
              description: 'Learn and build projects with like-minded individuals.',
              value: 'learner',
            ),
            SizedBox(height: 20),
            _buildOption(
              title: 'Hiring',
              description: 'For professional companies seeking talent.',
              value: 'hiring',
            ),
            SizedBox(height: 40),
            if (selectedRole != null)
              Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  onPressed: () {
                    if (selectedRole == 'learner') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LearnerScreen()),
                      );
                    } else if (selectedRole == 'hiring') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HiringScreen()),
                      );
                    }
                  },
                  backgroundColor: Color(0xFF3D59AB), // Deep Blue
                  child: Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({required String title, required String description, required String value}) {
    bool isSelected = selectedRole == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF3D59AB) : Colors.white, // Deep Blue for selected option
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF3D59AB), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Color(0xFF333333),
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white70 : Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
