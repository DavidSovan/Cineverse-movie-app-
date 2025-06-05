import 'package:flutter/material.dart';
import 'package:cineverse/services/search_multi_service.dart';
import 'package:cineverse/models/search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchMultiProvider extends ChangeNotifier {
  List<SearchResult> _results = [];
  bool _isLoading = false;
  String? _error;
  List<String> _searchHistory = [];

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

  void addToSearchHistory(String query) {
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
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

  Future<void> search(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await SearchMultiService.searchMulti(query);
      addToSearchHistory(query);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
