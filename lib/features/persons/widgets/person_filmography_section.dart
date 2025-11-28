import 'package:flutter/material.dart';
import '../models/movie_credit_model.dart';

/// PersonFilmographySection displays the person's acting and production credits
/// in tabbed views with smooth animations and Material 3 design.
class PersonFilmographySection extends StatefulWidget {
  final List<MovieCredit> actingCredits;
  final List<MovieCredit> productionCredits;
  final Function(MovieCredit) onMovieTap;

  const PersonFilmographySection({
    super.key,
    required this.actingCredits,
    required this.productionCredits,
    required this.onMovieTap,
  });

  @override
  State<PersonFilmographySection> createState() =>
      _PersonFilmographySectionState();
}

class _PersonFilmographySectionState extends State<PersonFilmographySection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActing = widget.actingCredits.isNotEmpty;
    final hasProduction = widget.productionCredits.isNotEmpty;

    if (!hasActing && !hasProduction) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filmography',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No filmography available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Filmography',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.theater_comedy, size: 20),
                    const SizedBox(width: 8),
                    Text('Acting (${widget.actingCredits.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.movie_creation, size: 20),
                    const SizedBox(width: 8),
                    Text('Production (${widget.productionCredits.length})'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCreditsList(
                  context,
                  widget.actingCredits,
                  isActing: true,
                ),
                _buildCreditsList(
                  context,
                  widget.productionCredits,
                  isActing: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the credits list view
  Widget _buildCreditsList(
    BuildContext context,
    List<MovieCredit> credits, {
    required bool isActing,
  }) {
    if (credits.isEmpty) {
      return Center(
        child: Text(
          'No ${isActing ? 'acting' : 'production'} credits',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemCount: credits.length,
      itemBuilder: (context, index) {
        return _buildCreditCard(context, credits[index], index);
      },
    );
  }

  /// Build individual credit card
  Widget _buildCreditCard(
    BuildContext context,
    MovieCredit credit,
    int index,
  ) {
    final posterUrl = credit.posterPath != null
        ? 'https://image.tmdb.org/t/p/w200${credit.posterPath}'
        : null;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => widget.onMovieTap(credit),
        child: Container(
          width: 140,
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Material(
            child: InkWell(
              onTap: () => widget.onMovieTap(credit),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster image
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: posterUrl != null
                          ? Image.network(
                              posterUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPosterPlaceholder(context),
                            )
                          : _buildPosterPlaceholder(context),
                    ),
                  ),
                  // Content
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Expanded(
                            child: Text(
                              credit.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Character/Job
                          Text(
                            credit.character ?? credit.job ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build poster placeholder
  Widget _buildPosterPlaceholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.movie,
        size: 40,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
