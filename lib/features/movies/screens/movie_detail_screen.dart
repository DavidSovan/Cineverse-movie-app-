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
        // Fetch movie details
        Provider.of<DetailMoviesProvider>(context, listen: false)
            .fetchMovieDetails(widget.movieId);

        // Check if item is already in watchlist
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

  /// Updated _toggleWatchlistStatus method for your MovieDetailsScreen

  Future<void> _toggleWatchlistStatus() async {
    final watchlistProvider =
        Provider.of<WatchlistProvider>(context, listen: false);

    try {
      if (widget.item.isInWatchlist) {
        // Remove from watchlist
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
        // Add to watchlist
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
      // Handle any errors
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

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                actions: [
                  // Watchlist button
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
                  title: Text(
                    movie.title,
                    style: AppTextStyles.featuredMovieTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag:
                            'movie_backdrop_${movie.id}', // Changed tag to be unique
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
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
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
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (movie.tagline != null &&
                                  movie.tagline!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    movie.tagline!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: AppColors.lightGrey,
                                        ),
                                  ),
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          AppDimensions.cardBorderRadius),
                                      child: Image.network(
                                        apiService
                                            .getImageUrl(movie.posterPath),
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow(context, 'Rating',
                                            '${movie.voteAverage}/10'),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(context, 'Released',
                                            movie.releaseDate),
                                        if (movie.runtime != null) ...[
                                          const SizedBox(height: 8),
                                          _buildInfoRow(
                                            context,
                                            'Runtime',
                                            '${movie.runtime} min',
                                          ),
                                        ],
                                        if (movie.status != null) ...[
                                          const SizedBox(height: 8),
                                          _buildInfoRow(
                                              context, 'Status', movie.status!),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Overview',
                                style: AppTextStyles.sectionHeader,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                movie.overview,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              if (movie.genres != null &&
                                  movie.genres!.isNotEmpty) ...[
                                Text(
                                  'Genres',
                                  style: AppTextStyles.sectionHeader,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: movie.genres!.map((genre) {
                                    return Chip(
                                      label: Text(genre.name),
                                      backgroundColor: AppColors.mediumGrey,
                                      labelStyle:
                                          const TextStyle(color: Colors.white),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 24),
                              ],
                              /*
                              
                              Movie Videos

                              */
                              MovieVideosWidget(
                                movieId: widget.movieId,
                                title: 'Official Trailers',
                                padding: EdgeInsets.zero,
                                maxVideos: 3,
                              ),
                              const SizedBox(height: 24),

                              /*
                              
                              Movie Credits

                              */

                              ChangeNotifierProvider(
                                create: (context) => MovieCreditsProvider(),
                                child: Container(
                                  height:
                                      300, // Fixed height to prevent layout issues
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Theme.of(context).cardColor,
                                  ),
                                  child: MovieCreditsWidget(
                                      movieId: widget.movieId),
                                ),
                              ),
                              const SizedBox(height: 24),

                              /*
                              
                              Similar Movies

                              */
                              SimilarMoviesGridWidget(
                                movieId: widget.movieId,
                              ),
                              const SizedBox(height: 24),
                              const SizedBox(height: 24),
                              if (movie.budget != null &&
                                  movie.budget! > 0) ...[
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  context,
                                  'Budget',
                                  '\$${_formatCurrency(movie.budget!)}',
                                ),
                              ],
                              if (movie.revenue != null &&
                                  movie.revenue! > 0) ...[
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  'Revenue',
                                  '\$${_formatCurrency(movie.revenue!)}',
                                ),
                              ],
                              if (movie.homepage != null &&
                                  movie.homepage!.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final url = Uri.parse(movie.homepage!);
                                    try {
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url,
                                            mode:
                                                LaunchMode.externalApplication);
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Could not open the website'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error opening website: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.language),
                                  label: const Text('Visit Website'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryRed,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
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
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
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
