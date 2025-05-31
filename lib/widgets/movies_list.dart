import 'package:cineverse/models/movies.dart';
import 'package:cineverse/widgets/animated_movie_card.dart';
import 'package:flutter/material.dart';

class MovieList extends StatelessWidget {
  final List<Movie> movies;
  final dynamic apiService;
  final Function(Movie) onTap;

  const MovieList({
    Key? key,
    required this.movies,
    required this.apiService,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 200).floor();
        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount.clamp(2, 5),
            childAspectRatio: 0.7,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return AnimatedMovieCard(
              movie: movies[index],
              apiService: apiService,
              onTap: onTap,
              index: index,
            );
          },
        );
      },
    );
  }
}
