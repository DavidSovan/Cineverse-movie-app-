import 'dart:convert';
import 'package:cineverse/core/config/api_config.dart';
import 'package:cineverse/features/movies/models/video_movies.dart';
import 'package:http/http.dart' as http;

class VideosMovieApi {
  VideosMovieApi();

  Future<MovieVideosResponse> fetchMovieVideos(int movieId) async {
    // Fixed: Include movieId in the URL path
    final url =
        '${ApiConfig.baseUrl}${ApiConfig.movieVideos.replaceAll('{movie_id}', movieId.toString())}?api_key=${ApiConfig.apiKey}';

    // Alternative approach if ApiConfig.movieVideos doesn't use placeholders:
    // final url = '${ApiConfig.baseUrl}/movie/$movieId/videos?api_key=${ApiConfig.apiKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return MovieVideosResponse.fromJson(data);
      } else {
        // Handle API errors (e.g., 401, 404)
        throw Exception(
            'Failed to load movie videos: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      // Handle network errors
      throw Exception('Failed to connect to the API: $e');
    }
  }
}
