import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineverse/Providers/movies_provider.dart';
import 'package:cineverse/Providers/genre_provider.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<GenreProvider>(
        builder: (context, genreProvider, child) {
          return ListView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.25,
            ),
            children: [
              ExpansionTile(
                title: const Text('Genres'),
                initiallyExpanded: true,
                children: [
                  _buildAllMoviesTile(context, genreProvider),
                  ..._buildGenreContent(genreProvider, context),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllMoviesTile(
      BuildContext context, GenreProvider genreProvider) {
    return ListTile(
      title: const Text('All Movies'),
      selected: genreProvider.selectedGenre == null,
      onTap: () {
        genreProvider.clearGenreSelection();
        context.read<MovieProvider>().fetchPopularMovies();
        Navigator.pop(context);
      },
    );
  }

  List<Widget> _buildGenreContent(
      GenreProvider genreProvider, BuildContext context) {
    if (genreProvider.isLoading) {
      return [const Center(child: CircularProgressIndicator())];
    }

    if (genreProvider.errorMessage != null) {
      return [
        ListTile(
          title: Text('Error: ${genreProvider.errorMessage}'),
          textColor: Colors.red,
        )
      ];
    }

    return genreProvider.genres
        .map((genre) => ListTile(
              title: Text(genre.name),
              selected: genreProvider.selectedGenre?.id == genre.id,
              onTap: () {
                genreProvider.fetchMoviesByGenre(genre.id);
                Navigator.pop(context);
              },
            ))
        .toList();
  }
}
