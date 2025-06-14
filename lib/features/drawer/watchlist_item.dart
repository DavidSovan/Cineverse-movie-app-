import 'dart:convert';

class WatchlistItem {
  final int id;
  final String title;
  final String posterPath;
  final String mediaType; // "movie" or "tv"
  final String releaseDate;
  bool isInWatchlist;

  WatchlistItem({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.mediaType,
    required this.releaseDate,
    this.isInWatchlist = false,
  });

  // Convert object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'mediaType': mediaType,
      'releaseDate': releaseDate,
      'isInWatchlist': isInWatchlist ? 1 : 0,
    };
  }

  // Create object from Map
  factory WatchlistItem.fromMap(Map<String, dynamic> map) {
    return WatchlistItem(
      id: map['id'],
      title: map['title'],
      posterPath: map['posterPath'],
      mediaType: map['mediaType'],
      releaseDate: map['releaseDate'],
      isInWatchlist: map['isInWatchlist'] == 1,
    );
  }

  // Convert object to JSON
  String toJson() => json.encode(toMap());

  // Convert JSON to object
  factory WatchlistItem.fromJson(String source) =>
      WatchlistItem.fromMap(json.decode(source));
}
