import 'dart:convert';
import 'package:cineverse/config/api_config.dart';
import 'package:cineverse/models/upcoming_movie.dart';
import 'package:http/http.dart' as http;

class UpcomingMovieApiServie {
  Future<UpcomingMoviesResponse> fetchUpcomingMovies({int page = 1}) async {
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.upcomingMovies}?api_key=${ApiConfig.apiKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UpcomingMoviesResponse.fromJson(data);
      } else {
        throw Exception(
            'Failed to load upcoming movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching upcoming movies: $e');
    }
  }
}
