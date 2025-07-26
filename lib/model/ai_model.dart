import 'dart:convert';
import 'package:http/http.dart' as http;

class AIModel {
  final String baseUrl = 'http://<HOST>';

  Future<String> sendMessageToTherapistBot(String message) async {
    final res = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['reply'];
    }
    throw Exception('Chat error ${res.statusCode}');
  }

  Future<String> getFoodRecommendation(String entry) async {
    final res = await http.post(
      Uri.parse('$baseUrl/food-recommendation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'entry': entry}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['suggestion'];
    }
    throw Exception('Food suggestion error ${res.statusCode}');
  }
}
