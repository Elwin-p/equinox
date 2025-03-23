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
  final Color primaryColor = const Color(0xFF4361EE);
  final Color secondaryColor = const Color(0xFF3F8EFC);
  final Color accentColor = const Color(0xFFFF7D00);
  final Color bgColor = const Color(0xFFF8F9FA);
  final Color textPrimary = const Color(0xFF2B2D42);
  final Color textSecondary = const Color(0xFF6C757D);
  final Color cardColor = Colors.white;

  int _currentIndex = 1; 
  String? _selectedChat;
  final TextEditingController _friendIdController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _friends = [];
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  final List<Map<String, dynamic>> _aiPersonas = [
    {
      'name': 'Equinox AI',
      'description': 'Your adaptive learning companion',
      'icon': Icons.auto_awesome,
      'color': Color(0xFF4361EE)
    },
    {
      'name': 'Philosopher',
      'description': 'Deep thoughts and ethical reasoning',
      'icon': Icons.psychology,
      'color': Color(0xFF9381FF)
    },
    {
      'name': 'Astrophysicist',
      'description': 'Cosmic insights and scientific explanations',
      'icon': Icons.stars,
      'color': Color(0xFF4CC9F0)
    },
    {
      'name': 'Engineer',
      'description': 'Practical solutions and technical guidance',
      'icon': Icons.build_circle,
      'color': Color(0xFF5E60CE)
    },
  ];

  @override
  void initState() {
    super.initState();

    _friends.add('DemoFriend123');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(() {
        // Only attempt to scroll when messages exist
        if (_messages.isNotEmpty) {
          _scrollToBottom();
        }
      });
    });
  }

  @override
  void dispose() {
    _friendIdController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addFriend() {
    if (_friendIdController.text.isNotEmpty) {
      setState(() {
        _friends.add(_friendIdController.text);
        _friendIdController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend added successfully'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty && _selectedChat != null) {
      final String messageText = _messageController.text;
      
      setState(() {
        _messages.add({
          'sender': 'You',
          'text': messageText,
          'timestamp': DateTime.now().toString().substring(11, 16), // HH:MM format
          'isRead': true,
        });
        _messageController.clear();
        _isTyping = true;
      });

      // Scroll to bottom after sending message
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      
      // Simulate AI response with typing indicator
      if (_aiPersonas.any((ai) => ai['name'] == _selectedChat)) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _isTyping = false;
            _messages.add({
              'sender': _selectedChat!,
              'text': 'This is a response from $_selectedChat. I can provide customized assistance based on your needs.',
              'timestamp': DateTime.now().toString().substring(11, 16),
              'isRead': false,
            });
          });
          
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      }
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
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double contentHeight = screenHeight - 
        AppBar().preferredSize.height - 
        MediaQuery.of(context).padding.top - 
        kBottomNavigationBarHeight;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: textPrimary,
            fontSize: 20,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded),
            color: textSecondary,
            onPressed: () {
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            color: textSecondary,
            onPressed: () {
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: constraints.maxWidth < 800 ? 800 : constraints.maxWidth,
              height: contentHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Panel: Contacts and AI Assistants
                  Container(
                    width: 300,
                    height: contentHeight,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Conversations',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _friendIdController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Friend ID',
                                    hintStyle: GoogleFonts.poppins(color: textSecondary, fontSize: 14),
                                    fillColor: bgColor,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  elevation: 0,
                                ),
                                onPressed: _addFriend,
                                child: Text(
                                  'Add',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(color: bgColor, thickness: 1),
                        
                        // Friends Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          child: Text(
                            'Friends',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: _friends.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.people_outline, color: textSecondary.withOpacity(0.5), size: 40),
                                      SizedBox(height: 8),
                                      Text(
                                        'No friends added yet',
                                        style: GoogleFonts.poppins(color: textSecondary, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _friends.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ContactTile(
                                      name: _friends[index],
                                      isSelected: _selectedChat == _friends[index],
                                      onTap: () => setState(() => _selectedChat = _friends[index]),
                                      primaryColor: primaryColor,
                                    );
                                  },
                                ),
                        ),
                        
                        Divider(color: bgColor, thickness: 1),
                        
                        // AI Assistants Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          child: Text(
                            'AI Assistants',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ListView.builder(
                            itemCount: _aiPersonas.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            physics: AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final ai = _aiPersonas[index];
                              return AIPersonaTile(
                                name: ai['name'],
                                description: ai['description'],
                                icon: ai['icon'],
                                color: ai['color'],
                                isSelected: _selectedChat == ai['name'],
                                onTap: () => setState(() => _selectedChat = ai['name']),
                                primaryColor: primaryColor,
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
                      height: contentHeight,
                      margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: _selectedChat == null
                          ? EmptyChatView(accentColor: accentColor)
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Chat Header
                                ChatHeader(
                                  name: _selectedChat!,
                                  isAI: _aiPersonas.any((ai) => ai['name'] == _selectedChat),
                                  primaryColor: primaryColor,
                                  icon: _aiPersonas.firstWhere(
                                    (ai) => ai['name'] == _selectedChat,
                                    orElse: () => {'icon': Icons.person_outline},
                                  )['icon'],
                                ),
                                
                                // Messages Area - Fix to prevent overflow
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      itemCount: _messages.length,
                                      itemBuilder: (context, index) {
                                        final message = _messages[index];
                                        final isUser = message['sender'] == 'You';
                                        
                                        return MessageBubble(
                                          text: message['text'],
                                          timestamp: message['timestamp'],
                                          isUser: isUser,
                                          primaryColor: primaryColor,
                                          textColor: textPrimary,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                
                                // Typing indicator
                                if (_isTyping)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20, bottom: 8),
                                      child: Text(
                                        '$_selectedChat is typing...',
                                        style: GoogleFonts.poppins(
                                          color: textSecondary,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                // Message Input - Fix to prevent overflow
                                MessageInput(
                                  controller: _messageController,
                                  onSend: _sendMessage,
                                  primaryColor: primaryColor,
                                  bgColor: bgColor,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationItemTapped,
        primaryColor: primaryColor,
        textSecondary: textSecondary,
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;

  const ContactTile({
    Key? key,
    required this.name,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? primaryColor : Colors.grey[300],
        child: Text(
          name[0].toUpperCase(),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}

class AIPersonaTile extends StatelessWidget {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;

  const AIPersonaTile({
    Key? key,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? primaryColor : color.withOpacity(0.8),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        description,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[600],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}

class ChatHeader extends StatelessWidget {
  final String name;
  final bool isAI;
  final Color primaryColor;
  final IconData icon;

  const ChatHeader({
    Key? key,
    required this.name,
    required this.isAI,
    required this.primaryColor,
    this.icon = Icons.person_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryColor,
            child: isAI 
                ? Icon(icon, color: Colors.white, size: 20)
                : Text(
                    name[0],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isAI)
                  Text(
                    'AI Assistant',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: primaryColor,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.call_outlined, color: primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String timestamp;
  final bool isUser;
  final Color primaryColor;
  final Color textColor;

  const MessageBubble({
    Key? key,
    required this.text,
    required this.timestamp,
    required this.isUser,
    required this.primaryColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isUser ? 64 : 0,
          right: isUser ? 0 : 64,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: isUser ? Radius.circular(16) : Radius.circular(4),
            bottomRight: isUser ? Radius.circular(4) : Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                color: isUser ? Colors.white : textColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timestamp,
              style: GoogleFonts.poppins(
                color: isUser ? Colors.white70 : Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Color primaryColor;
  final Color bgColor;

  const MessageInput({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.primaryColor,
    required this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file_rounded, color: Colors.grey[600]),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  isDense: true,
                ),
                maxLines: 3, 
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyChatView extends StatelessWidget {
  final Color accentColor;

  const EmptyChatView({
    Key? key,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: accentColor.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a friend or AI assistant from the list',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color primaryColor;
  final Color textSecondary;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.primaryColor,
    required this.textSecondary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: textSecondary,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
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
    );
  }
}