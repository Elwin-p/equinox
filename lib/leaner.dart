import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';

class LearnerScreen extends StatefulWidget {
  @override
  _LearnerScreenState createState() => _LearnerScreenState();
}

class _LearnerScreenState extends State<LearnerScreen> {
  String? selectedPursuing;
  TextEditingController userName= TextEditingController();
  List<String> pursuingOptions = [];
  List<String> selectedInterests = [];
  List<String> interests = [
    'AI & ML', 'Web Development', 'Cybersecurity', 'Data Science', 'Blockchain',
    'Game Development', 'AR/VR', 'IoT', 'Cloud Computing', 'UI/UX Design'
  ];
  TextEditingController newInterestController = TextEditingController();
  List<String> level = ['Beginner', 'Medium', 'Advanced'];
  List<String> selectedSkills = [];
  Map<String, double> skillRatings = {};
  List<String> skills = [
    'Python', 'Java', 'C++', 'Flutter', 'React', 'Django', 'TensorFlow', 'SQL', 'Rust', 'Kotlin'
  ];
  TextEditingController newSkillController = TextEditingController();

  List<String> selectedLearningGoals = [];
  List<String> learningGoals = [
    'AI & ML', 'Web Dev', 'Cloud', 'Game Dev', 'UI/UX'
  ];
  TextEditingController newLearningGoalController = TextEditingController();

  double freeTime = 2;
  String? selectedlevel;
  TextEditingController skillsController = TextEditingController();
  TextEditingController careerGoalsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPursuingOptions();
  }

  Future<void> loadPursuingOptions() async {
    String jsonString = await rootBundle.loadString('assets/pursuing.json');
    List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      pursuingOptions = List<String>.from(jsonData.map((e) => e["degree_title"]));
    });
  }

  void addCustomOption(String option, List<String> list, TextEditingController controller) {
    if (option.isNotEmpty && !list.contains(option)) {
      setState(() {
        list.add(option);
        controller.clear();
      });
    }
  }

  void saveData() async {
    if (selectedPursuing == null || selectedInterests.isEmpty || selectedLearningGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all mandatory fields")),
      );
      return;
    }

    try {

       // Save name locally
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userName.text);

    
      await FirebaseFirestore.instance.collection('learners').add({
        'name':userName.text,
        'pursuing': selectedPursuing,
        'interests': selectedInterests,
        'skills': skillRatings,
        'learningGoals': selectedLearningGoals,
        'freeTime': freeTime,
        'level': selectedlevel,
        'firstskills': skillsController.text,
        'careerGoals': careerGoalsController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Learner Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter your username', style: TextStyle(fontSize: 17)),
              TextField(
                controller: userName,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 16),
              Text('What are you pursuing?', style: TextStyle(fontSize: 17)),
              SizedBox(height: 12),
              DropdownSearch<String>(
                items: pursuingOptions,
                selectedItem: selectedPursuing,
                onChanged: (value) => setState(() => selectedPursuing = value),
                popupProps: PopupProps.menu(showSearchBox: true),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Search and select a degree",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 16),

              Text('Select your interests', style: TextStyle(fontSize: 17)),
              SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                children: interests.map((interest) {
                  return ChoiceChip(
                    label: Text(interest),
                    selected: selectedInterests.contains(interest),
                    selectedColor: Color.fromARGB(100, 61, 89, 171),
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? selectedInterests.add(interest)
                            : selectedInterests.remove(interest);
                      });
                    },
                  );
                }).toList(),
              ),
              TextField(
                controller: newInterestController,
                decoration: InputDecoration(hintText: 'Add new interest'),
                onSubmitted: (value) => addCustomOption(value, interests, newInterestController),
              ),
              SizedBox(height: 16),

              Text('What do you want to learn through this app? ', style: TextStyle(fontSize: 17)),
              SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                children: learningGoals.map((goal) {
                  return ChoiceChip(
                    label: Text(goal),
                    selected: selectedLearningGoals.contains(goal),
                    selectedColor: Color.fromARGB(100, 61, 89, 171),
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? selectedLearningGoals.add(goal)
                            : selectedLearningGoals.remove(goal);
                      });
                    },
                  );
                }).toList(),
              ),
              TextField(
                controller: newLearningGoalController,
                decoration: InputDecoration(labelText: 'Add new learning goal'),
                onSubmitted: (value) => addCustomOption(value, learningGoals, newLearningGoalController),
              ),
              SizedBox(height: 16),

              Text('What skill do you want to learn first', style: TextStyle(fontSize: 17)),
              SizedBox(height: 12),
              TextField(
                controller: skillsController,
                decoration: InputDecoration(labelText: 'Write skill name'),
              ),
              Text('Note: Min 20 hrs a month is necessary to learn basics', style: TextStyle(fontSize: 13),),
              SizedBox(height: 16),

              Text('How much free time do you have daily?', style: TextStyle(fontSize: 17)),
              SizedBox(height:10),
              Text(
                'You have $freeTime hours as freetime!',
                textAlign: TextAlign.center,
              ),
              Slider(
                value: freeTime,
                min: 0,
                max: 10,
                divisions: 10,
                label: '$freeTime hours',
                onChanged: (value) {
                  setState(() {
                    freeTime = value;
                  });
                },
              ),
              SizedBox(height: 16),

              Text('What level do u want to learn?', style: TextStyle(fontSize: 17)),
              DropdownButtonFormField<String>(
                value: selectedlevel,
                items: level.map((size) => DropdownMenuItem(value: size, child: Text(size))).toList(),
                onChanged: (value) => setState(() => selectedlevel = value),
                decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Select learning style'),
              ),
              SizedBox(height: 16),
              

              Text('Your Career Goals', style: TextStyle(fontSize: 17)),
              TextField(
                controller: careerGoalsController,
                decoration: InputDecoration(labelText: 'What do you aim for?'),
              ),
              SizedBox(height: 16),

              ElevatedButton(
                onPressed: saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF7F50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
