import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'splashscreen.dart'; 
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await dotenv.load(fileName: "./.env");
  await Firebase.initializeApp(); 

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  debugPrint("✅ Firebase App Check Activated");

  String apiKey = dotenv.env['API_KEY'] ?? ''; 
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
        primaryColor: const Color(0xFF3D59AB), 
        useMaterial3: true, 
      ),
      home: const SplashScreen(), 
      debugShowCheckedModeBanner: false,
    );
  }
}