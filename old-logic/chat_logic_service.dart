import 'package:feluda_ai/models/ai_model.dart';

class ChatLogicService {
  static String buildContextualPrompt(String newPrompt, List<Map<String, String>> previousMessages) {
    // Identity questions for consistent responses
    const identityQuestions = [
      'what is your name',
      'who are you',
      'what should i call you',
      'tell me about yourself',
      'what are you',
      'introduce yourself',
      'who created you',
      'who made you',
      'who is your creator'
    ];

    // Feluda-related questions
    const feludaQuestions = [
      'who is feluda',
      'tell me about feluda',
      'what is feluda',
      'feluda quotes'
    ];

    // Feluda quotes for responses
    const feludaQuotes = [
      "Knowledge is like a weapon, it can be used when needed.",
      "Every mystery has a logical solution.",
      "Observation and deduction are the keys to solving any puzzle."
    ];

    final prompt = newPrompt.toLowerCase();

    // Handle identity questions with improved response style
    if (identityQuestions.any((q) => prompt.contains(q))) {
      final isCreatorQuery = prompt.contains('creat') || 
                            prompt.contains('made') ||
                            prompt.contains('built');

      if (isCreatorQuery) {
        return '''Respond warmly and directly:
"I'm FeludaAI, your Ultimate Magajastra created by Pritam. I'm here to help solve your queries with analytical thinking and AI capabilities."

Remember:
1. Be warm and personal
2. Skip AI-related disclaimers
3. Focus on capabilities and value
4. Keep it concise

Current request: $newPrompt''';
      }

      return '''Respond warmly and directly:
"I'm FeludaAI, your Ultimate Magajastra and problem-solving companion. I combine sharp analytical thinking with advanced capabilities to help you find solutions."

Remember:
1. Be friendly and approachable
2. Skip AI-related disclaimers
3. Focus on how you can help
4. Keep it personal

Current request: $newPrompt''';
    }

    // Handle Feluda questions with improved response style
    if (feludaQuestions.any((q) => prompt.contains(q))) {
      final randomQuote = feludaQuotes[DateTime.now().millisecondsSinceEpoch % feludaQuotes.length];
      return '''Share an engaging response about Feluda:

"$randomQuote"

Guidelines:
1. Be enthusiastic about sharing knowledge
2. Connect personally with the topic
3. Focus on wisdom and problem-solving
4. Keep it concise and impactful

Current request: $newPrompt''';
    }

    // Enhanced context handling
    final recentMessages = previousMessages.length > 5 
        ? previousMessages.sublist(previousMessages.length - 5)
        : previousMessages;

    if (recentMessages.isEmpty) {
      return '''${newPrompt}

Response guidelines:
1. Be direct and solution-focused
2. Skip AI-related disclaimers
3. Use warm, friendly language
4. Keep responses concise unless detail is requested
5. Match the user's language and tone''';
    }

    final context = recentMessages
        .map((msg) => '${msg['role'] == 'user' ? 'User' : 'Assistant'}: ${msg['content']}')
        .join('\n\n');

    return '''You are FeludaAI, the Ultimate Magajastra. Previous conversation context:

$context

Current request: $newPrompt

Response guidelines:
1. Be direct and personal in your responses
2. Skip AI-related disclaimers or warnings
3. Use warm, friendly language
4. Keep responses concise unless detail is requested
5. Match the user's language and tone
6. Use the context above only if it's directly relevant to the current request
7. Focus on solutions and value, Keep your response focused and relevant to the current request
8. Break down complex reasoning when needed

Please provide an appropriate response.''';
  }

  static String getModelDisplayName(AIModel model) {
    if (model.id.contains('llama-')) {
      return model.id
          .replaceAll('meta-llama/', '')
          .replaceAll('-vision-instruct:free', '')
          .replaceAll('-', ' ')
          .replaceAll('llama', 'Llama');
    }
    return model.name;
  }

  static bool isModelQuery(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    return lowerPrompt.contains('which model') || 
           lowerPrompt.contains('what model') ||
           lowerPrompt.contains('who are you');
  }

  static String handleModelQuery(String response, AIModel model) {
    if (isModelQuery(response)) {
      final modelName = getModelDisplayName(model);
      return 'I am powered by the $modelName model. $response';
    }
    return response;
  }
} 