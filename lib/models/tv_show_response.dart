import 'package:cineverse/models/tv_show.dart';

// This class represents the response structure when fetching a list of TV shows from an API
class TvShowResponse {
  final int page;
  final List<TvShow> results;
  final int totalPages;
  final int totalResults;

  // Constructor to initialize all the fields
  TvShowResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  // Factory constructor to create a TvShowResponse object from JSON
  factory TvShowResponse.fromJson(Map<String, dynamic> json) {
    return TvShowResponse(
      page: json['page'] ?? 1,
      results: (json['results'] as List? ?? [])
          .map((show) => TvShow.fromJson(show)) // Parse each show in the list
          .toList(),
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
    );
  }
}
