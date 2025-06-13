import 'package:cineverse/models/watchlist_item.dart';
import 'package:cineverse/providers/tv_show_provider.dart';
import 'package:cineverse/screens/tv_show_detail_screen.dart';
import 'package:cineverse/widgets/animated_tv_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PopularTvWidget extends StatefulWidget {
  const PopularTvWidget({Key? key}) : super(key: key);

  @override
  State<PopularTvWidget> createState() => _PopularTvWidgetState();
}

class _PopularTvWidgetState extends State<PopularTvWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Fetch data when widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TvShowProvider>().fetchPopularTvShows(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TvShowProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TvShowProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular TV Shows',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (provider.isLoading && provider.popularTvShows.isEmpty)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),

            // Content
            SizedBox(
              height: 280,
              child: _buildContent(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(TvShowProvider provider) {
    if (provider.hasError && provider.popularTvShows.isEmpty) {
      return _buildErrorWidget(provider);
    }

    if (provider.popularTvShows.isEmpty && provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.popularTvShows.isEmpty) {
      return const Center(
        child: Text('No TV shows available'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount:
          provider.popularTvShows.length + (provider.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= provider.popularTvShows.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final tvShow = provider.popularTvShows[index];
        return Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          height: 280,
          child: AnimatedTvCard(
            tvShow: tvShow,
            index: index,
            onTap: (tvShow) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TvShowDetailScreen(
                    tvId: tvShow.id,
                    item: WatchlistItem(
                      id: tvShow.id,
                      title: tvShow.name,
                      posterPath: tvShow.posterPath ?? '',
                      mediaType: 'tv',
                      releaseDate: tvShow.firstAirDate,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(TvShowProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load TV shows',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => provider.refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
