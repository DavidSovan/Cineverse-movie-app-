import 'dart:convert';
import 'package:cineverse/Config/api_config.dart';
import 'package:http/http.dart' as http;
import '../models/movie_response.dart';

class SearchMovieApiService {
  SearchMovieApiService();
  Future<MovieResponse> searchMovies(String query) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.searchMovies}?api_key=${ApiConfig.apiKey}&query=$query',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return MovieResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to search movies: ${response.statusCode}');
    }
  }
}
