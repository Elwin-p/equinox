import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String userName = "User"; // Default name
  double progress = 0.0;
  int completedSubtopics = 0;
  int totalSubtopics = 8; // Adjust as needed
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Add theme colors
  final Color primaryColor = Color(0xFF2D31FA);
  final Color secondaryColor = Color(0xFF5D8BF4);
  final Color accentColor = Color(0xFFFF8C32);
  final Color bgColor = Color(0xFFF9F9F9);
  
  // Countdown timer values (for animation)
  final int days = 10;
  final int hours = 12;
  final int minutes = 30;

  Map<String, List<String>> learningPath = {
    'Flutter Development': ['Widgets', 'State Management', 'Navigation', 'Networking'],
    'Machine Learning': ['Supervised Learning', 'Unsupervised Learning', 'Deep Learning', 'Model Deployment'],
  };

  Map<String, Set<String>> completedTopics = {};

  @override
  void initState() {
    super.initState();
    loadUserName();
    
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
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "User";
    });
  }

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
      progress = completedSubtopics / totalSubtopics;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40), // Equinox Logo
            const Spacer(),
            _buildStreakIndicator(),
            const SizedBox(width: 16),
            Icon(Icons.notifications_outlined, color: Colors.black54), // Notifications
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: const CircleAvatar(backgroundColor: Colors.grey, radius: 16), // Profile Icon
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message with animated text
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
                const SizedBox(height: 24),

                // Animated Countdown Timer
                _buildCountdownTimer(),
                const SizedBox(height: 24),

                // Learning Path Section with progress summary
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Your Learning Path",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$completedSubtopics/$totalSubtopics completed",
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

                // Learning paths with animations
                Expanded(
                  child: AnimationLimiter(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: learningPath.keys.length,
                      itemBuilder: (context, index) {
                        String topic = learningPath.keys.elementAt(index);
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildTopicCard(topic),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Circular Progress Indicator with animation
                _buildProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildCountdownTimer() {
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
              Icon(Icons.timer_outlined, color: Colors.white, size: 24),
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
              _buildTimeUnit("$hours", "hours"),
              _buildTimeSeparator(),
              _buildTimeUnit("$minutes", "mins"),
            ],
          ),
        ],
      ),
    );
  }

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

 Widget _buildTopicCard(String topic) {
  List<String> subtopics = learningPath[topic]!;
  int completedCount = completedTopics[topic]?.length ?? 0;
  double topicProgress = subtopics.isEmpty ? 0 : completedCount / subtopics.length;

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
        title: Row(
          children: [
            Expanded(
              child: Text(
                topic,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "$completedCount/${subtopics.length}",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8, right: 8),
          child: LinearProgressIndicator(
            value: topicProgress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: secondaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            topic.contains('Flutter') 
                ? Icons.dashboard_customize_outlined 
                : Icons.psychology_outlined,
            color: secondaryColor,
          ),
        ),
        iconColor: primaryColor,
        collapsedIconColor: Colors.grey[500],
        children: subtopics.map((subtopic) {
          bool isCompleted = completedTopics[topic]?.contains(subtopic) ?? false;
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
                overflow: TextOverflow.ellipsis,
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

  Widget _buildProgressIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, animatedProgress, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                      "Keep going, you're doing great!",
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