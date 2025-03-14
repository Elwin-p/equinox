import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dropdown_search/dropdown_search.dart';

class LearnerScreen extends StatefulWidget {
  @override
  _LearnerScreenState createState() => _LearnerScreenState();
}

class _LearnerScreenState extends State<LearnerScreen> {
  String? selectedPursuing;
  List<String> pursuingOptions = [];
  List<String> selectedInterests = [];
  List<String> interests = [
    'AI & ML', 'Web Development', 'Cybersecurity', 'Data Science', 'Blockchain',
    'Game Development', 'AR/VR', 'IoT', 'Cloud Computing', 'UI/UX Design'
  ];
  TextEditingController newInterestController = TextEditingController();

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

  double freeTime = 2; // Default hours per day
  TextEditingController thoughtsController = TextEditingController();
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
              Text('What are you pursuing?', style: TextStyle(fontSize: 17),),
              SizedBox(height: 12,),
              DropdownSearch<String>(
                items: pursuingOptions,
                selectedItem: selectedPursuing,
                onChanged: (value) {
                  setState(() {
                    selectedPursuing = value;
                  });
                },
                popupProps: PopupProps.menu(showSearchBox: true),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Search and select a degree",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 16),

              Text('Select your interests', style: TextStyle(fontSize: 17),),
              SizedBox(height: 12),
              Wrap(
                spacing: 8.0, // Space between chips
                children: interests.map((interest) {
                  return ChoiceChip(
                    label: Text(interest),
                    selected: selectedInterests.contains(interest),
                    selectedColor: const Color.fromARGB(100, 61, 89, 171), // Change selected color
                    showCheckmark: false, // Remove tick mark
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

              Text('What skills do you know?', style: TextStyle(fontSize: 17),),
              SizedBox(height: 12),
              Wrap(
                spacing: 8.0, // Space between chips
                children: skills.map((skill) {
                  return ChoiceChip(
                    label: Text(skill),
                    selected: selectedSkills.contains(skill),
                    showCheckmark: false, // Remove tick mark
                    selectedColor: const Color.fromARGB(100, 61, 89, 171), // Change selected color
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? selectedSkills.add(skill)
                            : selectedSkills.remove(skill);
                        if (!selected) skillRatings.remove(skill);
                      });
                    },
                  );
                }).toList(),
              ),
              TextField(
                controller: newSkillController,
                decoration: InputDecoration(labelText: 'Add new skill'),
                onSubmitted: (value) => addCustomOption(value, skills, newSkillController),
              ),

              SizedBox(height: 16),
              ...selectedSkills.map((skill) {
                return Column(
                  children: [
                    Text('$skill Rating: ${skillRatings[skill] ?? 0}'),
                    Slider(
                      value: skillRatings[skill] ?? 0,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: '${skillRatings[skill] ?? 0}',
                      onChanged: (value) {
                        setState(() {
                          skillRatings[skill] = value;
                        });
                      },
                    ),
                  ],
                );
              }),
              SizedBox(height: 16),

              Text('What do you want to learn?', style: TextStyle(fontSize: 17),),
              SizedBox(height: 12),
              Wrap(
                spacing: 8.0, // Space between chips
                children: learningGoals.map((goal) {
                  return ChoiceChip(
                    label: Text(goal),
                    selected: selectedLearningGoals.contains(goal),
                    showCheckmark: false, // Remove tick mark
                    selectedColor: const Color.fromARGB(100, 61, 89, 171), // Change selected color
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

              Text(
                'How much free time do you have daily?',
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(height: 12),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Centers the content vertically
                  children: [
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
                  ],
                ),
              ),
              SizedBox(height: 16),

              Text('Your thoughts on your learning skills', style: TextStyle(fontSize: 17),),
              TextField(
                controller: thoughtsController,
                decoration: InputDecoration(labelText: 'Write your thoughts'),
              ),
              SizedBox(height: 16),

              Text('Your Career Goals', style: TextStyle(fontSize: 17),),
              TextField(
                controller: careerGoalsController,
                decoration: InputDecoration(labelText: 'What do you aim for?'),
              ),
              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  // Process user data here
                },
                child: Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
