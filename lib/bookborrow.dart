import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'homepage.dart';
import 'community.dart';
import 'chat.dart';


class BookBorrowMap extends StatefulWidget {
  const BookBorrowMap({Key? key}) : super(key: key);

  @override
  _BookBorrowMapState createState() => _BookBorrowMapState();
}

class _BookBorrowMapState extends State<BookBorrowMap> {
  final Completer<GoogleMapController> _controller = Completer();
  
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 5,
  );
  
  LatLng? _selectedPosition;
  String _currentAddress = "Tap map to select location";
  final Set<Marker> _markers = {};
  bool _isLocationShared = false;
  bool _isPinMode = false;
  Timer? _locationUpdateTimer;
  int _currentIndex = 3;
  
  final Color primaryColor = const Color(0xFF2D31FA);
  final Color secondaryColor = const Color(0xFF5D8BF4);
  final Color accentColor = const Color(0xFFFF8C32);
  final Color bgColor = const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    _ensureAnonymousLogin();
    _loadNearbyUsers();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _ensureAnonymousLogin() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged in anonymously')),
          );
        }
      }
    } catch (e) {
      print("Error with anonymous login: $e");
    }
  }

  void _onMapTap(LatLng position) async {
    if (_isPinMode) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        String address = "Unknown location";
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        }

        setState(() {
          _selectedPosition = position;
          _currentAddress = address;
          _markers.removeWhere((marker) => marker.markerId.value == 'selectedLocation');
          _markers.add(
            Marker(
              markerId: const MarkerId('selectedLocation'),
              position: position,
              infoWindow: InfoWindow(
                title: 'Your Selected Location',
                snippet: address,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );
        });

        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
            'location': GeoPoint(position.latitude, position.longitude),
            'address': address,
            'locationShared': true,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          
          _loadNearbyUsers();
        }
      } catch (e) {
        print("Error processing map tap: $e");
      }
    }
  }

  void _togglePinMode() {
    setState(() {
      _isPinMode = !_isPinMode;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isPinMode 
            ? 'Tap map to place your location pin' 
            : 'Pin placement mode disabled'),
      ),
    );
  }

  Future<void> _loadNearbyUsers() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      
      setState(() {
        _markers.removeWhere((marker) => marker.markerId.value != 'selectedLocation');
      });
      
      for (var doc in snapshot.docs) {
        if (doc.id == currentUser.uid) continue;
        
        final userData = doc.data();
        if (userData.containsKey('location') && userData['locationShared'] == true) {
          final GeoPoint location = userData['location'];
          final String address = userData['address'] ?? 'Address unknown';
          
          final booksSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .collection('books')
              .where('available', isEqualTo: true)
              .get();
          
          String bookInfo = '';
          if (booksSnapshot.docs.isNotEmpty) {
            bookInfo = booksSnapshot.docs
                .map((book) => '${book['title']} by ${book['author']}')
                .join('\n');
          } else {
            bookInfo = 'No books available';
          }

          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(location.latitude, location.longitude),
                infoWindow: InfoWindow(
                  title: 'Click to see more details',
                  snippet: '$address\nBooks:\n$bookInfo',
                  onTap: () => _showUserDetails(doc.id, userData),
                ),
              ),
            );
          });
        }
      }
    } catch (e) {
      print("Error loading nearby users: $e");
    }
  }

  void _showUserDetails(String userId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Lender'), 
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address: ${userData['address'] ?? 'Address unknown'}',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text('Available Books:',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('books')
                      .where('available', isEqualTo: true)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return const Text('Error loading books');
                    }
                    
                    final books = snapshot.data?.docs ?? [];
                    
                    if (books.isEmpty) {
                      return const Text('No books available from this user');
                    }
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(book['title'] ?? 'Untitled Book'),
                          subtitle: Text(book['author'] ?? 'Unknown Author'),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Request'),
                            onPressed: () {
                              _sendBorrowRequest(userId, books[index].id);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendBorrowRequest(String ownerId, String bookId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      
      final requesterDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      final String requesterName = requesterDoc.data()?['displayName'] ?? 'Anonymous User';
      
      await FirebaseFirestore.instance.collection('borrowRequests').add({
        'requesterId': currentUser.uid,
        'requesterName': requesterName,
        'ownerId': ownerId,
        'bookId': bookId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Borrow request sent!')),
      );
    } catch (e) {
      print("Error sending borrow request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending request: $e')),
      );
    }
  }

  void _showAddBookDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController bookTitleController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('user_name');
    nameController.text = savedName ?? "Anonymous${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}";
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add a Book to Share', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Your Display Name (Anonymous)',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bookTitleController,
                decoration: InputDecoration(
                  hintText: 'Book Title',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: authorController,
                decoration: InputDecoration(
                  hintText: 'Author',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedPosition == null 
                    ? 'Please select a location on the map first'
                    : 'Selected Address: $_currentAddress',
                style: GoogleFonts.poppins(
                  color: _selectedPosition == null ? Colors.red[700] : Colors.green[700],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[700])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (_selectedPosition == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a location first')),
                );
                return;
              }
              if (nameController.text.isEmpty || bookTitleController.text.isEmpty || authorController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              
              prefs.setString('user_name', nameController.text);
              _addBookToDatabase(nameController.text, bookTitleController.text, authorController.text);
              Navigator.pop(context);
            },
            child: Text('Add Book', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Future<void> _addBookToDatabase(String userName, String bookTitle, String author) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
        currentUser = userCredential.user;
      }
      
      if (currentUser != null && _selectedPosition != null) {
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
          'displayName': userName,
          'location': GeoPoint(_selectedPosition!.latitude, _selectedPosition!.longitude),
          'address': _currentAddress,
          'locationShared': true,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('books')
            .add({
          'title': bookTitle,
          'author': author,
          'available': true,
          'addedAt': FieldValue.serverTimestamp(),
        });
        
        setState(() {
          _isLocationShared = true;
        });
        
        _loadNearbyUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book "$bookTitle" added successfully')),
        );
      }
    } catch (e) {
      print("Error adding book: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding book: $e')),
      );
    }
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } 
    else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatPage()),
      );
    }
    else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CommunityForum()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Borrow Map', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isPinMode ? Icons.pin_drop : Icons.pin_drop_outlined),
            color: _isPinMode ? primaryColor : null,
            onPressed: _togglePinMode,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _currentAddress,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.blue[800],
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialPosition,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: _onMapTap,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addBook',
        backgroundColor: accentColor,
        onPressed: _showAddBookDialog,
        child: const Icon(Icons.add_outlined),
      ),
      bottomNavigationBar: Container(
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
            onTap: _onNavigationItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school), label: 'Learn'),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), activeIcon: Icon(Icons.chat_bubble_outlined), label: 'chat'),
              BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: 'Community'),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Library'),
            ],
          ),
        ),
      ),
    );
  }
}