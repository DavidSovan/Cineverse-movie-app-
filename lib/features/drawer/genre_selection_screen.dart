import 'package:cineverse/core/theme/text_styles.dart';
import 'package:cineverse/features/drawer/watchlist_item.dart';
import 'package:cineverse/features/movies/models/movies.dart';
import 'package:cineverse/features/movies/screens/movie_detail_screen.dart';
import 'package:cineverse/features/movies/services/movies_api_service.dart';
import 'package:cineverse/shared/widgets/animated_movie_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'genre_provider.dart';

class MoviesByGenreScreen extends StatefulWidget {
  final int genreId;
  final String genreName;

  const MoviesByGenreScreen({
    Key? key,
    required this.genreId,
    required this.genreName,
  }) : super(key: key);

  @override
  MoviesByGenreScreenState createState() => MoviesByGenreScreenState();
}

class MoviesByGenreScreenState extends State<MoviesByGenreScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GenreProvider>().fetchMoviesByGenre(widget.genreId);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<GenreProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.genreName,
          style: AppTextStyles.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<GenreProvider>(
        builder: (context, genreProvider, child) {
          if (genreProvider.isLoading && genreProvider.movies.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (genreProvider.errorMessage != null &&
              genreProvider.movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading movies',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    genreProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      genreProvider.fetchMoviesByGenre(widget.genreId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (genreProvider.movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie_outlined,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No movies found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    'No movies available for ${widget.genreName}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await genreProvider.fetchMoviesByGenre(widget.genreId);
            },
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: genreProvider.movies.length +
                  (genreProvider.isLoading ? 2 : 0),
              itemBuilder: (context, index) {
                if (index >= genreProvider.movies.length) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final movie = genreProvider.movies[index];
                return _buildMovieCard(movie, index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieCard(Movie movie, int index) {
    return AnimatedMovieCard(
      movie: movie,
      apiService: Provider.of<MovieApiService>(context, listen: false),
      onTap: (Movie tappedMovie) {
        // Navigate to movie detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(
              item: WatchlistItem(
                id: movie.id,
                title: movie.title,
                posterPath: movie.posterPath,
                mediaType: 'movie',
                releaseDate: movie.releaseDate,
              ),
              movieId: movie.id,
            ),
          ),
        );
      },
      index: index,
    );
  }
}
