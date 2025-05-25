import 'package:cineverse/models/movies.dart';

class UpcomingMoviesResponse {
  final List<Movie> results;
  final int page;
  final int totalPages;
  final int totalResults;

  UpcomingMoviesResponse({
    required this.results,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  factory UpcomingMoviesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> resultsList = json['results'] as List<dynamic>;
    final List<Movie> movies = resultsList
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();

    return UpcomingMoviesResponse(
      results: movies,
      page: json['page'] as int,
      totalPages: json['total_pages'] as int,
      totalResults: json['total_results'] as int,
    );
  }
}
