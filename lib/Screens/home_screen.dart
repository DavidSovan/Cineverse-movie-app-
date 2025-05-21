import 'package:cineverse/Models/movies.dart';
import 'package:cineverse/Screens/movie_detail_screen.dart';
import 'package:cineverse/Screens/search_movies_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineverse/Providers/movies_provider.dart';
import 'package:cineverse/Services/movies_api_service.dart';
import 'package:cineverse/Widgets/animated_movie_card.dart';
import 'package:cineverse/Widgets/movie_shimmer_loading.dart';
import 'package:cineverse/Theme/text_styles.dart';
import 'package:cineverse/Theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch movies when the home screen loads

    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<MovieProvider>().fetchPopularMovies();
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
      appBar: AppBar(
        title: Text(
          'Cineverse',
          style: AppTextStyles.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryRed,
                AppColors.darkRed,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: _buildBody(movieProvider, apiService),
      ),
    );
  }

  Widget _buildBody(MovieProvider movieProvider, MovieApiService apiService) {
    if (movieProvider.isLoading) {
      return const MovieShimmerLoading();
    }

    if (movieProvider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${movieProvider.error}',
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => movieProvider.fetchPopularMovies(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (movieProvider.movies.isEmpty) {
      return const Center(child: Text('No movies found'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular Movies Horizontal Scroll
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Popular Movies',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: movieProvider.movies.length,
              itemBuilder: (context, index) {
                final movie = movieProvider.movies[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 150,
                    child: AnimatedMovieCard(
                      movie: movie,
                      apiService: apiService,
                      onTap: (movie) => _navigateToMovieDetails(context, movie),
                      index: index,
                    ),
                  ),
                );
              },
            ),
          ),

          // All Movies Grid (with pagination placeholder)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'All Movies',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: movieProvider.movies.length,
            itemBuilder: (context, index) {
              final movie = movieProvider.movies[index];
              return AnimatedMovieCard(
                movie: movie,
                apiService: apiService,
                onTap: (movie) => _navigateToMovieDetails(context, movie),
                index: index,
              );
            },
          ),

          // Pagination Loading Indicator (placeholder)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Load More',
                style: AppTextStyles.textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryRed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
