import 'package:cineverse/models/watchlist_item.dart';
import 'package:cineverse/screens/movie_detail_screen.dart';
import 'package:cineverse/screens/tv_show_detail_screen.dart';
import 'package:flutter/material.dart';
import '../models/search_result.dart';

class SearchResultItem extends StatelessWidget {
  final SearchResult result;

  const SearchResultItem({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: result.posterPath != null
          ? Image.network(
              'https://image.tmdb.org/t/p/w500${result.posterPath}',
              width: 50,
              fit: BoxFit.cover,
            )
          : Container(width: 50, height: 70, color: Colors.grey),
      title: Text(result.title),
      subtitle: Text(
          '${result.mediaType.toUpperCase()} • ${result.releaseDate ?? 'N/A'}'),
      onTap: () {
        if (result.mediaType == 'movie') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(
                item: WatchlistItem(
                  id: result.id,
                  title: result.title,
                  posterPath: result.posterPath ?? '',
                  mediaType: 'movie',
                  releaseDate: result.releaseDate ?? '',
                ),
                movieId: result.id,
              ),
            ),
          );
        } else if (result.mediaType == 'tv') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TvShowDetailScreen(tvId: result.id),
            ),
          );
        }
      },
    );
  }
}
