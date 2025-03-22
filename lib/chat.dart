import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage.dart';
import 'community.dart';
import 'bookborrow.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final Color primaryColor = const Color(0xFF2D31FA);
  final Color secondaryColor = const Color(0xFF5D8BF4);
  final Color accentColor = const Color(0xFFFF8C32);
  final Color bgColor = const Color(0xFFF9F9F9);

  int _currentIndex = 1; // Chat tab active
  String? _selectedChat; // Tracks the selected chat (friend ID or AI persona)
  final TextEditingController _friendIdController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final List<String> _friends = []; // Dummy friend list
  final List<Map<String, String>> _messages = []; // Dummy message list

  // AI personas available for chat
  final List<Map<String, String>> _aiPersonas = [
    {'name': 'Equinox AI', 'description': 'Your learning companion'},
    {'name': 'Philosopher', 'description': 'Deep thoughts and wisdom'},
    {'name': 'Astrophysicist', 'description': 'Cosmic insights'},
    {'name': 'Engineer', 'description': 'Practical solutions'},
  ];

  void _addFriend() {
    if (_friendIdController.text.isNotEmpty) {
      setState(() {
        _friends.add(_friendIdController.text);
        _friendIdController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend added: ${_friends.last}')),
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty && _selectedChat != null) {
      setState(() {
        _messages.add({
          'sender': 'You',
          'text': _messageController.text,
          'timestamp': DateTime.now().toString().substring(11, 16), // HH:MM format
        });
        // Simulate AI response (for demo purposes)
        if (_aiPersonas.any((ai) => ai['name'] == _selectedChat)) {
          _messages.add({
            'sender': _selectedChat!,
            'text': 'This is a response from $_selectedChat. (AI simulation)',
            'timestamp': DateTime.now().toString().substring(11, 16),
          });
        }
      });
      _messageController.clear();
    }
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CommunityForum()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BookBorrowMap()));
    }
    // Index 1 (Chat) is already here, so no navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Messages', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.grey[600],
            onPressed: () {
              // Search functionality can be added later
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel: Friends and AI Personas
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5)],
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Chat', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                ),
                // Add Friend Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _friendIdController,
                          decoration: InputDecoration(
                            hintText: 'Enter Friend ID',
                            hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _addFriend,
                        child: Text('Add', style: GoogleFonts.poppins()),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Friends List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Friends', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_friends[index], style: GoogleFonts.poppins(fontSize: 14)),
                        onTap: () => setState(() => _selectedChat = _friends[index]),
                        selected: _selectedChat == _friends[index],
                        selectedTileColor: primaryColor.withOpacity(0.1),
                      );
                    },
                  ),
                ),
                const Divider(),
                // AI Personas List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('AI Assistants', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _aiPersonas.length,
                    itemBuilder: (context, index) {
                      final ai = _aiPersonas[index];
                      return ListTile(
                        title: Text(ai['name']!, style: GoogleFonts.poppins(fontSize: 14)),
                        subtitle: Text(ai['description']!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                        onTap: () => setState(() => _selectedChat = ai['name']),
                        selected: _selectedChat == ai['name'],
                        selectedTileColor: primaryColor.withOpacity(0.1),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Right Panel: Chat Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5)],
              ),
              child: _selectedChat == null
                  ? Center(
                      child: Text(
                        'Select a friend or AI to start chatting',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                  : Column(
                      children: [
                        // Chat Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.05),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: primaryColor,
                                child: Text(_selectedChat![0], style: GoogleFonts.poppins(color: Colors.white)),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _selectedChat!,
                                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        // Messages Area
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isUser = message['sender'] == 'You';
                              return Align(
                                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isUser ? primaryColor : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message['text']!,
                                        style: GoogleFonts.poppins(
                                          color: isUser ? Colors.white : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        message['timestamp']!,
                                        style: GoogleFonts.poppins(
                                          color: isUser ? Colors.white70 : Colors.grey[600],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Message Input
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: InputDecoration(
                                    hintText: 'Type a message...',
                                    hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.send, color: primaryColor),
                                onPressed: _sendMessage,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onNavigationItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school), label: 'Learn'),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), activeIcon: Icon(Icons.chat_bubble_outlined), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: 'Community'),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Library'),
            ],
          ),
        ),
      ),
    );
  }
}