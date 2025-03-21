import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage.dart';

class HiringScreen extends StatefulWidget {
  const HiringScreen({Key? key}) : super(key: key);

  @override
  _HiringScreenState createState() => _HiringScreenState();
}

class _HiringScreenState extends State<HiringScreen> {
  // Form controllers
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyWebsiteController = TextEditingController();
  final TextEditingController _companyLinkedInController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  // Selected values
  String? _selectedSector;
  String? _selectedCompanySize;
  
  // Theme colors - matching LearnerScreen
  final Color _primaryColor = const Color(0xFF2D31FA);
  final Color _secondaryColor = const Color(0xFF5D8BF4);
  final Color _accentColor = const Color(0xFFFF8C32);
  final Color _bgColor = const Color(0xFFF9F9F9);
  
  // Lists of options
  List<String> _sectors = [];
  final List<String> _companySizes = [
    'Small (1-10)', 
    'Medium (11-100)', 
    'Large (100+)'
  ];

  @override
  void initState() {
    super.initState();
    _loadIndustries();
  }

  /// Loads industry sectors from JSON asset
  Future<void> _loadIndustries() async {
    try {
      String jsonString = await rootBundle.loadString('assets/sector.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        _sectors = List<String>.from(jsonData["industries"]);
      });
    } catch (e) {
      debugPrint('Error loading industry sectors: $e');
    }
  }

  /// Saves hirer data to Firestore and SharedPreferences
  Future<void> _saveData() async {
    // Validate required fields
    if (_companyNameController.text.trim().isEmpty ||
        _companyWebsiteController.text.trim().isEmpty ||
        _companyLinkedInController.text.trim().isEmpty ||
        _selectedSector == null ||
        _selectedCompanySize == null ||
        _locationController.text.trim().isEmpty) {
      
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
    
    // Basic URL validation for website
    if (!_companyWebsiteController.text.trim().startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter a valid website URL starting with http:// or https://",
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

      // Save company name locally
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('company_name', _companyNameController.text);
    
      // Save all data to Firestore
      await FirebaseFirestore.instance.collection('hirers').add({
        'companyName': _companyNameController.text.trim(),
        'companyWebsite': _companyWebsiteController.text.trim(),
        'companyLinkedIn': _companyLinkedInController.text.trim(),
        'sector': _selectedSector,
        'companySize': _selectedCompanySize,
        'location': _locationController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Close loading dialog and navigate to home
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const HomePage())
        );
      }
    } catch (e) {
      // Close loading dialog and show error
      if (mounted) {
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
        'Company Profile',
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
            _buildSectionTitle('Company Name *'),
            _buildTextField(
              controller: _companyNameController,
              labelText: 'Company Name',
              hintText: 'Enter your company name',
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Company Website *'),
            _buildTextField(
              controller: _companyWebsiteController,
              labelText: 'Website URL',
              hintText: 'https://www.example.com',
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Company LinkedIn *'),
            _buildTextField(
              controller: _companyLinkedInController,
              labelText: 'LinkedIn Profile',
              hintText: 'https://www.linkedin.com/company/example',
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Industry Sector *'),
            const SizedBox(height: 8),
            _buildSectorDropdown(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Company Size *'),
            const SizedBox(height: 8),
            _buildCompanySizeDropdown(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Location *'),
            _buildTextField(
              controller: _locationController,
              labelText: 'Location',
              hintText: 'City, Country',
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

  /// Builds dropdown for sector options
  Widget _buildSectorDropdown() {
    return DropdownSearch<String>(
      items: _sectors,
      selectedItem: _selectedSector,
      onChanged: (value) => setState(() => _selectedSector = value),
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
          labelText: "Search and select a sector",
          labelStyle: GoogleFonts.poppins(),
          hintText: "Select industry sector",
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
          selectedItem ?? "Select industry sector",
          style: GoogleFonts.poppins(
            color: selectedItem == null ? Colors.grey : Colors.black87,
          ),
        );
      },
    );
  }

  /// Builds dropdown for company size options
  Widget _buildCompanySizeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCompanySize,
      items: _companySizes.map((size) {
        return DropdownMenuItem<String>(
          value: size,
          child: Text(
            size,
            style: GoogleFonts.poppins(color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCompanySize = value;
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
        hintText: 'Select company size',
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
    _companyNameController.dispose();
    _companyWebsiteController.dispose();
    _companyLinkedInController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}