import 'package:cineverse/features/movies/models/movies.dart';
import 'package:cineverse/features/movies/services/upcoming_movie_api_servie.dart';
import 'package:flutter/material.dart';

class UpcomingMoviesProvider with ChangeNotifier {
  final UpcomingMovieApiServie _apiService = UpcomingMovieApiServie();

  List<Movie> _upcomingMovies = [];
  bool _isLoading = false;
  String _error = '';
  int _currentPage = 1;
  int _totalPages = 1;

  List<Movie> get upcomingMovies => _upcomingMovies;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  UpcomingMoviesProvider() {
    fetchUpcomingMovies();
  }

  Future<void> fetchUpcomingMovies({int page = 1}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiService.fetchUpcomingMovies(page: page);
      if (page == 1) {
        _upcomingMovies = response.results;
      } else {
        _upcomingMovies.addAll(response.results);
      }
      _currentPage = response.page;
      _totalPages = response.totalPages;
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _currentPage >= _totalPages) return;
    await fetchUpcomingMovies(page: _currentPage + 1);
  }
}
