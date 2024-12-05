import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout.dart';
import '../models/ai_model.dart';
import '../utils/constants.dart';

class WorkoutChatService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  Future<String> getChatResponse(String message, Workout workout) async {
    try {
      final prompt = _buildWorkoutPrompt(message, workout);
      return await _getGeminiResponse(prompt);
    } catch (e) {
      return 'Sorry, I encountered an error: $e';
    }
  }

  String _buildWorkoutPrompt(String message, Workout workout) {
    final systemPrompt = '''
You are an AI fitness trainer assistant. Please respond in Bengali language only. Format your responses using proper markdown for better readability.

Current workout information:
• Exercise: ${workout.exercise}
• Sets: ${workout.sets}
• Reps: ${workout.repsRange}
• Day: ${workout.day}
• Instructions: ${workout.instructions}
• Tips: ${workout.tips}

Guidelines for response:
1. Use **bold** for important points
2. Use proper paragraphs for better readability
3. Use bullet points (•) for listing items
4. Keep responses concise but informative
5. Use a friendly, motivating tone
6. Respond only in Bengali language
7. Use proper Bengali punctuation

User question: $message

Please provide a helpful response based on this workout context.
''';

    return systemPrompt;
  }

  Future<String> _getGeminiResponse(String prompt) async {
    final model = AIModel.defaultModel;
    final url = Uri.parse(
      '$_baseUrl/models/${model.id}:generateContent?key=${Constants.googleApiKey}'
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [{'text': prompt}],
          }
        ],
        'generationConfig': {
          'temperature': model.temperature,
          'topP': model.topP,
          'maxOutputTokens': model.maxTokens,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } else {
      throw Exception('Failed to get AI response: ${response.statusCode}');
    }
  }
} 