import 'dart:convert';
import 'package:cineverse/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import '../models/movie_credits.dart';

class MovieCreditsApiService {
  Future<MovieCredits> fetchMovieCredits(int movieId) async {
    final endpoint =
        ApiConfig.movieCredits.replaceFirst('{movie_id}', movieId.toString());
    final url = '${ApiConfig.baseUrl}$endpoint?api_key=${ApiConfig.apiKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MovieCredits.fromJson(data);
      } else {
        throw Exception('Failed to load movie credits: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the API: $e');
    }
  }
}
