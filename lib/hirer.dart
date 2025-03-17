import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';

class HiringScreen extends StatefulWidget {
  @override
  _HiringScreenState createState() => _HiringScreenState();
}

class _HiringScreenState extends State<HiringScreen> {
  TextEditingController companyNameController = TextEditingController();
  TextEditingController companyWebsiteController = TextEditingController();
  TextEditingController companyLinkedInController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  List<String> sectors = [];
  String? selectedSector;
  String? selectedCompanySize;
  List<String> companySizes = ['Small (1-10)', 'Medium(11-100)', 'Large(100+)'];

  @override
  void initState() {
    super.initState();
    loadIndustries();
  }

  Future<void> loadIndustries() async {
    String jsonString = await rootBundle.loadString('assets/sector.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      sectors = List<String>.from(jsonData["industries"]);
    });
  }

  void saveToFirebase() {
    if (companyNameController.text.isEmpty ||
        companyWebsiteController.text.isEmpty ||
        companyLinkedInController.text.isEmpty ||
        selectedSector == null ||
        selectedCompanySize == null ||
        locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    FirebaseFirestore.instance.collection('hirers').add({
      'companyName': companyNameController.text,
      'companyWebsite': companyWebsiteController.text,
      'companyLinkedIn': companyLinkedInController.text,
      'sector': selectedSector,
      'companySize': selectedCompanySize,
      'location': locationController.text,
    }).then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data. Please try again.')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hiring Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Company Name', style: TextStyle(fontSize: 17)),
              TextField(controller: companyNameController, decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'equinox inc')),
              SizedBox(height: 16),
              
              Text('Company Website', style: TextStyle(fontSize: 17)),
              TextField(controller: companyWebsiteController, decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'https://www.equinoxinc.com')),
              SizedBox(height: 16),
              
              Text('Company LinkedIn', style: TextStyle(fontSize: 17)),
              TextField(controller: companyLinkedInController, decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'https://www.linkedin.com/company/equinox-inc')),
              SizedBox(height: 16),
              
              Text('Sector', style: TextStyle(fontSize: 17)),
              DropdownSearch<String>(
                items: sectors,
                selectedItem: selectedSector,
                onChanged: (value) => setState(() => selectedSector = value),
                popupProps: PopupProps.menu(showSearchBox: true),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: "Select sector",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              Text('Company Size', style: TextStyle(fontSize: 17)),
              DropdownButtonFormField<String>(
                value: selectedCompanySize,
                items: companySizes.map((size) => DropdownMenuItem(value: size, child: Text(size))).toList(),
                onChanged: (value) => setState(() => selectedCompanySize = value),
                decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Select size'),
              ),
              SizedBox(height: 16),
              
              Text('Location', style: TextStyle(fontSize: 17)),
              TextField(controller: locationController, decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Distict,State,County')),
              SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: saveToFirebase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7F50), // Coral Orange button
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
