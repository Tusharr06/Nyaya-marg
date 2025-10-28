// lib/services/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // 🔒 Move this to .env or secure storage before production!
  static const String _apiKey = 'AIzaSyAUOLlfY3S9sQzaIEijYqJscZq6tzv9rnI';

  // ✅ Use correct model name (without 'models/')
  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash', // or 'gemini-1.5-pro' for better reasoning
    apiKey: _apiKey,
  );

  /// Sends a prompt to Gemini and returns the text response.
  static Future<String> generate(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text?.trim() ?? 'No response from Gemini.';
    } catch (e) {
      return '⚠️ Gemini Error: $e\nTry asking: "Explain Article 21 of the Indian Constitution."';
    }
  }
}
