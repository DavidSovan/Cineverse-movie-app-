// This class represents a single TV Show model with all its related fields
class TvShow {
  final bool adult;
  final String? backdropPath; // URL path for the backdrop image (nullable)
  final List<int> genreIds;
  final int id;
  final List<String> originCountry;
  final String originalLanguage;
  final String originalName;
  final String overview;
  final double popularity;
  final String? posterPath; // URL path for the poster image (nullable)
  final String firstAirDate;
  final String name;
  final double voteAverage;
  final int voteCount;

  // Constructor to initialize all the fields
  TvShow({
    required this.adult,
    this.backdropPath,
    required this.genreIds,
    required this.id,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalName,
    required this.overview,
    required this.popularity,
    this.posterPath,
    required this.firstAirDate,
    required this.name,
    required this.voteAverage,
    required this.voteCount,
  });

  // Factory constructor to create a TvShow object from a JSON map
  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      adult: json['adult'] ?? false,
      backdropPath: json['backdrop_path'],
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      id: json['id'],
      originCountry: List<String>.from(json['origin_country'] ?? []),
      originalLanguage: json['original_language'] ?? '',
      originalName: json['original_name'] ?? '',
      overview: json['overview'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
      posterPath: json['poster_path'],
      firstAirDate: json['first_air_date'] ?? '',
      name: json['name'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
    );
  }

  // Method to convert a TvShow object back into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'adult': adult,
      'backdrop_path': backdropPath,
      'genre_ids': genreIds,
      'id': id,
      'origin_country': originCountry,
      'original_language': originalLanguage,
      'original_name': originalName,
      'overview': overview,
      'popularity': popularity,
      'poster_path': posterPath,
      'first_air_date': firstAirDate,
      'name': name,
      'vote_average': voteAverage,
      'vote_count': voteCount,
    };
  }

  // Helper method to build the full URL of the poster image
  String get fullPosterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  // Helper method to build the full URL of the backdrop image
  String get fullBackdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';
}
