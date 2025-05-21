import 'dart:convert';
import 'package:cineverse/Models/detail_movies.dart';
import 'package:cineverse/Models/movies.dart';
import 'package:cineverse/Config/api_config.dart';
import 'package:http/http.dart' as http;

class MovieApiService {
  MovieApiService();

  Future<List<Movie>> getPopularMovies() async {
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.popularMovies}?api_key=${ApiConfig.apiKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }

  String getImageUrl(String path, {bool isBackdrop = false}) {
    if (path.isEmpty) {
      return ApiConfig.placeholderImage;
    }
    final baseImageUrl =
        isBackdrop ? ApiConfig.backdropImageUrl : ApiConfig.posterImageUrl;
    return '$baseImageUrl$path';
  }

  Future<DetailedMovie> getMovieDetails(int movieId) async {
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.movieDetails}$movieId?api_key=${ApiConfig.apiKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DetailedMovie.fromJson(data);
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movie details: $e');
    }
  }
}
