import 'package:cineverse/core/theme/text_styles.dart';
import 'package:cineverse/features/drawer/watchlist_item.dart';
import 'package:cineverse/features/movies/providers/upcoming_movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineverse/features/movies/services/movies_api_service.dart';
import 'package:cineverse/features/movies/screens/movie_detail_screen.dart';

class UpcomingMoviesSection extends StatelessWidget {
  const UpcomingMoviesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<MovieApiService>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Upcoming Movies',
            style: AppTextStyles.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: Consumer<UpcomingMoviesProvider>(
            builder: (context, upcomingMoviesProvider, child) {
              if (upcomingMoviesProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (upcomingMoviesProvider.error.isNotEmpty) {
                return Center(
                  child: Text('Error: ${upcomingMoviesProvider.error}'),
                );
              }

              if (upcomingMoviesProvider.upcomingMovies.isEmpty) {
                return const Center(
                    child: Text('No upcoming movies available'));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: upcomingMoviesProvider.upcomingMovies.length,
                itemBuilder: (context, index) {
                  final movie = upcomingMoviesProvider.upcomingMovies[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
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
                            movieId: movie.id),
                      ),
                    ),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              apiService.getImageUrl(movie.posterPath),
                              height: 160,
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                height: 160,
                                width: 120,
                                child: Icon(Icons.error),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
