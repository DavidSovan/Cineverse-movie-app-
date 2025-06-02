import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static String apiKey = dotenv.env['API_KEY']!; // API key
  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
  // Image URLs
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String posterImageUrl = '$imageBaseUrl/w500';
  static const String backdropImageUrl = '$imageBaseUrl/w780';
  // API Endpoints
  static const String popularMovies = '/movie/popular';
  static const String movieDetails = '/movie/';
  static const String searchMovies = '/search/movie';
  static const String genreList = '/genre/movie/list';
  static const String discoverMovies = '/discover/movie';
  static const String upcomingMovies = '/movie/upcoming';
  static const String movieVideos = '/movie/{movie_id}/videos';
  static const String movieCredits = '/movie/{movie_id}/credits';
  static const String similarMovies = '/movie/{movie_id}/similar';
  // TV Show Endpoints
  static const String popularTvShows = '/tv/popular';
  // Build URL (Popular TV show) with API key
  static String buildUrl(String endpoint, {Map<String, String>? queryParams}) {
    final uri = Uri.parse('$baseUrl$endpoint');
    final params = <String, String>{
      'api_key': apiKey,
      ...?queryParams,
    };
    return uri.replace(queryParameters: params).toString();
  }

  //tv show details endpoint
  static String tvShowDetail(int tvId) =>
      '$baseUrl/tv/$tvId?api_key=$apiKey'; // Build URL for TV show details

  // Placeholder Image
  static const String placeholderImage =
      'https://via.placeholder.com/500x750?text=No+Image';
}
