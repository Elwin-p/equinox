import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage.dart';

class LearnerScreen extends StatefulWidget {
  const LearnerScreen({Key? key}) : super(key: key);

  @override
  _LearnerScreenState createState() => _LearnerScreenState();
}

class _LearnerScreenState extends State<LearnerScreen> {
  // Form controllers and values
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _newInterestController = TextEditingController();
  final TextEditingController _newSkillController = TextEditingController();
  final TextEditingController _newLearningGoalController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _careerGoalsController = TextEditingController();
  
  // Selected values
  String? _selectedPursuing;
  String? _selectedLevel;
  double _freeTime = 2.0;
  
  // Theme colors
  final Color _primaryColor = const Color(0xFF2D31FA);
  final Color _secondaryColor = const Color(0xFF5D8BF4);
  final Color _accentColor = const Color(0xFFFF8C32);
  final Color _bgColor = const Color(0xFFF9F9F9);
  
  // Lists of options
  List<String> _pursuingOptions = [];
  
  // Selected items
  
  List<String> _selectedInterests = [];
  List<String> _selectedLearningGoals = [];
  Map<String, double> _skillRatings = {};
  
  // Available options
  List<String> _interests = [
    'AI & ML', 
    'Web Development', 
    'Cybersecurity', 
    'Data Science', 
    'Blockchain',
    'Game Development', 
    'AR/VR', 
    'IoT', 
    'Cloud Computing', 
    'UI/UX Design'
  ];
  
  
  List<String> _learningGoals = [
    'AI & ML', 
    'Web Dev', 
    'Cloud', 
    'Game Dev', 
    'UI/UX'
  ];

