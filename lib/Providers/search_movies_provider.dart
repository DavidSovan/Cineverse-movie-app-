import 'package:cineverse/Models/movies.dart';
import 'package:cineverse/Services/search_movie_api_service.dart';
import 'package:flutter/foundation.dart';

class SearchMoviesProvider with ChangeNotifier {
  final SearchMovieApiService movieService;

  SearchMoviesProvider({required this.movieService});

  List<Movie> _movies = [];
  bool _isLoading = false;
  String _error = '';

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _movies = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await movieService.searchMovies(query);
      _movies = response.results;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
