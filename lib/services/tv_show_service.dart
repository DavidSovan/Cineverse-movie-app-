import 'dart:convert';
import 'package:cineverse/config/api_config.dart';
import 'package:cineverse/models/tv_show_response.dart';
import 'package:http/http.dart' as http;

// This class handles network requests related to TV shows
class TvShowService {
  // Set a timeout of 30 seconds for any HTTP request
  static const Duration _timeout = Duration(seconds: 30);

  // Function to fetch a list of popular TV shows from the API
  Future<TvShowResponse> getPopularTvShows({int page = 1}) async {
    try {
      // Build the full API URL with a page query parameter
      final url = ApiConfig.buildUrl(
        ApiConfig.popularTvShows, // Endpoint for popular shows
        queryParams: {'page': page.toString()}, // Convert page number to string
      );

      // Make an HTTP GET request with headers and a timeout
      final response = await http
          .get(
            Uri.parse(url), // Convert string URL to Uri
            headers: ApiConfig.headers, // Custom headers from ApiConfig
          )
          .timeout(_timeout); // Stop waiting after 30 seconds

      // If the response is successful (HTTP 200 OK)
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body); // Parse JSON response
        return TvShowResponse.fromJson(jsonData); // Convert JSON to Dart model
      } else {
        // If response is not 200, throw a custom exception
        throw ApiException(
          'Failed to load popular TV shows: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      // If the error is already an ApiException, rethrow it
      if (e is ApiException) rethrow;

      // If it’s a different kind of error (e.g., network error), wrap it
      throw ApiException('Network error: ${e.toString()}', 0);
    }
  }
}

// Custom exception class for handling API-related errors
class ApiException implements Exception {
  final String message; // Error message
  final int statusCode; // HTTP status code or 0 if it's a general error

  ApiException(this.message, this.statusCode);

  // When the exception is printed or logged, show this format
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
