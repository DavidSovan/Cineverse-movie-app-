import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineverse/features/movies/providers/movie_credits_provider.dart';
import 'package:cineverse/features/movies/models/movie_credits.dart';

class MovieCreditsWidget extends StatefulWidget {
  final int movieId;

  const MovieCreditsWidget({
    Key? key,
    required this.movieId,
  }) : super(key: key);

  @override
  State<MovieCreditsWidget> createState() => _MovieCreditsWidgetState();
}

class _MovieCreditsWidgetState extends State<MovieCreditsWidget> {
  @override
  void initState() {
    super.initState();

    // Fetch movie credits when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieCreditsProvider>().fetchMovieCredits(widget.movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieCreditsProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Cast',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Content
            Expanded(
              child: _buildContent(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(MovieCreditsProvider provider) {
    switch (provider.state) {
      case MovieCreditsState.initial:
        return const Center(
          child: Text('Ready to load credits'),
        );

      case MovieCreditsState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case MovieCreditsState.loaded:
        if (provider.movieCredits == null) {
          return const Center(
            child: Text('No credits available'),
          );
        }
        return _buildCastList(provider.movieCredits!.cast);

      case MovieCreditsState.error:
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
                'Error loading credits',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage ?? 'Unknown error occurred',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<MovieCreditsProvider>()
                      .fetchMovieCredits(widget.movieId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildCastList(List<Cast> cast) {
    if (cast.isEmpty) {
      return const Center(
        child: Text('No cast information available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cast.length,
      itemBuilder: (context, index) {
        final castMember = cast[index];
        return _buildCastCard(castMember);
      },
    );
  }

  Widget _buildCastCard(Cast castMember) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Profile Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: castMember.profilePath != null
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w185${castMember.profilePath}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey[600],
                          );
                        },
                      )
                    : Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.grey[600],
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Cast Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    castMember.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'as ${castMember.character}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
