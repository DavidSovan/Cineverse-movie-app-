import 'package:cineverse/features/movies/models/movies.dart';
import 'package:flutter/material.dart';
import '../services/similar_movies_service.dart';

enum SimilarMoviesState { initial, loading, loaded, error }

class SimilarMoviesProvider with ChangeNotifier {
  final SimilarMoviesService _movieService = SimilarMoviesService();

  SimilarMoviesState _state = SimilarMoviesState.initial;
  List<Movie> _similarMovies = [];
  String _errorMessage = '';

  bool _disposed = false;

  SimilarMoviesState get state => _state;
  List<Movie> get similarMovies => _similarMovies;
  String get errorMessage => _errorMessage;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchSimilarMovies(int movieId) async {
    if (_disposed) {
      return;
    }

    _state = SimilarMoviesState.loading;
    notifyListeners();

    try {
      _similarMovies = await _movieService.fetchSimilarMovies(movieId);
      if (_disposed) return;

      _state = SimilarMoviesState.loaded;
    } catch (e) {
      if (_disposed) return;

      _errorMessage = e.toString();
      _state = SimilarMoviesState.error;
    } finally {
      if (!_disposed) {
        notifyListeners();
      }
    }
  }
}
