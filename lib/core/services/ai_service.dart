import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/ai_response.dart';
import '../models/capture_item.dart';

abstract class AIService {
  Future<AIStructuredResponse> analyzeScreenshot({
    required String imagePath,
    required String apiKey,
    String modelName = 'gemini-3.6-flash',
  });

  Future<Map<String, dynamic>> naturalLanguageSearch({
    required String query,
    required List<CaptureItem> items,
    required String apiKey,
    String modelName = 'gemini-3.6-flash',
  });
}

class CustomAIApiService implements AIService {
  @override
  Future<AIStructuredResponse> analyzeScreenshot({
    required String imagePath,
    required String apiKey,
    String modelName = 'gemini-3.6-flash',
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('Gemini API key is not configured. Please add your key in Settings.');
    }

    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      throw Exception('Screenshot image file does not exist at $imagePath');
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final cleanModel = modelName.isEmpty ? 'qwen3.8-27B' : modelName;
    final url = Uri.parse('https://ai-gw.f1arl.com/v1/chat/completions');

    const promptText = '''
You are an expert OCR & Visual Knowledge Assistant for SnapNote AI.
Analyze this screenshot image carefully and extract all valuable information into a valid JSON object.

RULES:
1. Classify into EXACTLY ONE category:
   - "note": General information, reference text, documentation, article snippet.
   - "event": Meetings, webinars, scheduled conferences, concerts, meetups with date/time.
   - "reminder": Something to remember to do at a specific date/time.
   - "task": Actionable task, todo, assignment, bug ticket.
   - "read_later": Articles, blogs, research papers, websites worth reading later.
   - "idea": Concepts, project ideas, feature thoughts.
   - "shopping": Product listing, price tag, store item, e-commerce screenshot.
   - "code": Source code snippets, terminal commands, configuration files.
   - "place": Physical locations, maps, addresses, restaurant listings.

2. Do NOT invent dates, URLs, or prices if not clearly visible or strongly implied.
3. If code is present, detect programming language and format the content cleanly with markdown code blocks.
4. Output strict JSON with NO surrounding text, no markdown backticks (` ```json `), ONLY raw JSON object.

JSON Schema:
{
  "category": "note" | "event" | "reminder" | "task" | "read_later" | "idea" | "shopping" | "code" | "place",
  "title": "Clear descriptive title",
  "summary": "1-2 sentence executive summary",
  "content": "Rich markdown formatted content",
  "tags": ["tag1", "tag2"],
  "confidence": 0.95,
  "is_uncertain": false,
  "date": "YYYY-MM-DD or null",
  "time": "HH:mm or null",
  "end_date": "YYYY-MM-DD or null",
  "end_time": "HH:mm or null",
  "location": "Venue or location name or null",
  "address": "Address string or null",
  "city": "City or null",
  "country": "Country or null",
  "url": "Full visible web URL or null",
  "people": ["Name1"],
  "product_name": "Product title or null",
  "price": "19.99 or null",
  "currency": "USD or null",
  "store": "Amazon, eBay, etc. or null",
  "programming_language": "dart, python, etc. or null",
  "priority": "low" | "medium" | "high" | null,
  "due_date": "YYYY-MM-DD or null"
}
''';

    final requestBody = {
      "model": cleanModel,
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": promptText
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "data:${_getMimeType(imagePath)};base64,$base64Image"
              }
            }
          ]
        }
      ],
      "temperature": 0.2
    };

    http.Response? response;
    int retries = 3;
    int delayMs = 1500;
    String lastErrorMsg = '';

    for (int i = 0; i < retries; i++) {
      try {
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          break;
        }

        final errBody = jsonDecode(response.body);
        lastErrorMsg = errBody['error']?['message'] ?? 'HTTP ${response.statusCode}: ${response.reasonPhrase}';

        // Don't retry on client errors except 429 Too Many Requests
        if (response.statusCode >= 400 && response.statusCode < 500 && response.statusCode != 429) {
          throw Exception('AI API Error: $lastErrorMsg');
        }
      } catch (e) {
        lastErrorMsg = e.toString();
        if (e is FormatException || (e.toString().contains('AI API Error:'))) {
          rethrow;
        }
      }

      if (i < retries - 1) {
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2; // Exponential backoff (1.5s, 3s, 6s)
      }
    }

    if (response == null || response.statusCode != 200) {
      throw Exception('AI API Error after retries: $lastErrorMsg');
    }

    final resData = jsonDecode(response.body);
    final choices = resData['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('No response generated by AI API.');
    }

    final text = choices[0]['message']['content'] as String;
    return _parseAIJsonResponse(text);
  }

  @override
  Future<Map<String, dynamic>> naturalLanguageSearch({
    required String query,
    required List<CaptureItem> items,
    required String apiKey,
    String modelName = 'gemini-3.6-flash',
  }) async {
    if (apiKey.trim().isEmpty || items.isEmpty) {
      return {'answer': 'No API key configured or no items stored.', 'item_ids': <String>[]};
    }

    final cleanModel = modelName.isEmpty ? 'qwen3.8-27B' : modelName;
    final url = Uri.parse('https://ai-gw.f1arl.com/v1/chat/completions');

    final itemsSummary = items.take(100).map((e) => {
      'id': e.id,
      'title': e.title,
      'category': e.category,
      'summary': e.summary,
      'tags': e.tags,
      'date': e.createdAt.toIso8601String(),
    }).toList();

    final prompt = '''
The user is asking a natural language question about their captured knowledge:
Query: "$query"

Here is a list of stored capture items:
${jsonEncode(itemsSummary)}

Identify which items directly match or relate to the query.
Return ONLY raw JSON with schema:
{
  "answer": "A friendly summary answering the user's question directly",
  "item_ids": ["matching_id_1", "matching_id_2"]
}
''';

    final requestBody = {
      "model": cleanModel,
      "messages": [
        {
          "role": "user",
          "content": prompt
        }
      ],
      "temperature": 0.2
    };

    int retries = 2;
    int delayMs = 1500;

    for (int i = 0; i < retries; i++) {
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final resData = jsonDecode(response.body);
          final text = resData['choices'][0]['message']['content'] as String;
          final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
          return jsonDecode(cleanText) as Map<String, dynamic>;
        }
        
        // Don't retry on client errors except 429 Too Many Requests
        if (response.statusCode >= 400 && response.statusCode < 500 && response.statusCode != 429) {
          break;
        }
      } catch (_) {}

      if (i < retries - 1) {
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
      }
    }

    return {'answer': 'Could not process natural language query.', 'item_ids': <String>[]};
  }

  String _getMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/png';
  }

  AIStructuredResponse _parseAIJsonResponse(String rawText) {
    String cleanJson = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
    
    // Attempt to extract JSON substring if there's surrounding text
    final firstBrace = cleanJson.indexOf('{');
    final lastBrace = cleanJson.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      cleanJson = cleanJson.substring(firstBrace, lastBrace + 1);
    }

    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      // Fallback object if JSON parsing fails
      return AIStructuredResponse(
        category: 'note',
        title: 'OCR Capture Note',
        summary: 'Extracted raw text snippet.',
        content: rawText,
        tags: ['raw'],
        confidence: 0.5,
        isUncertain: true,
        rawJson: rawText,
      );
    }

    List<String> parseList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    final category = (data['category'] as String?)?.toLowerCase().trim() ?? 'note';
    final allowedCategories = ['note', 'event', 'reminder', 'task', 'read_later', 'idea', 'shopping', 'code', 'place'];
    final validCategory = allowedCategories.contains(category) ? category : 'note';

    final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.9;
    final isUncertain = (data['is_uncertain'] as bool?) ?? (confidence < 0.7);

    return AIStructuredResponse(
      category: validCategory,
      title: (data['title'] as String?)?.trim() ?? 'Untitled Capture',
      summary: (data['summary'] as String?)?.trim() ?? '',
      content: (data['content'] as String?)?.trim() ?? '',
      tags: parseList(data['tags']),
      confidence: confidence,
      isUncertain: isUncertain,
      date: data['date'] as String?,
      time: data['time'] as String?,
      endDate: data['end_date'] as String?,
      endTime: data['end_time'] as String?,
      location: data['location'] as String?,
      address: data['address'] as String?,
      city: data['city'] as String?,
      country: data['country'] as String?,
      url: data['url'] as String?,
      people: parseList(data['people']),
      productName: data['product_name'] as String?,
      price: data['price'] as String?,
      currency: data['currency'] as String?,
      store: data['store'] as String?,
      programmingLanguage: data['programming_language'] as String?,
      priority: data['priority'] as String?,
      dueDate: data['due_date'] as String?,
      rawJson: cleanJson,
    );
  }
}
