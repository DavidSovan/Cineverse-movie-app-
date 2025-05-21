import 'package:cineverse/Models/movies.dart';
import 'package:cineverse/Models/genre.dart';

class DetailedMovie extends Movie {
  final List<Genre>? genres;
  final String? tagline;
  final int? runtime;
  final int? budget;
  final int? revenue;
  final String? status;
  final String? homepage;
  bool isFavorite = false;

  DetailedMovie({
    required int id,
    required String title,
    required String overview,
    required String posterPath,
    required String backdropPath,
    required double voteAverage,
    required String releaseDate,
    this.genres,
    this.tagline,
    this.runtime,
    this.budget,
    this.revenue,
    this.status,
    this.homepage,
  }) : super(
          id: id,
          title: title,
          overview: overview,
          posterPath: posterPath,
          backdropPath: backdropPath,
          voteAverage: voteAverage,
          releaseDate: releaseDate,
          adult: false,
        );

  factory DetailedMovie.fromJson(Map<String, dynamic> json) {
    List<Genre>? genres;
    if (json['genres'] != null) {
      genres = List<Genre>.from(
        (json['genres'] as List).map((genre) => Genre.fromJson(genre)),
      );
    }

    return DetailedMovie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      releaseDate: json['release_date'],
      genres: genres,
      tagline: json['tagline'],
      runtime: json['runtime'],
      budget: json['budget'],
      revenue: json['revenue'],
      status: json['status'],
      homepage: json['homepage'],
    );
  }

  bool get hasFullDetails => genres != null;
}
