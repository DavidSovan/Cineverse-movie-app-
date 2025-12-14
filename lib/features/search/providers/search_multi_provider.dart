import 'package:flutter/material.dart';
import 'package:cineverse/features/search/services/search_multi_service.dart';
import 'package:cineverse/features/search/models/search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SearchMultiProvider extends ChangeNotifier {
  List<SearchResult> _results = [];
  bool _isLoading = false;
  String? _error;
  List<String> _searchHistory = [];
  
  // Debouncing and request cancellation
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const int _minQueryLength = 3;

  List<SearchResult> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get searchHistory => _searchHistory;

  SearchMultiProvider() {
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList('search_history') ?? [];
    notifyListeners();
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _searchHistory);
  }

  void _addToSearchHistory(String query) {
    // Normalize search term
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return;
    
    // Remove existing entry and add to front
    _searchHistory.remove(normalizedQuery);
    _searchHistory.insert(0, normalizedQuery);
    
    // Limit history size
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }
    
    _saveSearchHistory();
    notifyListeners();
  }

  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    _searchHistory.clear();
    notifyListeners();
  }

  // Live search without saving to history
  void liveSearch(String query) {
    // Cancel previous debounce timer
    _debounceTimer?.cancel();
    
    // Don't search for short queries
    if (query.trim().length < _minQueryLength) {
      _clearResults();
      return;
    }
    
    // Set up debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(query.trim(), saveToHistory: false);
    });
  }

  // Confirmed search that saves to history
  Future<void> confirmedSearch(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < _minQueryLength) return;
    
    _debounceTimer?.cancel();
    await _performSearch(normalizedQuery, saveToHistory: true);
  }

  // Search when user taps on a result
  void onResultTapped(String query) {
    _addToSearchHistory(query);
  }

  Future<void> _performSearch(String query, {required bool saveToHistory}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await SearchMultiService.searchMulti(query);
      
      // Only save to history if this is a confirmed search
      if (saveToHistory) {
        _addToSearchHistory(query);
      }
    } catch (e) {
      _error = e.toString();
      _results.clear();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _clearResults() {
    _results.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
