import 'dart:async';
import 'package:cineverse/Providers/search_movies_provider.dart';
import 'package:cineverse/Screens/movie_detail_screen.dart';
import 'package:cineverse/Services/movies_api_service.dart';
import 'package:cineverse/Widgets/movies_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Add debounce timer
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Remove direct listener and use debounced search instead
    _searchController.addListener(_debouncedSearch);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_debouncedSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _debouncedSearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        final provider =
            Provider.of<SearchMoviesProvider>(context, listen: false);
        provider.searchMovies(_searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Search'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for movies...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<SearchMoviesProvider>(
              builder: (context, movieProvider, child) {
                if (movieProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (movieProvider.error.isNotEmpty) {
                  return Center(
                    child: Text(
                      'Error: ${movieProvider.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (movieProvider.movies.isEmpty &&
                    _searchController.text.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No movies found',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (movieProvider.movies.isEmpty) {
                  return const Center(
                    child: Text(
                      'Search for movies...',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return MovieList(
                  movies: movieProvider.movies,
                  apiService:
                      Provider.of<MovieApiService>(context, listen: false),
                  onTap: (movie) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MovieDetailsScreen(movieId: movie.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
