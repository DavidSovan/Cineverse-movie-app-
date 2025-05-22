import 'package:cineverse/Models/movies.dart';
import 'package:flutter/material.dart';
import '../Models/genre.dart';
import '../services/genre_api_service.dart';

class GenreProvider with ChangeNotifier {
  final GenreApiService _apiService = GenreApiService();

  List<Genre> _genres = [];
  List<Movie> _movies = [];
  int _totalPages = 1;
  int _currentPage = 1;
  bool _isLoading = false;
  String? _errorMessage;
  Genre? _selectedGenre;

  List<Genre> get genres => _genres;
  List<Movie> get movies => _movies;
  int get totalPages => _totalPages;
  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Genre? get selectedGenre => _selectedGenre;

  /// Fetch genres
  Future<void> fetchGenres() async {
    _isLoading = true;
    notifyListeners();

    try {
      _genres = await _apiService.fetchGenres();
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
    _selectedGenre = _genres.firstWhere((genre) => genre.id == genreId,
        orElse: () => Genre(id: 0, name: 'All'));
    notifyListeners();

    try {
      final result = await _apiService.fetchMoviesByGenre(genreId, page: page);
      if (page == 1) {
        _movies = result['movies'];
      } else {
        _movies.addAll(result['movies']);
      }
      _totalPages = result['totalPages'];
      _currentPage = result['currentPage'];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _movies = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load more movies for the current genre
  Future<void> loadMore() async {
    if (_isLoading || _currentPage >= _totalPages) return;

    await fetchMoviesByGenre(_selectedGenre?.id, page: _currentPage + 1);
  }

  /// Clear selected genre and reset state
  void clearGenreSelection() {
    _selectedGenre = null;
    _movies = [];
    _currentPage = 1;
    _totalPages = 1;
    notifyListeners();
  }
}
