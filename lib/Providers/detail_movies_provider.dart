import 'package:cineverse/Models/detail_movies.dart';
import 'package:cineverse/Services/movies_api_service.dart';
import 'package:flutter/material.dart';

class DetailMoviesProvider with ChangeNotifier {
  final MovieApiService movieService;

  DetailMoviesProvider({required this.movieService});

  // State variables
  DetailedMovie? _currentMovie;
  bool _isLoading = false;
  String? _error;

  // Getters
  DetailedMovie? get currentMovie => _currentMovie;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Method to fetch movie details
  Future<void> fetchMovieDetails(int movieId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final movie = await movieService.getMovieDetails(movieId);
      _currentMovie = movie;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // You can add more methods as needed, for example:
  bool isMovieLoaded() {
    return _currentMovie != null && _currentMovie!.hasFullDetails;
  }

  // Method to clear current movie
  void clearCurrentMovie() {
    _currentMovie = null;
    notifyListeners();
  }
}
