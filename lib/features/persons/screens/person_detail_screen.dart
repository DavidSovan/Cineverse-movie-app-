import 'package:cineverse/features/drawer/watchlist_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/person_provider.dart';
import '../widgets/person_header.dart';
import '../widgets/person_biography_section.dart';
import '../widgets/person_info_section.dart';
import '../widgets/person_also_known_as_section.dart';
import '../widgets/person_filmography_section.dart';
import '../../movies/screens/movie_detail_screen.dart';

/// PersonDetailScreen displays comprehensive information about a person (actor, director, etc.)
/// with a fully responsive, modern Material 3 design.
///
/// Features:
/// - Responsive layout for mobile, tablet, and desktop
/// - Smooth animations and transitions
/// - Theme-aware dark mode support
/// - Extracted reusable widgets for better maintainability
class PersonDetailScreen extends StatefulWidget {
  final int personId;
  final String tag;

  const PersonDetailScreen({
    super.key,
    required this.personId,
    required this.tag,
  });

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadPersonData();
  }

  /// Load person data when the screen is initialized
  void _loadPersonData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PersonProvider>();
      provider.loadPerson(widget.personId);
      provider.loadMovieCredits(widget.personId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonProvider>(
      builder: (context, provider, _) {
        // Handle loading state
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle error state
        if (provider.error != null) {
          return _buildErrorScreen(context, provider);
        }

        // Handle empty data state
        if (provider.person == null) {
          return const Scaffold(
            body: Center(child: Text('No person data available')),
          );
        }

        // Build main content
        return _buildMainContent(context, provider);
      },
    );
  }

  /// Build error state UI
  Widget _buildErrorScreen(BuildContext context, PersonProvider provider) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load person details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadPersonData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build main content with responsive layout
  Widget _buildMainContent(BuildContext context, PersonProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        final isDesktop = constraints.maxWidth >= 1024;

        if (isDesktop) {
          return _buildDesktopLayout(context, provider);
        } else if (isTablet) {
          return _buildTabletLayout(context, provider);
        } else {
          return _buildMobileLayout(context, provider);
        }
      },
    );
  }

  /// Mobile layout with collapsible header
  Widget _buildMobileLayout(BuildContext context, PersonProvider provider) {
    final person = provider.person!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with collapsible app bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(person.name),
              background: PersonHeader(
                person: person,
                tag: widget.tag,
              ),
            ),
          ),
          // Content sections
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildContentSections(context, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tablet layout with side-by-side arrangement
  Widget _buildTabletLayout(BuildContext context, PersonProvider provider) {
    final person = provider.person!;

    return Scaffold(
      appBar: AppBar(title: Text(person.name)),
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: Profile image and basic info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PersonHeader(
                  person: person,
                  tag: widget.tag,
                  isCompact: true,
                ),
              ),
            ),
            // Right side: Details and filmography
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContentSections(context, provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Desktop layout with optimized spacing
  Widget _buildDesktopLayout(BuildContext context, PersonProvider provider) {
    final person = provider.person!;

    return Scaffold(
      appBar: AppBar(title: Text(person.name)),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Profile image
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: PersonHeader(
                      person: person,
                      tag: widget.tag,
                      isCompact: true,
                    ),
                  ),
                ),
                // Right side: All details
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildContentSections(context, provider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build all content sections (reused across layouts)
  Widget _buildContentSections(
    BuildContext context,
    PersonProvider provider,
  ) {
    final person = provider.person!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Known For Department
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            person.knownForDepartment,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        const SizedBox(height: 24),

        // Biography Section
        PersonBiographySection(biography: person.biography),
        const SizedBox(height: 32),

        // Info Section (Birth, Death, Place of Birth)
        PersonInfoSection(person: person),
        const SizedBox(height: 32),

        // Also Known As Section
        if (person.alsoKnownAs.isNotEmpty) ...[
          PersonAlsoKnownAsSection(names: person.alsoKnownAs),
          const SizedBox(height: 32),
        ],

        // Filmography Section
        PersonFilmographySection(
          actingCredits: provider.actingCredits,
          productionCredits: provider.productionCredits,
          onMovieTap: (credit) => _navigateToMovie(context, credit),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Navigate to movie detail screen
  void _navigateToMovie(BuildContext context, dynamic credit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailsScreen(
          movieId: credit.id,
          item: WatchlistItem(
            id: credit.id,
            title: credit.title,
            posterPath: credit.posterPath ?? '',
            mediaType: 'movie',
            releaseDate: '',
          ),
        ),
      ),
    );
  }
}
