class MovieCredits {
  final int id;
  final List<Cast> cast;

  const MovieCredits({
    required this.id,
    required this.cast,
  });

  factory MovieCredits.fromJson(Map<String, dynamic> json) {
    var castList = (json['cast'] as List?) ?? [];
    List<Cast> casts =
        castList.map((i) => Cast.fromJson(i as Map<String, dynamic>)).toList();

    return MovieCredits(
      id: json['id'] as int? ?? 0,
      cast: casts,
    );
  }
}

class Cast {
  final int id;
  final String name;
  final String originalName;
  final String? profilePath;
  final String character;

  const Cast({
    required this.id,
    required this.name,
    required this.originalName,
    this.profilePath,
    required this.character,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'] as int,
      name: json['name'] as String,
      originalName: json['original_name'] as String,
      profilePath: json['profile_path'] as String?,
      character: json['character'] as String,
    );
  }
}
