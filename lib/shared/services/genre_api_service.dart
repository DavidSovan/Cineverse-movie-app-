import 'dart:convert';

import 'package:cineverse/core/config/api_config.dart';
import 'package:cineverse/features/drawer/genre.dart';
import 'package:cineverse/features/movies/models/movies.dart';
import 'package:http/http.dart' as http;

class GenreApiService {
  GenreApiService();

  Future<List<Genre>> fetchGenres() async {
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.genreList}?api_key=${ApiConfig.apiKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> genreList = data['genres'];
        return genreList.map((genre) => Genre.fromJson(genre)).toList();
      } else {
        throw Exception('Failed to load genres: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching genres: $e');
    }
  }

  Future<Map<String, dynamic>> fetchMoviesByGenre(int? genreId,
      {int page = 1}) async {
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.discoverMovies}?api_key=${ApiConfig.apiKey}&page=$page${genreId != null ? '&with_genres=$genreId' : ''}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> movieList = data['results'];
        final int totalPages = data['total_pages'];

        final movies = movieList.map((movie) => Movie.fromJson(movie)).toList();

        return {
          'movies': movies,
          'totalPages': totalPages,
          'currentPage': page,
        };
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movies by genre: $e');
    }
  }
}
