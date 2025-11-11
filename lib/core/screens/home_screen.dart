import 'package:cineverse/core/screens/widgets/home_app_bar.dart';
import 'package:cineverse/core/screens/widgets/home_drawer.dart';
import 'package:cineverse/core/screens/widgets/loading_animation.dart';
import 'package:cineverse/core/theme/colors.dart';
import 'package:cineverse/core/theme/text_styles.dart';
import 'package:cineverse/features/drawer/genre_provider.dart';
import 'package:cineverse/features/drawer/watchlist_item.dart';
import 'package:cineverse/features/movies/models/movies.dart';
import 'package:cineverse/features/movies/providers/movies_provider.dart';
import 'package:cineverse/features/movies/screens/movie_detail_screen.dart';
import 'package:cineverse/features/movies/services/movies_api_service.dart';
import 'package:cineverse/features/movies/widgets/upcoming_movies_section.dart';
import 'package:cineverse/features/tv_shows/widgets/popular_tv_widget.dart';
import 'package:cineverse/shared/widgets/animated_movie_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

// Loading Wrapper Widget
class LoadingWrapper extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final LoadingStyle loadingStyle;
  final Color? primaryColor;
  final Color? overlayColor;
  final bool blurBackground;

  const LoadingWrapper({
    Key? key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.loadingStyle = LoadingStyle.elegant,
    this.primaryColor,
    this.overlayColor,
    this.blurBackground = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Your main content
        child,

        // Loading overlay
        if (isLoading)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: overlayColor ?? Colors.black.withValues(alpha: 0.6),
            child: blurBackground
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: _buildLoadingContent(context),
                  )
                : _buildLoadingContent(context),
          ),
      ],
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return LoadingAnimation(
      message: loadingMessage,
      style: loadingStyle,
      primaryColor: primaryColor ?? Theme.of(context).primaryColor,
      size: 80,
      showPulseEffect: true,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialLoading = true;
  String _loadingMessage = 'Welcome to Cineverse...';

  @override
  void initState() {
    super.initState();
    _initializeHomeScreen();
  }

  Future<void> _initializeHomeScreen() async {
    try {
      // Phase 1: Welcome message
      setState(() {
        _loadingMessage = 'Welcome to Cineverse...';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      // Phase 2: Loading movies
      setState(() {
        _loadingMessage = 'Loading trending movies...';
      });

      if (mounted) {
        await Future.wait([
          context.read<MovieProvider>().fetchPopularMovies(),
          Future.delayed(
              const Duration(milliseconds: 500)), // Minimum loading time for UX
        ]);
      }

      // Phase 3: Loading genres
      setState(() {
        _loadingMessage = 'Setting up categories...';
      });

      if (mounted) {
        await Future.wait([
          context.read<GenreProvider>().fetchGenres(),
          Future.delayed(const Duration(milliseconds: 500)),
        ]);
      }

      // Phase 4: Final setup
      setState(() {
        _loadingMessage = 'Almost ready...';
      });
      await Future.delayed(const Duration(milliseconds: 600));
    } catch (error) {
      // Handle initialization errors
      setState(() {
        _loadingMessage = 'Something went wrong. Retrying...';
      });
      await Future.delayed(const Duration(seconds: 1));

      // Retry initialization
      if (mounted) {
        _initializeHomeScreen();
        return;
      }
    }

    // Hide loading
    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  void _navigateToMovieDetails(BuildContext context, Movie movie) {
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
  }

  // Method to show loading for specific actions
  void _showActionLoading(String message) {
    setState(() {
      _isInitialLoading = true;
      _loadingMessage = message;
    });
  }

  void _hideLoading() {
    setState(() {
      _isInitialLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final apiService = Provider.of<MovieApiService>(context, listen: false);

    // Determine if we should show loading overlay
    bool shouldShowLoading = _isInitialLoading;

    return Scaffold(
      drawer: const HomeDrawer(),
      appBar: const HomeAppBar(),
      body: LoadingWrapper(
        isLoading: shouldShowLoading,
        loadingMessage: _loadingMessage,
        loadingStyle: LoadingStyle.elegant,
        primaryColor: AppColors.primaryRed,
        overlayColor: Colors.black.withValues(alpha: 0.7),
        blurBackground: true,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildBody(movieProvider, apiService),
                const UpcomingMoviesSection(),
                const PopularTvWidget(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(MovieProvider movieProvider, MovieApiService apiService) {
    final genreProvider = Provider.of<GenreProvider>(context);

    // Show section loading (smaller loading indicator for content updates)
    if (!_isInitialLoading &&
        (genreProvider.isLoading || movieProvider.isLoading)) {
      return const SizedBox(
        height: 200,
        child: LoadingAnimation(
          message: 'Updating content...',
          style: LoadingStyle.minimal,
          size: 40,
        ),
      );
    }

    if (genreProvider.errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: AppTextStyles.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                genreProvider.errorMessage!,
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _showActionLoading('Retrying...');
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (genreProvider.selectedGenre != null) {
                      genreProvider
                          .fetchMoviesByGenre(genreProvider.selectedGenre?.id);
                    } else {
                      movieProvider.fetchPopularMovies();
                    }
                    _hideLoading();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final movies = genreProvider.selectedGenre != null
        ? genreProvider.movies
        : movieProvider.movies;

    if (movies.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No movies found',
                style: AppTextStyles.textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try refreshing or selecting a different category',
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        genreProvider.selectedGenre?.name ?? 'Trending Now',
                        style: AppTextStyles.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${movies.length} movies available',
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (genreProvider.selectedGenre != null)
                  TextButton.icon(
                    onPressed: () {
                      _showActionLoading('Loading trending movies...');
                      genreProvider.clearGenreSelection();
                      Future.delayed(const Duration(milliseconds: 500), () {
                        movieProvider.fetchPopularMovies();
                        _hideLoading();
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Show All'),
                  ),
              ],
            ),
          ),

          // Movies Grid
          GridView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
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
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showActionLoading('Loading more movies...');
                    Future.delayed(const Duration(milliseconds: 300), () {
                      genreProvider.loadMore();
                      _hideLoading();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: Text(
                    'Load More',
                    style: AppTextStyles.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
