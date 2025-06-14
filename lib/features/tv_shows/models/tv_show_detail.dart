import 'package:cineverse/features/drawer/genre.dart';
import 'package:cineverse/features/tv_shows/models/network.dart';

class TvShowDetail {
  final int id;
  final String name;
  final String originalName;
  final String overview;
  final String firstAirDate;
  final String lastAirDate;
  final int numberOfSeasons;
  final int numberOfEpisodes;
  final List<Genre> genres;
  final String originalLanguage;
  final List<String> originCountry;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final int voteCount;
  final String status;
  final String type;
  final List<Network> networks;

  TvShowDetail({
    required this.id,
    required this.name,
    required this.originalName,
    required this.overview,
    required this.firstAirDate,
    required this.lastAirDate,
    required this.numberOfSeasons,
    required this.numberOfEpisodes,
    required this.genres,
    required this.originalLanguage,
    required this.originCountry,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.status,
    required this.type,
    required this.networks,
  });

  factory TvShowDetail.fromJson(Map<String, dynamic> json) {
    return TvShowDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      overview: json['overview'] ?? '',
      firstAirDate: json['first_air_date'] ?? '',
      lastAirDate: json['last_air_date'] ?? '',
      numberOfSeasons: json['number_of_seasons'] ?? 0,
      numberOfEpisodes: json['number_of_episodes'] ?? 0,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((genre) => Genre.fromJson(genre))
              .toList() ??
          [],
      originalLanguage: json['original_language'] ?? '',
      originCountry: List<String>.from(json['origin_country'] ?? []),
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      networks: (json['networks'] as List<dynamic>?)
              ?.map((network) => Network.fromJson(network))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'original_name': originalName,
      'overview': overview,
      'first_air_date': firstAirDate,
      'last_air_date': lastAirDate,
      'number_of_seasons': numberOfSeasons,
      'number_of_episodes': numberOfEpisodes,
      'genres': genres.map((genre) => genre.toJson()).toList(),
      'original_language': originalLanguage,
      'origin_country': originCountry,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'status': status,
      'type': type,
      'networks': networks.map((network) => network.toJson()).toList(),
    };
  }

  String get fullPosterPath =>
      posterPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get fullBackdropPath => backdropPath.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w1280$backdropPath'
      : '';
}
