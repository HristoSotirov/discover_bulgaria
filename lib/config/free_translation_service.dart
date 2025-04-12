import 'package:http/http.dart' as http;
import 'dart:convert';

class FreeTranslationService {
  static Future<String> translate(String text, String targetLang) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=bg|$targetLang'
      ));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['responseData']['translatedText'] ?? text;
      }
      return text;
    } catch (e) {
      return text;
    }
  }
}