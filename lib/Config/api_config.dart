import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static String apiKey =
      dotenv.env['API_KEY']!; // Replace with your actual API key

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

  // Placeholder Image
  static const String placeholderImage =
      'https://via.placeholder.com/500x750?text=No+Image';
}
