import 'package:cineverse/models/video_movies.dart';
import 'package:cineverse/providers/videos_movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieVideosWidget extends StatefulWidget {
  final int movieId;
  final String? title;
  final bool showTitle;
  final EdgeInsetsGeometry? padding;
  final int? maxVideos;
  final bool trailersOnly;

  const MovieVideosWidget({
    Key? key,
    required this.movieId,
    this.title,
    this.showTitle = true,
    this.padding = const EdgeInsets.all(16.0),
    this.maxVideos,
    this.trailersOnly = false,
  }) : super(key: key);

  @override
  State<MovieVideosWidget> createState() => _MovieVideosWidgetState();
}

class _MovieVideosWidgetState extends State<MovieVideosWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch videos when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieVideosProvider>(context, listen: false)
          .fetchMovieVideos(widget.movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) ...[
            Text(
              widget.title ?? 'Trailers & Videos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
          ],
          Consumer<MovieVideosProvider>(
            builder: (context, movieVideosProvider, child) {
              if (movieVideosProvider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (movieVideosProvider.errorMessage != null) {
                return _buildErrorWidget(movieVideosProvider.errorMessage!);
              } else if (movieVideosProvider.movieVideos == null ||
                  movieVideosProvider.movieVideos!.results.isEmpty) {
                return _buildNoVideosWidget();
              } else {
                return _buildVideosList(
                    movieVideosProvider.movieVideos!.results);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              'Error loading videos: $errorMessage',
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVideosWidget() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.video_library_outlined, color: Colors.grey.shade600),
          const SizedBox(width: 8.0),
          Text(
            'No videos available',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosList(List<Video> videos) {
    List<Video> filteredVideos;

    if (widget.trailersOnly) {
      // Filter YouTube trailers only
      filteredVideos = videos
          .where((video) => video.type == 'Trailer' && video.site == 'YouTube')
          .toList();
    } else {
      // Filter all YouTube videos
      filteredVideos =
          videos.where((video) => video.site == 'YouTube').toList();
    }

    if (filteredVideos.isEmpty) {
      return _buildNoVideosWidget();
    }

    // Apply maxVideos limit if specified
    final displayVideos = widget.maxVideos != null
        ? filteredVideos.take(widget.maxVideos!).toList()
        : filteredVideos;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayVideos.length,
      itemBuilder: (context, index) {
        final video = displayVideos[index];
        return _buildVideoCard(video);
      },
    );
  }

  Widget _buildVideoCard(Video video) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 2.0,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            Icons.play_circle_filled,
            color: Colors.red.shade600,
            size: 24.0,
          ),
        ),
        title: Text(
          video.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          video.type,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12.0,
          ),
        ),
        trailing: Icon(
          Icons.launch,
          color: Colors.grey.shade600,
          size: 20.0,
        ),
        onTap: () => _launchYouTubeVideo(video.key),
      ),
    );
  }

  Future<void> _launchYouTubeVideo(String videoKey) async {
    final youtubeUrl = 'https://www.youtube.com/watch?v=$videoKey';
    try {
      if (!await launchUrl(
        Uri.parse(youtubeUrl),
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch $youtubeUrl';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
