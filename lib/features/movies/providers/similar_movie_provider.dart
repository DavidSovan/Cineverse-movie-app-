import 'package:cineverse/features/movies/models/movies.dart';
import 'package:flutter/material.dart';
import '../services/similar_movies_service.dart';

enum SimilarMoviesState { initial, loading, loaded, error }

class SimilarMoviesProvider with ChangeNotifier {
  final SimilarMoviesService _movieService = SimilarMoviesService();

  SimilarMoviesState _state = SimilarMoviesState.initial;
  List<Movie> _similarMovies = [];
  String _errorMessage = '';

  SimilarMoviesState get state => _state;
  List<Movie> get similarMovies => _similarMovies;
  String get errorMessage => _errorMessage;

  Future<void> fetchSimilarMovies(int movieId) async {
    _state = SimilarMoviesState.loading;
    notifyListeners();

    try {
      _similarMovies = await _movieService.fetchSimilarMovies(movieId);
      _state = SimilarMoviesState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = SimilarMoviesState.error;
    } finally {
      notifyListeners();
    }
  }
}