  List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _loadPursuingOptions();
  }

  /// Loads pursuing options from JSON asset
  Future<void> _loadPursuingOptions() async {
    try {
      String jsonString = await rootBundle.loadString('assets/pursuing.json');
      List<dynamic> jsonData = json.decode(jsonString);
      setState(() {
        _pursuingOptions = List<String>.from(jsonData.map((e) => e["degree_title"]));
      });
    } catch (e) {
      debugPrint('Error loading pursuing options: $e');
    }
  }

  /// Adds a custom option to a list if it doesn't already exist
  void _addCustomOption(String option, List<String> list, TextEditingController controller) {
    if (option.isNotEmpty && !list.contains(option)) {
      setState(() {
        list.add(option);
        controller.clear();
      });
    }
  }

  /// Saves user data to Firestore and SharedPreferences
  Future<void> _saveData() async {
    // Validate required fields
    if (_selectedPursuing == null || 
        _selectedInterests.isEmpty || 
        _selectedLearningGoals.isEmpty || 
        _usernameController.text.isEmpty ||
        _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please fill all required fields",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              color: _primaryColor,
            ),
          );
        },
      );

      // Save username locally
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _usernameController.text);
    
      // Save all data to Firestore
      await FirebaseFirestore.instance.collection('learners').add({
        'name': _usernameController.text,
        'pursuing': _selectedPursuing,
        'interests': _selectedInterests,
        'skills': _skillRatings,
        'learningGoals': _selectedLearningGoals,
        'freeTime': _freeTime,
        'level': _selectedLevel,
        'firstSkill': _skillsController.text,
        'careerGoals': _careerGoalsController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Close loading dialog and navigate to home
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const HomePage())
      );
    } catch (e) {
      // Close loading dialog and show error
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error saving data: $e",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Builds the app bar with title
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Learner Preferences',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
    );
  }

  /// Builds the main body content
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Enter your username *'),
            _buildTextField(
              controller: _usernameController,
              labelText: 'Username',
              hintText: 'Enter a username',
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('What are you pursuing? *'),
            const SizedBox(height: 8),
            _buildPursuingDropdown(),
            const SizedBox(height: 24),

            _buildSectionTitle('Select your interests *'),
            const SizedBox(height: 8),
            _buildChipSelection(
              options: _interests,
              selectedOptions: _selectedInterests,
              controller: _newInterestController,
              hintText: 'Add new interest',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('What do you want to learn through this app? *'),
            const SizedBox(height: 8),
            _buildChipSelection(
              options: _learningGoals,
              selectedOptions: _selectedLearningGoals,
              controller: _newLearningGoalController,
              hintText: 'Add new learning goal',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('What skill do you want to learn first? *'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _skillsController,
              labelText: 'Skill name',
              hintText: 'e.g., Python, Flutter, etc.',
            ),
            Text(
              'Note: Min 20 hrs a month is necessary to learn basics',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('How much free time do you have daily? *'),
            const SizedBox(height: 8),
            _buildFreeTimeSlider(),
            const SizedBox(height: 24),

            _buildSectionTitle('What level do you want to learn? *'),
            const SizedBox(height: 8),
            _buildLevelDropdown(),
            const SizedBox(height: 24),

            _buildSectionTitle('Your Career Goals'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _careerGoalsController,
              labelText: 'Career aspirations',
              hintText: 'What do you aim to achieve?',
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            _buildContinueButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Builds a section title with Poppins font
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  /// Builds a styled text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  /// Builds dropdown for pursuing options
  Widget _buildPursuingDropdown() {
    return DropdownSearch<String>(
      items: _pursuingOptions,
      selectedItem: _selectedPursuing,
      onChanged: (value) => setState(() => _selectedPursuing = value),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: GoogleFonts.poppins(),
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        menuProps: MenuProps(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Search and select a degree",
          labelStyle: GoogleFonts.poppins(),
          hintText: "Select what you're pursuing",
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
        ),
      ),
      dropdownBuilder: (context, selectedItem) {
        return Text(
          selectedItem ?? "Select what you're pursuing",
          style: GoogleFonts.poppins(
            color: selectedItem == null ? Colors.grey : Colors.black87,
          ),
        );
      },
    );
  }

  /// Builds chip selection for interests and learning goals
  Widget _buildChipSelection({
    required List<String> options,
    required List<String> selectedOptions,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(
                option,
                style: GoogleFonts.poppins(
                  color: selectedOptions.contains(option) ? Colors.white : Colors.black87,
                  fontWeight: selectedOptions.contains(option) ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              selected: selectedOptions.contains(option),
              selectedColor: _secondaryColor,
              backgroundColor: Colors.grey[200],
              showCheckmark: false,
              onSelected: (selected) {
                setState(() {
                  selected
                      ? selectedOptions.add(option)
                      : selectedOptions.remove(option);
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(Icons.add, color: _primaryColor),
              onPressed: () => _addCustomOption(controller.text, options, controller),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
          ),
          style: GoogleFonts.poppins(),
          onSubmitted: (value) => _addCustomOption(value, options, controller),
        ),
      ],
    );
  }

  /// Builds the free time slider
/// Builds the free time slider
  Widget _buildFreeTimeSlider() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'You have ${_freeTime.toStringAsFixed(1)} hours of free time daily',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Slider(
                value: _freeTime,
                min: 0,
                max: 10,
                divisions: 20,
                label: '${_freeTime.toStringAsFixed(1)} hours',
                activeColor: _accentColor,
                inactiveColor: Colors.grey[300],
                onChanged: (value) {
                  setState(() {
                    _freeTime = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0 hrs',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '10 hrs',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds dropdown for learning level



// Then update the dropdown method:
Widget _buildLevelDropdown() {
  print("Available levels: $_levels"); // Debug print
  return DropdownButtonFormField<String>(
    value: _selectedLevel,
    items: _levels.map((level) {
      return DropdownMenuItem<String>(
        value: level,
        child: Text(
          level,
          style: GoogleFonts.poppins(color: Colors.black),
          
        ),
      );
    }).toList(),
    onChanged: (value) {
      setState(() {
        _selectedLevel = value;
      });
    },
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintText: 'Select level',
      hintStyle: GoogleFonts.poppins(color: Colors.grey),
    ),
    style: GoogleFonts.poppins(),
    dropdownColor: Colors.white,
    icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
    isExpanded: true,
  );
}
  /// Builds the continue button
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveData,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Continue',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _newInterestController.dispose();
    _newSkillController.dispose();
    _newLearningGoalController.dispose();
    _skillsController.dispose();
    _careerGoalsController.dispose();
    super.dispose();
  }
}