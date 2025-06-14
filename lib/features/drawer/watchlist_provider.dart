import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'watchlist_item.dart';

class WatchlistProvider extends ChangeNotifier {
  static const String _storageKey = 'watchlist';
  List<WatchlistItem> _items = [];

  List<WatchlistItem> get items => _items;

  WatchlistProvider() {
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];

    _items = jsonList.map((item) => WatchlistItem.fromJson(item)).toList();
    notifyListeners();
  }

  Future<void> saveWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _items.map((item) => item.toJson()).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  bool isInWatchlist(int id) {
    return _items.any((item) => item.id == id);
  }

  Future<void> addToWatchlist(WatchlistItem item) async {
    if (!isInWatchlist(item.id)) {
      _items.add(item);
      await saveWatchlist();
      notifyListeners();
    }
  }

  Future<void> removeFromWatchlist(int id) async {
    _items.removeWhere((item) => item.id == id);
    await saveWatchlist();
    notifyListeners();
  }

  Future<void> toggleWatchlist(WatchlistItem item) async {
    if (isInWatchlist(item.id)) {
      await removeFromWatchlist(item.id);
    } else {
      await addToWatchlist(item);
    }
  }
}
