class Person {
  final int id;
  final String name;
  final String biography;
  final String? birthday;
  final String? deathday;
  final int gender;
  final String? homepage;
  final String? imdbId;
  final String knownForDepartment;
  final String? placeOfBirth;
  final String? profilePath;
  final List<String> alsoKnownAs;

  Person({
    required this.id,
    required this.name,
    required this.biography,
    this.birthday,
    this.deathday,
    required this.gender,
    this.homepage,
    this.imdbId,
    required this.knownForDepartment,
    this.placeOfBirth,
    this.profilePath,
    required this.alsoKnownAs,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      biography: json['biography'] ?? 'No biography available',
      birthday: json['birthday'],
      deathday: json['deathday'],
      gender: json['gender'] ?? 0,
      homepage: json['homepage'],
      imdbId: json['imdb_id'],
      knownForDepartment: json['known_for_department'] ?? 'Not specified',
      placeOfBirth: json['place_of_birth'],
      profilePath: json['profile_path'],
      alsoKnownAs: List<String>.from(json['also_known_as'] ?? []),
    );
  }
}
