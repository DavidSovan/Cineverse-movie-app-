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

  // Placeholder Image
  static const String placeholderImage =
      'https://via.placeholder.com/500x750?text=No+Image';
}
