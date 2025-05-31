class MovieVideosResponse {
  final int id;
  final List<Video> results;

  MovieVideosResponse({
    required this.id,
    required this.results,
  });

  factory MovieVideosResponse.fromJson(Map<String, dynamic> json) {
    return MovieVideosResponse(
      id: json['id'],
      results: (json['results'] as List)
          .map((i) => Video.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Video {
  final String iso6391;
  final String iso31661;
  final String name;
  final String key;
  final String site;
  final int size;
  final String type;
  final bool official;
  final DateTime publishedAt;
  final String id;

  Video({
    required this.iso6391,
    required this.iso31661,
    required this.name,
    required this.key,
    required this.site,
    required this.size,
    required this.type,
    required this.official,
    required this.publishedAt,
    required this.id,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      iso6391: json['iso_639_1'] as String,
      iso31661: json['iso_3166_1'] as String,
      name: json['name'] as String,
      key: json['key'] as String,
      site: json['site'] as String,
      size: json['size'] as int,
      type: json['type'] as String,
      official: json['official'] as bool,
      publishedAt: DateTime.parse(json['published_at'] as String),
      id: json['id'] as String,
    );
  }
}
