import 'package:cineverse/features/drawer/watchlist_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/person_provider.dart';
import '../widgets/read_more_text.dart';
import '../models/movie_credit_model.dart';
import '../../movies/screens/movie_detail_screen.dart';

class PersonDetailScreen extends StatelessWidget {
  final int personId;
  final String tag;

  const PersonDetailScreen(
      {super.key, required this.personId, required this.tag});

  int? calculateAge(String? birthday) {
    if (birthday == null) return null;
    try {
      final birthDate = DateTime.parse(birthday);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  Widget _buildMovieList(List<MovieCredit> credits) {
    return credits.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No credits available'),
            ),
          )
        : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: credits.length,
            itemBuilder: (context, index) {
              final credit = credits[index];
              final posterUrl = credit.posterPath != null
                  ? 'https://image.tmdb.org/t/p/w200${credit.posterPath}'
                  : null;

              return GestureDetector(
                onTap: () {
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
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      posterUrl != null
                          ? Image.network(
                              posterUrl,
                              height: 160,
                              errorBuilder: (_, __, ___) => Container(
                                height: 160,
                                width: 100,
                                color: Colors.grey[300],
                                child: const Icon(Icons.movie, size: 40),
                              ),
                            )
                          : Container(
                              height: 160,
                              width: 100,
                              color: Colors.grey[300],
                              child: const Icon(Icons.movie, size: 40),
                            ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 100,
                        child: Text(
                          credit.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 100,
                        child: Text(
                          credit.character ?? credit.job ?? '',
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonProvider>(
      builder: (context, provider, _) {
        // Load person data when the widget is first built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.person == null || provider.person!.id != personId) {
            provider.loadPerson(personId);
            provider.loadMovieCredits(personId);
          }
        });

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        final person = provider.person!;
        final age =
            person.birthday != null ? calculateAge(person.birthday) : null;
        final profileUrl = person.profilePath != null
            ? 'https://image.tmdb.org/t/p/w500${person.profilePath}'
            : null;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(person.name),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: tag,
                        child: profileUrl != null
                            ? Image.network(profileUrl, fit: BoxFit.cover)
                            : Container(
                                color: Colors.grey,
                                child: const Center(
                                  child: Icon(Icons.person,
                                      size: 100, color: Colors.white),
                                ),
                              ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.knownForDepartment,
                        style: const TextStyle(
                            fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 16),

                      // Biography
                      const Text("Biography",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ReadMoreText(text: person.biography),

                      const SizedBox(height: 16),

                      // Birthday + Place of Birth
                      if (person.birthday != null) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Icon(Icons.cake_outlined,
                                  color: Colors.grey[700], size: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Born: ${DateFormat.yMMMMd().format(DateTime.parse(person.birthday!))}${age != null ? ' ($age years)' : ''}",
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (person.placeOfBirth != null &&
                          person.placeOfBirth!.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Icon(Icons.place,
                                  color: Colors.grey[700], size: 20),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                "Place of Birth: ${person.placeOfBirth}",
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 16),

                      // Also Known As
                      if (person.alsoKnownAs.isNotEmpty) ...[
                        const Text("Also Known As",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: person.alsoKnownAs
                              .map((name) => Chip(label: Text(name)))
                              .toList(),
                        ),
                      ],

                      const SizedBox(height: 32),
                      const Text("Filmography",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      // Filmography Tabs
                      DefaultTabController(
                        length: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TabBar(
                              tabs: [
                                Tab(text: 'Acting'),
                                Tab(text: 'Production'),
                              ],
                              labelColor: Colors.black,
                              indicatorColor: Colors.black,
                            ),
                            SizedBox(
                              height: 250,
                              child: TabBarView(
                                children: [
                                  _buildMovieList(provider.actingCredits),
                                  _buildMovieList(provider.productionCredits),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
