class SearchResult {
  final int id;
  final String title;
  final String? posterPath;
  final String mediaType;
  final String? releaseDate;

  SearchResult({
    required this.id,
    required this.title,
    required this.mediaType,
    this.posterPath,
    this.releaseDate,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? json['name'] ?? 'Untitled',
      posterPath: json['poster_path'],
      mediaType: json['media_type'] ?? 'unknown',
      releaseDate: json['release_date'] ?? json['first_air_date'],
    );
  }
}
