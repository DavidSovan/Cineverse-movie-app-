import 'package:flutter/material.dart';
import 'package:cineverse/Models/movies.dart';
import 'package:cineverse/Services/movies_api_service.dart';

class MovieProvider extends ChangeNotifier {
  final MovieApiService apiService;

  MovieProvider({required this.apiService});

  List<Movie> _movies = [];
  bool _isLoading = false;
  String _error = '';

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchPopularMovies() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _movies = await apiService.getPopularMovies();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void fetchMovieDetails(int movieId) {}
}
