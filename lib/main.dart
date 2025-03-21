import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splashscreen.dart'; // Import the splash screen
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

 // Load environment variables
  await dotenv.load(fileName: "./.env");
  await Firebase.initializeApp(); // Initialize Firebase before using it

  String apiKey = dotenv.env['API_KEY'] ?? ''; // Fetch API key safely
  if (apiKey.isEmpty) {
    debugPrint("❌ API Key is missing! Check your .env file.");
  } else {
    debugPrint("✅ API Key Loaded Successfully");
    Gemini.init(apiKey: apiKey);
  }

  runApp(const MyApp());
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
