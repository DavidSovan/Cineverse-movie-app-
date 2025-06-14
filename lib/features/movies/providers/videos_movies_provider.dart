import 'package:cineverse/features/movies/models/video_movies.dart';
import 'package:cineverse/features/movies/services/videos_movie_api.dart';
import 'package:flutter/material.dart';

class MovieVideosProvider extends ChangeNotifier {
  final VideosMovieApi apiService = VideosMovieApi();
  MovieVideosResponse? _movieVideos;
  bool _isLoading = false;
  String? _errorMessage;

  MovieVideosResponse? get movieVideos => _movieVideos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMovieVideos(int movieId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _movieVideos = await apiService.fetchMovieVideos(movieId);
    } catch (e) {
      _errorMessage = e.toString();
      _movieVideos = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
