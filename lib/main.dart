import 'package:flutter/material.dart';
import 'splashscreen.dart'; // Import the splash screen

void main() {
  runApp(const MyApp());
   debugProfileBuildsEnabled = true; // Show UI performance issues
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Equinox',
      theme: ThemeData(
        primaryColor: const Color(0xFF3D59AB), // Deep Blue
        useMaterial3: true, // Enables Material 3 for a modern UI
      ),
      home: const SplashScreen(), // Set SplashScreen as the home
      debugShowCheckedModeBanner: false,
    );
  }
}
