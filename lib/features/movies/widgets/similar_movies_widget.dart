import 'package:cineverse/features/drawer/watchlist_item.dart';
import 'package:cineverse/features/movies/models/movies.dart';
import 'package:cineverse/features/movies/providers/similar_movie_provider.dart';
import 'package:cineverse/features/movies/screens/movie_detail_screen.dart';
import 'package:cineverse/features/movies/services/movies_api_service.dart';
import 'package:cineverse/shared/widgets/animated_movie_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SimilarMoviesGridWidget extends StatelessWidget {
  final int movieId;
  final VoidCallback? onMovieTap;

  const SimilarMoviesGridWidget({
    Key? key,
    required this.movieId,
    this.onMovieTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SimilarMoviesProvider()..fetchSimilarMovies(movieId),
      child: Consumer<SimilarMoviesProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context),
                const SizedBox(height: 16),
                _buildContent(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Text(
      'Similar Movies',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildContent(BuildContext context, SimilarMoviesProvider provider) {
    switch (provider.state) {
      case SimilarMoviesState.loading:
        return _buildLoadingState();
      case SimilarMoviesState.loaded:
        return _buildLoadedState(context, provider.similarMovies);
      case SimilarMoviesState.error:
        return _buildErrorState(context, provider.errorMessage, provider);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6, // Show 6 skeleton items
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Container(
                        height: 12,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadedState(BuildContext context, List<Movie> movies) {
    if (movies.isEmpty) {
      return _buildEmptyState();
    }

    // Show all similar movies
    final displayMovies = movies;

    return GridView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return AnimatedMovieCard(
          movie: displayMovies[index],
          apiService: Provider.of<MovieApiService>(context, listen: false),
          onTap: (movie) => _onMovieCardTap(context, movie),
          index: index,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'No similar movies found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage,
      SimilarMoviesProvider provider) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load similar movies',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => provider.fetchSimilarMovies(movieId),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMovieCardTap(BuildContext context, Movie movie) {
    // Navigate to movie detail screen or handle movie selection
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

    // Or call the optional callback
    onMovieTap?.call();
  }
}
