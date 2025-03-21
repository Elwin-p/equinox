//this is gemini's services

import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class GeminiService {
  static final gemini = Gemini.instance;

  /// Gets a structured learning path from Gemini API
  /// Returns a formatted JSON map with learning path data
  static Future<Map<String, dynamic>> getLearningPath(
    String skill, 
    int hoursPerDay, 
    String level
  ) async {
    // Calculate estimated days based on skill complexity and hours per day
    final int estimatedDays = _calculateEstimatedDays(skill, hoursPerDay, level);
    
    final prompt = '''
    Generate a structured learning path for $skill at $level level for someone who can dedicate $hoursPerDay hours per day.
    The path should take approximately $estimatedDays days to complete.
    Return the response ONLY in the following JSON format. Ensure the response is valid JSON with no extra text:
    {
      "skill": "$skill",
      "level": "$level",
      "estimatedDays": $estimatedDays,
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
        parts: [TextPart(prompt)],
      );

      if (response == null || response.content == null) {
        throw Exception("Invalid response from Gemini");
      }

      // Print the raw response to see what we're getting
    // Print the actual text content from the response
    if (response.content?.parts != null && response.content!.parts!.isNotEmpty) {
      final part = response.content!.parts!.first;
      print("Part type: ${part.runtimeType}");
      print("Part toString: ${part.toString()}");
      // Print all properties/methods on part object
      print("Part properties: ${part.toString()}");
    }
    
    final jsonString = response.content?.parts?.first.toString().trim() ?? '';
    
    // Print the extracted JSON string
    print("JSON string: $jsonString");
      
      if (jsonString.isEmpty) {
        throw Exception("Empty response from Gemini");
      }

      // Extract JSON if it's wrapped in backticks
      String cleanedJson = jsonString;
      if (jsonString.contains('```json')) {
        cleanedJson = jsonString.split('```json')[1].split('```')[0].trim();
      } else if (jsonString.contains('```')) {
        cleanedJson = jsonString.split('```')[1].split('```')[0].trim();
      }

      try {
        final jsonData = jsonDecode(cleanedJson);
        return jsonData;
      } on FormatException catch(e) {
        debugPrint('Error decoding JSON: $e, original response: $jsonString');
        throw Exception("Invalid JSON response from Gemini");
      }
    } catch (e) {
      debugPrint('Error generating learning path: $e');
      // Return fallback data if API fails
      return _getFallbackData(skill, level, estimatedDays);
    }
  }

  /// Calculates estimated days based on skill complexity and hours
  static int _calculateEstimatedDays(String skill, int hoursPerDay, String level) {
    // Base days needed for different levels
    int baseDays = 30; // Default for intermediate
    
    if (level == 'Beginner') {
      baseDays = 20;
    } else if (level == 'Advanced') {
      baseDays = 45;
    }
    
    // Adjust based on hours per day (assuming 2 hours is standard)
    return (baseDays * 2 / hoursPerDay).ceil();
  }

  /// Returns fallback data if the API request fails
  static Map<String, dynamic> _getFallbackData(String skill, String level, int estimatedDays) {
    return {
      "skill": skill,
      "level": level,
      "estimatedDays": estimatedDays,
      "topics": [
        {
          "name": "Basic Concepts",
          "subtopics": ["Introduction to $skill", "Core principles", "Basic terminology"]
        },
        {
          "name": "Core Skills",
          "subtopics": ["Essential techniques", "Fundamental tools", "Standard practices"]
        }
      ]
    };
  }
}