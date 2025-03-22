//this is homepage

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'gemini.dart';
import 'bookborrow.dart'; // Import the bookborrow.dart file

class HomePage extends StatefulWidget {
  final String? skill;
  final int? hoursPerDay;
  final String? level;

  const HomePage({
    Key? key, 
    this.skill, 
    this.hoursPerDay, 
    this.level
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // User properties
  String userName = "User"; // Default name
  double progress = 0.0;
  int completedSubtopics = 0;
  int _currentIndex = 0; // For bottom navigation
  Map<String, dynamic>? learningData;
  bool isLoading = true;
  String error = '';
  int estimatedDays = 0;
  int totalSubtopics = 0;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Theme colors
  final Color primaryColor = const Color(0xFF2D31FA);
  final Color secondaryColor = const Color(0xFF5D8BF4);
  final Color accentColor = const Color(0xFFFF8C32);
  final Color bgColor = const Color(0xFFF9F9F9);
  
  // Completed topics tracking
  final Map<String, Set<String>> completedTopics = {};

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Load user data and learning path
    _initializeData();
  }

  /// Initialize all required data
  Future<void> _initializeData() async {
    await loadUserName();
    await _loadLearningPath();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Loads the user name from SharedPreferences
  Future<void> loadUserName() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userName = prefs.getString('user_name') ?? "User";
      });
    } catch (e) {
      debugPrint('Error loading username: $e');
    }
  }

  /// Loads learning path data from Gemini service
  Future<void> _loadLearningPath() async {
    if (widget.skill == null || widget.hoursPerDay == null || widget.level == null) {
      setState(() {
        error = 'Missing required parameters';
        isLoading = false;
      });
      return;
    }

    try {
      final data = await GeminiService.getLearningPath(
        widget.skill!,
        widget.hoursPerDay!,
        widget.level!,
      );

      if (mounted) {
        setState(() {
          learningData = data;
          estimatedDays = data['estimatedDays'] ?? 30;
          
          // Calculate total subtopics
          totalSubtopics = 0;
          final topics = List<Map<String, dynamic>>.from(data['topics'] ?? []);
          for (var topic in topics) {
            final subtopics = List<String>.from(topic['subtopics'] ?? []);
            totalSubtopics += subtopics.length;
          }
          
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to load learning path: $e';
          isLoading = false;
        });
      }
    }
  }

  /// Toggles the completion status of a subtopic
  void toggleSubtopicCompletion(String topic, String subtopic) {
    setState(() {
      completedTopics.putIfAbsent(topic, () => <String>{});
      
      if (completedTopics[topic]!.contains(subtopic)) {
        completedTopics[topic]!.remove(subtopic);
        completedSubtopics--;
      } else {
        completedTopics[topic]!.add(subtopic);
        completedSubtopics++;
      }
      
      progress = totalSubtopics > 0 ? completedSubtopics / totalSubtopics : 0;
    });
  }

  /// Handle navigation when bottom nav items are tapped
  void _onNavigationItemTapped(int index) {
    if (index == 3) {
      // Library icon - navigate to BookBorrow page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BookBorrowMap()),
      );
    } else {
      // For other tabs, just update the index
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Builds the app bar with logo, streak indicator, and user profile
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false, // This removes the back button
      title: Row(
        children: [
          Image.asset('assets/logo.png', height: 40),
          const Spacer(),
          _buildStreakIndicator(),
          const SizedBox(width: 16),
          const Icon(Icons.notifications_outlined, color: Colors.black54),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 2),
            ),
            child: const CircleAvatar(backgroundColor: Colors.grey, radius: 16),
          ),
        ],
      ),
    );
  }

  /// Builds the main body content with animations
  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildCountdownTimer(),
                const SizedBox(height: 24),
                _buildLearningPathSection(),
                const SizedBox(height: 32), // Add spacing
                _buildProgressIndicator(),
                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the welcome section with animated text
  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back,",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              userName,
              textStyle: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              speed: const Duration(milliseconds: 100),
            ),
          ],
          totalRepeatCount: 1,
        ),
        const SizedBox(height: 4),
        Text(
          "Your journey starts now",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Builds the learning path section with animations
  Widget _buildLearningPathSection() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                error,
                style: GoogleFonts.poppins(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final topics = List<Map<String, dynamic>>.from(learningData?['topics'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Your Learning Path",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$completedSubtopics/$totalSubtopics",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        topics.isEmpty 
          ? _buildEmptyState()
          : AnimationLimiter(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  final subtopics = List<String>.from(topic['subtopics'] ?? []);
                  
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildTopicCard(
                          topic['name'],
                          subtopics,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }

  /// Builds empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Colors.grey[400],
            
          ),
          const SizedBox(height: 16),
          Text(
            "No learning path available",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavigationItemTapped, // Use the new navigation handler
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_outlined),
              label: 'chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Library',
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the streak indicator widget
  Widget _buildStreakIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: accentColor, size: 20),
          const SizedBox(width: 4),
          Text(
            'Day 0',
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the countdown timer display
  Widget _buildCountdownTimer() {
    final int days = estimatedDays;
    final int hours = widget.hoursPerDay ?? 0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                "Course deadline",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeUnit("$days", "days"),
              _buildTimeSeparator(),
              _buildTimeUnit("$hours", "hours/day"),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single time unit display for the countdown timer
  Widget _buildTimeUnit(String value, String unit) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          unit,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Builds a separator for the countdown timer
  Widget _buildTimeSeparator() {
    return Text(
      ":",
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Builds a topic card with expansion functionality
  Widget _buildTopicCard(String topic, List<String> subtopics) {
    // Determine completion count for this topic
    final completedCount = completedTopics[topic]?.length ?? 0;
    final topicProgress = subtopics.isEmpty ? 0.0 : completedCount / subtopics.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          childrenPadding: EdgeInsets.zero,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            topic,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: topicProgress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$completedCount/${subtopics.length}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTopicIcon(topic),
              color: secondaryColor,
            ),
          ),
          iconColor: primaryColor,
          collapsedIconColor: Colors.grey[500],
          children: subtopics.map((subtopic) {
            final bool isCompleted = completedTopics[topic]?.contains(subtopic) ?? false;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: isCompleted ? Colors.green.withOpacity(0.05) : Colors.transparent,
              child: ListTile(
                title: Text(
                  subtopic,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Colors.grey : Colors.black87,
                  ),
                ),
                trailing: InkWell(
                  onTap: () => toggleSubtopicCompletion(topic, subtopic),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle_outlined,
                      color: isCompleted ? Colors.white : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 32),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Returns appropriate icon based on topic name
  IconData _getTopicIcon(String topic) {
    final topicLower = topic.toLowerCase();
    
    if (topicLower.contains('flutter') || topicLower.contains('ui') || topicLower.contains('front')) {
      return Icons.dashboard_customize_outlined;
    } else if (topicLower.contains('machine') || topicLower.contains('ai') || topicLower.contains('data')) {
      return Icons.psychology_outlined;
    } else if (topicLower.contains('basic') || topicLower.contains('intro') || topicLower.contains('concept')) {
      return Icons.lightbulb_outline;
    } else if (topicLower.contains('advanced') || topicLower.contains('expert')) {
      return Icons.architecture_outlined;
    } else if (topicLower.contains('backend') || topicLower.contains('server') || topicLower.contains('database')) {
      return Icons.storage_outlined;
    } else if (topicLower.contains('project') || topicLower.contains('build')) {
      return Icons.build_outlined;
    }
    
    return Icons.code_outlined;
  }

  /// Builds the circular progress indicator with animation
  Widget _buildProgressIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, animatedProgress, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
              margin: const EdgeInsets.only(top: 20), // Add top margin
          child: Center(
            child: Column(
              children: [
                CircularPercentIndicator(
                  radius: 65.0,
                  lineWidth: 12.0,
                  animation: true,
                  animationDuration: 1500,
                  percent: animatedProgress,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${(animatedProgress * 100).toInt()}%",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        "Complete",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  progressColor: secondaryColor,
                  backgroundColor: Colors.grey[200]!,
                  footer: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      "${learningData?['skill'] ?? widget.skill ?? 'Skill'} Mastery",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}