class GeminiConfig {
  GeminiConfig._();

  static const String apiKey = '';
  static const String model = 'gemini-2.0-flash';

  static bool get isConfigured => apiKey.isNotEmpty;
}
