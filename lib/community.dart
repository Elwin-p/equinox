import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage.dart';
import 'bookborrow.dart';
import 'chat.dart';

class CommunityForum extends StatefulWidget {
  const CommunityForum({Key? key}) : super(key: key);

  @override
  _CommunityForumState createState() => _CommunityForumState();
}

class _CommunityForumState extends State<CommunityForum> {
  final Color primaryColor = const Color(0xFF3366FF);
  final Color secondaryColor = const Color(0xFF6699FF);
  final Color accentColor = const Color(0xFFFF9966);
  final Color bgColor = const Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF2D3748);
  final Color textSecondaryColor = const Color(0xFF718096);

  int _currentIndex = 2; 
  final List<Map<String, String>> hirerPosts = [
    {
      'title': 'Looking for Math Tutor',
      'content': 'Need an experienced math tutor for high school students. Hourly rate: \$30',
      'author': 'Hirer123',
      'timestamp': '2 hours ago',
    },
    {
      'title': 'Programming Mentor Needed',
      'content': 'Seeking a Python expert for weekly sessions. Budget: \$50/hr',
      'author': 'CodeHirer',
      'timestamp': '1 day ago',
    },
  ];

  final List<Map<String, dynamic>> learnerPosts = [
    {
      'title': 'How to understand calculus better?',
      'content': 'Struggling with derivatives, any tips?',
      'author': 'MathLearner',
      'timestamp': '3 hours ago',
      'votes': 12,
      'comments': [
        {
          'content': 'Try watching 3Blue1Brown videos on YouTube!',
          'author': 'HelpfulUser',
          'timestamp': '2 hours ago',
          'votes': 5,
        },
      ],
    },
    {
      'title': 'Best way to learn Python?',
      'content': 'New to coding, where should I start?',
      'author': 'CodeNewbie',
      'timestamp': '5 hours ago',
      'votes': 8,
      'comments': [],
    },
  ];

  void _onNavigationItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookBorrowMap()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Community Forum',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: textSecondaryColor,
            onPressed: () {
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            color: textSecondaryColor,
            onPressed: () {
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildFilterChips(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Hirer Announcements', Icons.work_outline),
              const SizedBox(height: 12),
              _buildSectionContainer(
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: secondaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'View-only for Learners',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: secondaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...hirerPosts.map((post) => _buildHirerPost(post)).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('Learner Q&A', Icons.question_answer_outlined),
              const SizedBox(height: 12),
              _buildSectionContainer(
                Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Ask a question...',
                        hintStyle: GoogleFonts.poppins(color: textSecondaryColor),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.help_outline),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.send_rounded, 
                            color: Colors.white, 
                            size: 20
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Posts
                    ...learnerPosts.map((post) => _buildLearnerPost(post)).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onNavigationItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: cardColor,
            selectedItemColor: primaryColor,
            unselectedItemColor: textSecondaryColor,
            selectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                activeIcon: Icon(Icons.school),
                label: 'Learn',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chat',
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
      ),
    );
  }

  Widget _buildFilterChips() {
    final List<String> filters = ['All Posts', 'Questions', 'Announcements', 'Trending'];
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final bool isSelected = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filters[index],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isSelected ? Colors.white : textSecondaryColor,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              backgroundColor: Colors.white,
              selectedColor: primaryColor,
              checkmarkColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey[300]!,
                ),
              ),
              onSelected: (bool selected) {
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionContainer(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHirerPost(Map<String, String> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.business_center, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title']!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimaryColor,
                      ),
                    ),
                    Text(
                      'Posted by ${post['author']} • ${post['timestamp']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.bookmark_border, color: textSecondaryColor),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post['content']!,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: textPrimaryColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.send_rounded, size: 16),
                label: Text(
                  'Apply',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
              ),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(Icons.share_outlined, size: 16, color: textSecondaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Share',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLearnerPost(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Voting Column
              Column(
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.arrow_drop_up, 
                      size: 32,
                      color: post['votes'] > 0 ? primaryColor : textSecondaryColor,
                    ),
                    onPressed: () {},
                  ),
                  Text(
                    '${post['votes']}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: post['votes'] > 0 ? primaryColor : textSecondaryColor,
                    ),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.arrow_drop_down, 
                      size: 32,
                      color: textSecondaryColor,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title']!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post['content']!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: textPrimaryColor.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Asked by ${post['author']} • ${post['timestamp']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.comment_outlined, size: 18),
                label: Text(
                  '${post['comments'].length} Comments',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: secondaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                onPressed: () {},
              ),
              Row(
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    icon: Icon(Icons.bookmark_border, size: 20, color: textSecondaryColor),
                    onPressed: () {},
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    icon: Icon(Icons.share_outlined, size: 20, color: textSecondaryColor),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          if (post['comments'].isNotEmpty) ...[
            const Divider(height: 24),
            ...post['comments'].map((comment) => _buildComment(comment)).toList(),
          ],
          const SizedBox(height: 16),
          // Comment input field
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFEEEEEE),
                child: Icon(Icons.person_outline, size: 20, color: Color(0xFF666666)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: GoogleFonts.poppins(color: textSecondaryColor, fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send_rounded, color: primaryColor, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComment(Map<String, dynamic> comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFEEEEEE),
            child: Icon(Icons.person_outline, size: 20, color: Color(0xFF666666)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment['author'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment['timestamp'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment['content'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textPrimaryColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.thumb_up_outlined,
                              size: 14,
                              color: textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${comment['votes']}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Reply',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: secondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}