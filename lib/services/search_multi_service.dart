import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cineverse/models/search_result.dart';
import 'package:cineverse/config/api_config.dart';

class SearchMultiService {
  static Future<List<SearchResult>> searchMulti(String query) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.searchMulti}?api_key=${ApiConfig.apiKey}&query=${Uri.encodeComponent(query)}',
    );

    final response = await http.get(
      url,
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final results = jsonBody['results'] as List;
      return results.map((e) => SearchResult.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
