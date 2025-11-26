class AIModel {
  final String id;
  final String name;
  final String provider;
  final int maxTokens;
  final double temperature;
  final double topP;

  const AIModel({
    required this.id,
    required this.name,
    required this.provider,
    this.maxTokens = 2048,
    this.temperature = 0.7,
    this.topP = 0.95,
  });

  static const defaultModel = AIModel(
    id: 'gemini-flash-lite-latest',
    name: 'Gemini Flash',
    provider: 'Google',
    maxTokens: 2048,
    temperature: 0.7,
  );
} 