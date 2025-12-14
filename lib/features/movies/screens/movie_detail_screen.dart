import 'package:cineverse/core/theme/colors.dart';
import 'package:cineverse/core/theme/demensions.dart';
import 'package:cineverse/core/theme/text_styles.dart';
import 'package:cineverse/features/drawer/watchlist_item.dart';
import 'package:cineverse/features/drawer/watchlist_provider.dart';
import 'package:cineverse/features/movies/providers/movie_credits_provider.dart';
import 'package:cineverse/features/movies/widgets/movie_credit_widget.dart';
import 'package:cineverse/features/movies/widgets/movie_videos_widget.dart';
import 'package:cineverse/features/movies/widgets/similar_movies_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cineverse/features/movies/providers/detail_movies_provider.dart';
import 'package:cineverse/features/movies/services/movies_api_service.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;
  final WatchlistItem item;

  const MovieDetailsScreen({
    Key? key,
    required this.movieId,
    required this.item,
  }) : super(key: key);

  @override
  MovieDetailsScreenState createState() => MovieDetailsScreenState();
}

class MovieDetailsScreenState extends State<MovieDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.microtask(() {
      if (mounted) {
        Provider.of<DetailMoviesProvider>(context, listen: false)
            .fetchMovieDetails(widget.movieId);

        final watchlistProvider =
            Provider.of<WatchlistProvider>(context, listen: false);
        final isInWatchlist = watchlistProvider.isInWatchlist(widget.item.id);

        setState(() {
          widget.item.isInWatchlist = isInWatchlist;
        });

        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleWatchlistStatus() async {
    final watchlistProvider =
        Provider.of<WatchlistProvider>(context, listen: false);

    try {
      if (widget.item.isInWatchlist) {
        await watchlistProvider.removeFromWatchlist(widget.item.id);
        setState(() {
          widget.item.isInWatchlist = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from Watchlist'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        await watchlistProvider.addToWatchlist(widget.item);
        setState(() {
          widget.item.isInWatchlist = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to Watchlist'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<MovieApiService>(context, listen: false);

    return Consumer<DetailMoviesProvider>(
      builder: (context, movieProvider, child) {
        if (movieProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (movieProvider.error != null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error: ${movieProvider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final movie = movieProvider.currentMovie;
        if (movie == null) {
          return const Scaffold(
            body: Center(child: Text('No movie data available')),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isLargeScreen = screenWidth > 600;
            final isExtraLargeScreen = screenWidth > 1200;

            final expandedHeight = isExtraLargeScreen
                ? 400.0
                : isLargeScreen
                    ? 350.0
                    : 300.0;

            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: expandedHeight,
                    floating: false,
                    pinned: true,
                    actions: [
                      IconButton(
                        icon: Icon(
                          widget.item.isInWatchlist
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _toggleWatchlistStatus,
                        tooltip: widget.item.isInWatchlist
                            ? 'Remove from Watchlist'
                            : 'Add to Watchlist',
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      title: GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: movie.title));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copied: ${movie.title}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(
                          movie.title,
                          style: AppTextStyles.featuredMovieTitle.copyWith(
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 8.0,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ],
                          ),
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: 'movie_backdrop_${movie.id}',
                            child: Image.network(
                              apiService.getImageUrl(movie.backdropPath,
                                  isBackdrop: true),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
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
                                );
                              },
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isExtraLargeScreen
                                    ? 48.0
                                    : isLargeScreen
                                        ? 32.0
                                        : 16.0,
                                vertical: 24.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tagline
                                  if (movie.tagline != null &&
                                      movie.tagline!.isNotEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20.0),
                                      child: Text(
                                        '"${movie.tagline!}"',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontStyle: FontStyle.italic,
                                              color: AppColors.lightGrey,
                                              fontSize: 16,
                                            ),
                                      ),
                                    ),

                                  // Main Content Card
                                  _buildMainInfoCard(
                                    context,
                                    movie,
                                    apiService,
                                    isLargeScreen,
                                    screenWidth,
                                  ),

                                  const SizedBox(height: 32),

                                  // Overview Section
                                  _buildSectionCard(
                                    context,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Overview',
                                          style: AppTextStyles.sectionHeader,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          movie.overview,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                height: 1.6,
                                                fontSize: 15,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Genres
                                  if (movie.genres != null &&
                                      movie.genres!.isNotEmpty)
                                    _buildGenresSection(context, movie),

                                  const SizedBox(height: 24),

                                  // Action Buttons
                                  _buildActionButtons(context, movie),

                                  const SizedBox(height: 32),

                                  // Videos Section
                                  _buildSectionCard(
                                    context,
                                    child: MovieVideosWidget(
                                      movieId: widget.movieId,
                                      title: 'Official Trailers',
                                      padding: EdgeInsets.zero,
                                      maxVideos: 3,
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Credits Section
                                  _buildSectionCard(
                                    context,
                                    child: SizedBox(
                                      height: 300,
                                      child: ChangeNotifierProvider(
                                        create: (context) =>
                                            MovieCreditsProvider(),
                                        child: MovieCreditsWidget(
                                            movieId: widget.movieId),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Similar Movies Section
                                  SimilarMoviesGridWidget(
                                    movieId: widget.movieId,
                                  ),

                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Main info card with poster and details
  Widget _buildMainInfoCard(
    BuildContext context,
    dynamic movie,
    MovieApiService apiService,
    bool isLargeScreen,
    double screenWidth,
  ) {
    final posterWidth = (screenWidth * 0.25).clamp(120.0, 200.0);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster with shadow
          Container(
            width: posterWidth,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppDimensions.cardBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.cardBorderRadius),
                child: Image.network(
                  apiService.getImageUrl(movie.posterPath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.mediumGrey,
                      child: const Icon(
                        Icons.movie,
                        size: 48,
                        color: Colors.white54,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: isLargeScreen ? 24 : 16),

          // Movie Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating with stars
                _buildRatingRow(context, movie.voteAverage),
                const SizedBox(height: 16),

                // Info rows
                _buildInfoChip(context, Icons.calendar_today, movie.releaseDate),
                if (movie.runtime != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoChip(
                      context, Icons.access_time, '${movie.runtime} min'),
                ],
                if (movie.status != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoChip(context, Icons.info_outline, movie.status!),
                ],

                // Budget & Revenue
                if (movie.budget != null && movie.budget! > 0) ...[
                  const SizedBox(height: 12),
                  _buildInfoChip(context, Icons.attach_money,
                      'Budget: \$${_formatCurrency(movie.budget!)}'),
                ],
                if (movie.revenue != null && movie.revenue! > 0) ...[
                  const SizedBox(height: 12),
                  _buildInfoChip(context, Icons.trending_up,
                      'Revenue: \$${_formatCurrency(movie.revenue!)}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Rating with visual stars
  Widget _buildRatingRow(BuildContext context, double rating) {
    final starCount = (rating / 2).round();
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < starCount ? Icons.star : Icons.star_border,
              color: AppColors.primaryRed,
              size: 24,
            );
          }),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryRed,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${rating.toStringAsFixed(1)}/10',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // Info chip with icon
  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.lightGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightGrey,
                  fontSize: 14,
                ),
          ),
        ),
      ],
    );
  }

  // Genres with gradient chips
  Widget _buildGenresSection(BuildContext context, dynamic movie) {
    return _buildSectionCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Genres',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: movie.genres!.map<Widget>((genre) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryRed.withOpacity(0.8),
                      AppColors.darkRed,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryRed.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  genre.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Action buttons section
  Widget _buildActionButtons(BuildContext context, dynamic movie) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final streamUrl = Uri.parse(
                'https://vidsrc.to/embed/movie/${movie.id}',
              );
              try {
                if (await canLaunchUrl(streamUrl)) {
                  await launchUrl(
                    streamUrl,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open streaming URL'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error opening stream: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.play_circle_filled, size: 24),
            label: const Text('Watch Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
        if (movie.homepage != null && movie.homepage!.isNotEmpty) ...[
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final url = Uri.parse(movie.homepage!);
              try {
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open the website'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error opening website: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.language),
            label: const Text('Website'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryRed,
              side: const BorderSide(color: AppColors.primaryRed, width: 2),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Reusable section card wrapper
  Widget _buildSectionCard(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }

  
  String _formatCurrency(int amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }
}