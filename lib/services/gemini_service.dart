import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/jewelry_result.dart';

class GeminiService {
  // ✅ Get FREE API key at: https://aistudio.google.com/app/apikey // get new key
  static const String apiKey = 'AIzaSyAH7jsBvCQKllcZrXTWo2pRzmBiuaaJP60';
  // update new key
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-1.5-flash:generateContent';

  static const String _prompt = '''
You are a world-class gemologist and jewelry expert. Carefully examine this jewelry image.

Your task is to COUNT each type of element SEPARATELY and PRECISELY:

1. GOLD BALLS/BEADS — small round spherical gold/yellow metallic elements
2. DIAMONDS — clear/white sparkling stones (round brilliant, princess, baguette, any cut)
3. RUBIES — red colored precious stones
4. EMERALDS — green colored precious stones
5. SAPPHIRES — blue colored precious stones
6. PEARLS — white/cream lustrous round pearls
7. OTHER STONES — any other gemstones not listed above

Instructions:
- Scan the ENTIRE jewelry systematically section by section
- Count ONLY clearly visible elements
- For partially hidden elements, count only if >50% visible
- Be as accurate as possible

Respond ONLY in this exact JSON format (no markdown, no explanation, just JSON):
{
  "goldBalls": <number>,
  "diamonds": <number>,
  "rubies": <number>,
  "emeralds": <number>,
  "sapphires": <number>,
  "pearls": <number>,
  "otherStones": <number>,
  "otherStonesType": "<describe other stones or write none>",
  "jewelryType": "<ring/necklace/mangalsutra/bangle/earring/bracelet/pendant/chain>",
  "metal": "<yellow gold/rose gold/white gold/silver/platinum/unknown>",
  "confidence": "<high/medium/low>",
  "description": "<detailed description of what you see in the jewelry>",
  "notes": "<mention any partially hidden elements or image quality issues>"
}''';

  static Future<JewelryResult> analyzeImage(File imageFile) async {
    if (apiKey == 'AIzaSyAH7jsBvCQKllcZrXTWo2pRzmBiuaaJP60') {
      throw Exception(
          'Please set your Gemini API key in lib/services/gemini_service.dart\n'
          'Get a FREE key at: https://aistudio.google.com/app/apikey');
    }

    final bytes = await imageFile.readAsBytes();

    // Compress if > 4MB
    List<int> imageBytes = bytes;
    if (bytes.length > 4 * 1024 * 1024) {
      imageBytes = bytes; // In production use flutter_image_compress
    }

    final base64Image = base64Encode(imageBytes);
    final mimeType = _getMimeType(imageFile.path);

    final requestBody = {
      'contents': [
        {
          'parts': [
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            },
            {'text': _prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.05,
        'maxOutputTokens': 800,
        'topP': 0.8,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_NONE'
        }
      ]
    };

    final response = await http
        .post(
          Uri.parse('$_baseUrl?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      final errorMsg = errorBody['error']?['message'] ?? 'Unknown API error';
      throw Exception('API Error (${response.statusCode}): $errorMsg');
    }

    final responseData = jsonDecode(response.body);

    // Extract text from response
    final candidates = responseData['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No response from AI. Please try again.');
    }

    final content = candidates[0]['content'];
    final parts = content['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Empty response from AI.');
    }

    final rawText = parts[0]['text'] as String? ?? '';

    // Clean and parse JSON
    final cleanJson = _extractJson(rawText);
    final Map<String, dynamic> parsed = jsonDecode(cleanJson);

    return JewelryResult.fromMap(parsed);
  }

  static String _extractJson(String text) {
    // Remove markdown code blocks
    String cleaned = text
        .replaceAll('```json', '')
        .replaceAll('```JSON', '')
        .replaceAll('```', '')
        .trim();

    // Find JSON object
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return cleaned.substring(start, end + 1);
    }
    return cleaned;
  }

  static String _getMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
