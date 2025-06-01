import 'package:cineverse/models/tv_show.dart';
import 'package:cineverse/services/tv_show_service.dart';
import 'package:flutter/foundation.dart';

// Enum representing different loading states of the app
enum TvShowState { idle, loading, loaded, error }

// This class manages the state for TV shows using ChangeNotifier (used in Provider)
class TvShowProvider extends ChangeNotifier {
  // Create an instance of the service that fetches TV shows from API
  final TvShowService _tvShowService = TvShowService();

  // Internal state variables
  TvShowState _state = TvShowState.idle; // Current state of the app
  List<TvShow> _popularTvShows = []; // List to store fetched TV shows
  String _errorMessage = ''; // To store error messages
  int _currentPage = 1; // Page number for pagination
  int _totalPages = 1; // Total number of pages available
  bool _hasMoreData = true; // Flag to check if there's more data to load

  // Public getters to expose internal state to UI widgets
  TvShowState get state => _state;
  List<TvShow> get popularTvShows => _popularTvShows;
  String get errorMessage => _errorMessage;
  bool get isLoading => _state == TvShowState.loading;
  bool get hasError => _state == TvShowState.error;
  bool get hasMoreData => _hasMoreData;
  int get currentPage => _currentPage;

  // Function to fetch popular TV shows from API
  Future<void> fetchPopularTvShows({bool refresh = false}) async {
    // If refresh is true, reset data and page info
    if (refresh) {
      _currentPage = 1;
      _popularTvShows.clear();
      _hasMoreData = true;
    }

    // Stop if no more data to load (unless it's a refresh)
    if (!_hasMoreData && !refresh) return;

    _setState(TvShowState.loading); // Set UI to loading state

    try {
      // Call the API using the current page number
      final response =
          await _tvShowService.getPopularTvShows(page: _currentPage);

      // If refreshing, replace list; otherwise, append new data
      if (refresh) {
        _popularTvShows = response.results;
      } else {
        _popularTvShows.addAll(response.results);
      }

      // Update pagination info
      _totalPages = response.totalPages;
      _hasMoreData = _currentPage < _totalPages;
      _currentPage++;

      _setState(TvShowState.loaded); // Set UI to loaded state
    } catch (e) {
      _errorMessage = e.toString(); // Store error
      _setState(TvShowState.error); // Set UI to error state
    }
  }

  // Load more shows when user scrolls down (pagination)
  Future<void> loadMore() async {
    if (!_hasMoreData || _state == TvShowState.loading) return;
    await fetchPopularTvShows();
  }

  // Refresh the list of TV shows
  Future<void> refresh() async {
    await fetchPopularTvShows(refresh: true);
  }

  // Private helper to update state and notify UI
  void _setState(TvShowState newState) {
    _state = newState;
    notifyListeners(); // Notify any UI widgets listening to changes
  }

  // Clear the error and reset the state to idle
  void clearError() {
    _errorMessage = '';
    _setState(TvShowState.idle);
  }
}
