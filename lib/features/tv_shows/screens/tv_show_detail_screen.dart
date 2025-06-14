import 'package:cineverse/features/drawer/watchlist_item.dart';
import 'package:cineverse/features/drawer/watchlist_provider.dart';
import 'package:cineverse/features/tv_shows/providers/tv_show_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TvShowDetailScreen extends StatefulWidget {
  final int tvId;
  final WatchlistItem item;

  const TvShowDetailScreen({
    Key? key,
    required this.tvId,
    required this.item,
  }) : super(key: key);

  @override
  State<TvShowDetailScreen> createState() => _TvShowDetailScreenState();
}

class _TvShowDetailScreenState extends State<TvShowDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TvShowDetailProvider>().fetchTvShowDetail(widget.tvId);

      // Check if the item is already in the watchlist
      final watchlistProvider = context.read<WatchlistProvider>();
      final isInWatchlist = watchlistProvider.isInWatchlist(widget.item.id);
      if (mounted) {
        setState(() {
          widget.item.isInWatchlist = isInWatchlist;
        });
      }
    });
  }

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              widget.item.isInWatchlist
                  ? Icons.bookmark_added
                  : Icons.bookmark_add_outlined,
              color: Colors.white,
            ),
            onPressed: _toggleWatchlistStatus,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Consumer<TvShowDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading TV show details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchTvShowDetail(widget.tvId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!provider.hasData) {
            return const Center(
              child: Text('No data available'),
            );
          }

          final tvShow = provider.tvShowDetail!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    tvShow.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  background: tvShow.fullBackdropPath.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              tvShow.fullBackdropPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                  ),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          color: Theme.of(context).primaryColor,
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Poster
                          Container(
                            width: 120,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: tvShow.fullPosterPath.isNotEmpty
                                  ? Image.network(
                                      tvShow.fullPosterPath,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 32,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.tv,
                                        size: 32,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tvShow.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (tvShow.originalName != tvShow.name) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    tvShow.originalName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${tvShow.voteAverage.toStringAsFixed(1)}/10',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${tvShow.voteCount} votes)',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    _buildInfoChip(
                                        tvShow.status, Icons.info_outline),
                                    _buildInfoChip(tvShow.type, Icons.tv),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Overview
                      if (tvShow.overview.isNotEmpty) ...[
                        Text(
                          'Overview',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tvShow.overview,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                  ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Show Info
                      _buildInfoSection(context, 'Show Information', [
                        _buildInfoRow('First Air Date', tvShow.firstAirDate),
                        _buildInfoRow('Last Air Date', tvShow.lastAirDate),
                        _buildInfoRow(
                            'Seasons', tvShow.numberOfSeasons.toString()),
                        _buildInfoRow(
                            'Episodes', tvShow.numberOfEpisodes.toString()),
                        _buildInfoRow(
                            'Language', tvShow.originalLanguage.toUpperCase()),
                        _buildInfoRow(
                            'Origin Country', tvShow.originCountry.join(', ')),
                      ]),

                      const SizedBox(height: 24),

                      // Genres
                      if (tvShow.genres.isNotEmpty) ...[
                        Text(
                          'Genres',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tvShow.genres
                              .map((genre) => Chip(
                                    label: Text(genre.name),
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.1),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Networks
                      if (tvShow.networks.isNotEmpty) ...[
                        Text(
                          'Networks',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        ...tvShow.networks.map((network) => Card(
                              child: ListTile(
                                leading: const Icon(Icons.tv),
                                title: Text(network.name),
                                subtitle: Text(network.originCountry),
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
