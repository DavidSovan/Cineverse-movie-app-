import 'dart:convert';
import 'package:cineverse/core/config/api_config.dart';
import 'package:cineverse/features/movies/models/movie_response.dart';
import 'package:cineverse/features/movies/models/movies.dart';
import 'package:http/http.dart' as http;

class SimilarMoviesService {
  Future<List<Movie>> fetchSimilarMovies(int movieId) async {
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.similarMovies.replaceAll('{movie_id}', movieId.toString())}?api_key=${ApiConfig.apiKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final movieResponse = MovieResponse.fromJson(data);
        return movieResponse.results;
      } else {
        throw Exception(
            'Failed to load similar movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching similar movies: $e');
    }
  }
}
