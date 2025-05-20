import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineverse/Providers/movies_provider.dart';
import 'package:cineverse/Services/movies_api_service.dart';
import 'package:cineverse/Widgets/movie_cards.dart';

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
      context.read<MovieProvider>().fetchPopularMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final apiService = Provider.of<MovieApiService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Movies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => movieProvider.fetchPopularMovies(),
          ),
        ],
      ),
      body: _buildBody(movieProvider, apiService),
    );
  }

  Widget _buildBody(MovieProvider movieProvider, MovieApiService apiService) {
    if (movieProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (movieProvider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${movieProvider.error}',
              style: const TextStyle(color: Colors.red),
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

    return RefreshIndicator(
      onRefresh: () => movieProvider.fetchPopularMovies(),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: movieProvider.movies.length,
        itemBuilder: (context, index) {
          final movie = movieProvider.movies[index];
          return MovieCard(movie: movie, apiService: apiService);
        },
      ),
    );
  }
}
