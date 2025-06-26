class MovieCredit {
  final int id;
  final String title;
  final String? character;
  final String? job;
  final String? posterPath;

  MovieCredit({
    required this.id,
    required this.title,
    this.character,
    this.job,
    this.posterPath,
  });

  factory MovieCredit.fromJson(Map<String, dynamic> json) {
    return MovieCredit(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? 'Untitled',
      character: json['character'],
      job: json['job'],
      posterPath: json['poster_path'],
    );
  }
}
