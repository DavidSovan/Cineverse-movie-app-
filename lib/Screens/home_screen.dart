import 'package:cineverse/Models/movies.dart';
import 'package:cineverse/Screens/movie_detail_screen.dart';
import 'package:cineverse/Widgets/home_app_bar.dart';
import 'package:cineverse/Widgets/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineverse/Providers/movies_provider.dart';
import 'package:cineverse/Providers/genre_provider.dart';
import 'package:cineverse/Services/movies_api_service.dart';
import 'package:cineverse/Widgets/animated_movie_card.dart';
import 'package:cineverse/Widgets/movie_shimmer_loading.dart';
import 'package:cineverse/Theme/text_styles.dart';
import 'package:cineverse/Theme/colors.dart';
import 'package:cineverse/Widgets/upcoming_movies_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch movies and genres when the home screen loads
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<MovieProvider>().fetchPopularMovies();
      // ignore: use_build_context_synchronously
      context.read<GenreProvider>().fetchGenres();
    });
  }

  void _navigateToMovieDetails(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movieId: movie.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final apiService = Provider.of<MovieApiService>(context, listen: false);

    return Scaffold(
      drawer: const HomeDrawer(),
      appBar: const HomeAppBar(),
      body: SingleChildScrollView(
        child: _buildBody(movieProvider, apiService),
      ),
    );
  }

  Widget _buildBody(MovieProvider movieProvider, MovieApiService apiService) {
    final genreProvider = Provider.of<GenreProvider>(context);

    if (genreProvider.isLoading || movieProvider.isLoading) {
      return const MovieShimmerLoading();
    }

    if (genreProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${genreProvider.errorMessage}',
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (genreProvider.selectedGenre != null) {
                  genreProvider
                      .fetchMoviesByGenre(genreProvider.selectedGenre?.id);
                } else {
                  movieProvider.fetchPopularMovies();
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Determine which movies to display
    final movies = genreProvider.selectedGenre != null
        ? genreProvider.movies
        : movieProvider.movies;

    if (movies.isEmpty) {
      return const Center(child: Text('No movies found'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with current category
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  genreProvider.selectedGenre?.name ?? 'Popular Movies',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (genreProvider.selectedGenre != null)
                  TextButton(
                    onPressed: () {
                      genreProvider.clearGenreSelection();
                      movieProvider.fetchPopularMovies();
                    },
                    child: const Text('Show All'),
                  ),
              ],
            ),
          ),

          // Movies Grid
          GridView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: 260, // Fixed height for each grid item
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return AnimatedMovieCard(
                movie: movie,
                apiService: apiService,
                onTap: (movie) => _navigateToMovieDetails(context, movie),
                index: index,
              );
            },
          ),

          // Upcoming Movies Section
          const UpcomingMoviesSection(),

          // Load More Button
          if (genreProvider.selectedGenre != null &&
              genreProvider.currentPage < genreProvider.totalPages)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () => genreProvider.loadMore(),
                  child: Text(
                    'Load More',
                    style: AppTextStyles.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
