import 'package:cineverse/Models/movies.dart';
import 'package:cineverse/Screens/movie_detail_screen.dart';
import 'package:cineverse/Screens/search_movies_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineverse/Providers/movies_provider.dart';
import 'package:cineverse/Providers/genre_provider.dart';
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
    // Fetch movies and genres when the home screen loads
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<MovieProvider>().fetchPopularMovies();
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
      drawer: Drawer(
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
                    ListTile(
                      title: const Text('All Movies'),
                      selected: genreProvider.selectedGenre == null,
                      onTap: () {
                        genreProvider.clearGenreSelection();
                        context.read<MovieProvider>().fetchPopularMovies();
                        Navigator.pop(context);
                      },
                    ),
                    if (genreProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (genreProvider.errorMessage != null)
                      ListTile(
                        title: Text('Error: ${genreProvider.errorMessage}'),
                        textColor: Colors.red,
                      )
                    else
                      ...genreProvider.genres.map((genre) => ListTile(
                            title: Text(genre.name),
                            selected:
                                genreProvider.selectedGenre?.id == genre.id,
                            onTap: () {
                              genreProvider.fetchMoviesByGenre(genre.id);
                              Navigator.pop(context);
                            },
                          )),
                  ],
                ),
              ],
            );
          },
        ),
      ),
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
