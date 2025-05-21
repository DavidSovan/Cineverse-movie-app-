import 'package:cineverse/Models/movies.dart';
import 'package:flutter/material.dart';
import '../models/genre.dart';
import '../services/genre_api_service.dart';

class GenreProvider with ChangeNotifier {
  final GenreApiService _apiService = GenreApiService();

  List<Genre> _genres = [];
  List<Movie> _movies = [];
  int _totalPages = 1;
  int _currentPage = 1;
  bool _isLoading = false;
  String? _errorMessage;

  List<Genre> get genres => _genres;
  List<Movie> get movies => _movies;
  int get totalPages => _totalPages;
  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch genres
  Future<void> fetchGenres() async {
    _isLoading = true;
    notifyListeners();

    try {
      _genres = (await _apiService.fetchGenres()).cast<Genre>();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch movies by genre
  Future<void> fetchMoviesByGenre(int? genreId, {int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.fetchMoviesByGenre(genreId, page: page);
      _movies = result['movies'];
      _totalPages = result['totalPages'];
      _currentPage = result['currentPage'];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
