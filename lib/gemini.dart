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
    Return the response ONLY in the following JSON format with no additional text or explanation:
    {
      "skill": "$skill",
      "level": "$level",
      "estimatedDays": $estimatedDays,
      "topics": [
        {
          "name": "Topic Name",
          "subtopics": ["Subtopic 1", "Subtopic 2"]
        }
      ]
    }
    ''';

    try {
      final response = await gemini.prompt(
        parts: [TextPart(prompt)],
      );

      if (response == null || response.content == null) {
        debugPrint("Null response from Gemini");
        throw Exception("Invalid response from Gemini");
      }

      // Check if we have parts in the response
      if (response.content?.parts == null || response.content!.parts!.isEmpty) {
        debugPrint("No parts in Gemini response");
        throw Exception("No content parts in Gemini response");
      }

      // IMPORTANT FIX: Correctly access the text content from TextPart
      final part = response.content!.parts!.first;
      String responseText = "";
      
      // Check if the part is a TextPart and extract text correctly
      if (part is TextPart) {
        responseText = part.text.trim();
      } else {
        // If it's not a TextPart, try a fallback approach
        responseText = part.toString().trim();
      }
      
      debugPrint("Raw Gemini response text: $responseText");
      
      if (responseText.isEmpty) {
        debugPrint("Empty response text from Gemini");
        throw Exception("Empty response from Gemini");
      }

      // Try multiple approaches to extract valid JSON
      String jsonString = responseText;
      
      // First approach: Extract from code blocks if present
      if (responseText.contains('```json')) {
        jsonString = responseText.split('```json')[1].split('```')[0].trim();
        debugPrint("Extracted from ```json block: $jsonString");
      } else if (responseText.contains('```')) {
        jsonString = responseText.split('```')[1].split('```')[0].trim();
        debugPrint("Extracted from ``` block: $jsonString");
      }
      
      // Second approach: Try to find JSON object by its beginning and ending
      if (jsonString.contains('{') && jsonString.contains('}')) {
        final startIndex = jsonString.indexOf('{');
        final endIndex = jsonString.lastIndexOf('}') + 1;
        if (startIndex >= 0 && endIndex > startIndex) {
          jsonString = jsonString.substring(startIndex, endIndex);
          debugPrint("Extracted using braces: $jsonString");
        }
      }

      try {
        // Try to parse the JSON
        final jsonData = jsonDecode(jsonString);
        debugPrint("Successfully parsed JSON");
        return jsonData;
      } catch (e) {
        debugPrint('Error decoding JSON: $e');
        debugPrint('JSON string that failed: $jsonString');
        
        // One last attempt: clean any non-JSON characters
        try {
          // Only attempt the substring if there are curly braces
          if (jsonString.contains('{') && jsonString.contains('}')) {
            // Remove any characters before { and after }
            final cleanedJson = jsonString.substring(
              jsonString.indexOf('{'), 
              jsonString.lastIndexOf('}') + 1
            );
            debugPrint("Final attempt with cleaned JSON: $cleanedJson");
            return jsonDecode(cleanedJson);
          } else {
            throw Exception("No JSON object found in response");
          }
        } catch (e) {
          debugPrint('Final attempt failed: $e');
          throw Exception("Invalid JSON response from Gemini");
        }
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