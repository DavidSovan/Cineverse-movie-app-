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
        child,
        if (isLoading)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: overlayColor ?? Colors.black.withOpacity(0.6),
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
      setState(() {
        _loadingMessage = 'Welcome to Cineverse...';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _loadingMessage = 'Loading trending movies...';
      });

      if (mounted) {
        await Future.wait([
          context.read<MovieProvider>().fetchPopularMovies(),
          Future.delayed(const Duration(milliseconds: 500)),
        ]);
      }

      setState(() {
        _loadingMessage = 'Setting up categories...';
      });

      if (mounted) {
        await Future.wait([
          context.read<GenreProvider>().fetchGenres(),
          Future.delayed(const Duration(milliseconds: 500)),
        ]);
      }

      setState(() {
        _loadingMessage = 'Almost ready...';
      });
      await Future.delayed(const Duration(milliseconds: 600));
    } catch (error) {
      setState(() {
        _loadingMessage = 'Something went wrong. Retrying...';
      });
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        _initializeHomeScreen();
        return;
      }
    }

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

    bool shouldShowLoading = _isInitialLoading;

    return Scaffold(
      drawer: const HomeDrawer(),
      appBar: const HomeAppBar(),
      body: LoadingWrapper(
        isLoading: shouldShowLoading,
        loadingMessage: _loadingMessage,
        loadingStyle: LoadingStyle.elegant,
        primaryColor: AppColors.primaryRed,
        overlayColor: Colors.black.withOpacity(0.7),
        blurBackground: true,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildBody(movieProvider, apiService),
                const SizedBox(height: 32),
                const UpcomingMoviesSection(),
                const SizedBox(height: 32),
                const PopularTvWidget(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(MovieProvider movieProvider, MovieApiService apiService) {
    final genreProvider = Provider.of<GenreProvider>(context);

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
      return _buildErrorState(genreProvider, movieProvider);
    }

    final movies = genreProvider.selectedGenre != null
        ? genreProvider.movies
        : movieProvider.movies;

    if (movies.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured Hero Carousel Section
        if (movies.isNotEmpty) _buildFeaturedCarousel(movies, apiService),

        const SizedBox(height: 32),

        // Category Header
        _buildCategoryHeader(genreProvider, movies, movieProvider),

        const SizedBox(height: 16),

        // Movies Grid
        _buildMoviesGrid(movies, apiService),

        // Load More Button
        if (genreProvider.selectedGenre != null &&
            genreProvider.currentPage < genreProvider.totalPages)
          _buildLoadMoreButton(genreProvider),
      ],
    );
  }

  // Featured Hero Carousel
  Widget _buildFeaturedCarousel(List<Movie> movies, MovieApiService apiService) {
    // Take top 5 movies for the carousel
    final featuredMovies = movies.take(5).toList();
    
    return SizedBox(
      height: 420,
      child: PageView.builder(
        padEnds: false,
        controller: PageController(viewportFraction: 0.92),
        itemCount: featuredMovies.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildFeaturedHero(featuredMovies[index], apiService, index),
          );
        },
      ),
    );
  }

  // Featured Hero Banner (Individual)
  Widget _buildFeaturedHero(Movie movie, MovieApiService apiService, int index) {
    return GestureDetector(
      onTap: () => _navigateToMovieDetails(context, movie),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryRed.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.network(
                apiService.getImageUrl(movie.backdropPath.isNotEmpty ? movie.backdropPath : movie.posterPath,
                    isBackdrop: true),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryRed,
                          AppColors.darkRed,
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Gradient Overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Content
              Positioned(
                left: 20,
                right: 20,
                bottom: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Featured Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryRed,
                            AppColors.darkRed,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryRed.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            index == 0 ? 'FEATURED' : 'TOP ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 8.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Rating & Release Date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white70,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.releaseDate.split('-').first,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Watch Now Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryRed,
                            AppColors.darkRed,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryRed.withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Watch Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Category Header with improved styling
  Widget _buildCategoryHeader(
    GenreProvider genreProvider,
    List<Movie> movies,
    MovieProvider movieProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Decorative Line
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryRed,
                  AppColors.darkRed,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(width: 12),

          // Category Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  genreProvider.selectedGenre?.name ?? 'Trending Now',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryRed.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${movies.length} movies',
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Clear Filter Button
          if (genreProvider.selectedGenre != null)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryRed.withOpacity(0.1),
                    AppColors.darkRed.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryRed.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _showActionLoading('Loading trending movies...');
                    genreProvider.clearGenreSelection();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      movieProvider.fetchPopularMovies();
                      _hideLoading();
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.clear,
                          color: AppColors.primaryRed,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Show All',
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Movies Grid with improved layout
  Widget _buildMoviesGrid(List<Movie> movies, MovieApiService apiService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 20,
          crossAxisSpacing: 16,
          childAspectRatio: 0.63,
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
    );
  }

  // Load More Button with improved design
  Widget _buildLoadMoreButton(GenreProvider genreProvider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primaryRed,
                AppColors.darkRed,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryRed.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _showActionLoading('Loading more movies...');
                Future.delayed(const Duration(milliseconds: 300), () {
                  genreProvider.loadMore();
                  _hideLoading();
                });
              },
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Load More Movies',
                      style: AppTextStyles.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Error State with better visuals
  Widget _buildErrorState(
      GenreProvider genreProvider, MovieProvider movieProvider) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.error.withOpacity(0.1),
              AppColors.error.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.error.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              genreProvider.errorMessage ?? 'Unable to load movies',
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryRed,
                    AppColors.darkRed,
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRed.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
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
                  borderRadius: BorderRadius.circular(25),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Try Again',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty State with illustration
  Widget _buildEmptyState() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryRed.withOpacity(0.1),
                    AppColors.darkRed.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.movie_outlined,
                size: 80,
                color: AppColors.primaryRed.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No movies found',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try refreshing or selecting\na different category',
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}