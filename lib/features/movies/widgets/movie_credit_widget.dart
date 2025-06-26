import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineverse/features/movies/providers/movie_credits_provider.dart';
import 'package:cineverse/features/movies/models/movie_credits.dart';
import 'package:cineverse/features/persons/screens/person_detail_screen.dart';
import 'package:cineverse/features/persons/providers/person_provider.dart';

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

    return SizedBox(
      height: 200, // Fixed height for horizontal list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: cast.length,
        itemBuilder: (context, index) {
          final castMember = cast[index];
          return Container(
            width: 120, // Fixed width for each cast card
            margin: const EdgeInsets.only(right: 12),
            child: _buildCastCard(castMember),
          );
        },
      ),
    );
  }

  Widget _buildCastCard(Cast castMember) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => PersonProvider()..loadPerson(castMember.id),
              child: PersonDetailScreen(
                personId: castMember.id,
                tag: 'cast_${castMember.id}',
              ),
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image with Hero animation
            Hero(
              tag: 'cast_${castMember.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 100,
                  height: 120,
                  color: Colors.grey[300],
                  child: castMember.profilePath != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w185${castMember.profilePath}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey[600],
                            );
                          },
                        )
                      : Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Cast Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    castMember.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    castMember.character,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
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
