import 'package:cineverse/features/movies/models/movies.dart';

class MovieResponse {
  final List<Movie> results;
  final int page;
  final int totalPages;
  final int totalResults;

  MovieResponse({
    required this.results,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      results: (json['results'] as List)
          .map((movieJson) => Movie.fromJson(movieJson))
          .toList(),
      page: json['page'],
      totalPages: json['total_pages'],
      totalResults: json['total_results'],
    );
  }
}
