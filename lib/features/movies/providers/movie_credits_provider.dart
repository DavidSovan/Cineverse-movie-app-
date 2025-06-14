import 'package:cineverse/features/movies/models/movie_credits.dart';
import 'package:cineverse/features/movies/services/movie_creadits_api_service.dart';
import 'package:flutter/material.dart';

enum MovieCreditsState {
  initial,
  loading,
  loaded,
  error,
}

class MovieCreditsProvider with ChangeNotifier {
  MovieCredits? _movieCredits;
  MovieCreditsState _state = MovieCreditsState.initial;
  String? _errorMessage;

  MovieCredits? get movieCredits => _movieCredits;
  MovieCreditsState get state => _state;
  String? get errorMessage => _errorMessage;
  final MovieCreditsApiService _apiService = MovieCreditsApiService();

  Future<void> fetchMovieCredits(int movieId) async {
    _state = MovieCreditsState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Explicit type annotation to ensure correct type
      final MovieCredits result = await _apiService.fetchMovieCredits(movieId);
      _movieCredits = result;
      _state = MovieCreditsState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = MovieCreditsState.error;
    } finally {
      notifyListeners();
    }
  }

  // Optional: Add a method to clear the data
  void clearCredits() {
    _movieCredits = null;
    _state = MovieCreditsState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
