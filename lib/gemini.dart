import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:convert';

class GeminiService {
  static final gemini = Gemini.instance;

  static Future<Map<String, dynamic>> getLearningPath(String skill, int hoursPerDay, String level) async {
    final prompt = '''
    Generate a structured learning path for $skill at $level level for someone who can dedicate $hoursPerDay hours per day.
    Return the response in the following JSON format. Ensure the response is valid JSON:
    {
      "skill": "$skill",
      "level": "$level",
      "estimatedDays": number,
      "topics": [
        {
          "name": "Topic Name",
          "subtopics": ["Subtopic 1", "Subtopic 2", ...]
        }
      ]
    }
    ''';

    try {
      final response = await gemini.prompt(
        parts: [TextPart(prompt)], // Corrected line
      );

      if (response == null || response.content == null) {
        throw Exception("Invalid response from Gemini");
      }

      final jsonString = response.content?.parts?.first.toString() ?? '';

      if (jsonString.isEmpty) {
        throw Exception("Empty response from Gemini");
      }

      try{
          final jsonData = jsonDecode(jsonString);
          return jsonData;
      } on FormatException catch(e){
          print('Error decoding JSON: $e, original response: $jsonString');
          throw Exception("Invalid JSON response from Gemini");
      }

    } catch (e) {
      print('Error generating learning path: $e');
      return {
        "skill": skill,
        "level": level,
        "estimatedDays": 30,
        "topics": [
          {
            "name": "Basic Concepts",
            "subtopics": ["Introduction to $skill", "Core principles"]
          }
        ]
      };
    }
  }
}