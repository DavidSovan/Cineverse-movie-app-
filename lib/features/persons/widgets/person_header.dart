import 'package:flutter/material.dart';
import '../models/person_model.dart';

/// PersonHeader displays the person's profile image and basic information
/// with a modern Material 3 design and smooth animations.
class PersonHeader extends StatefulWidget {
  final Person person;
  final String tag;
  final bool isCompact;

  const PersonHeader({
    super.key,
    required this.person,
    required this.tag,
    this.isCompact = false,
  });

  @override
  State<PersonHeader> createState() => _PersonHeaderState();
}

class _PersonHeaderState extends State<PersonHeader> {
  @override
  Widget build(BuildContext context) {
    final profileUrl = widget.person.profilePath != null
        ? 'https://image.tmdb.org/t/p/w500${widget.person.profilePath}'
        : null;

    if (widget.isCompact) {
      return _buildCompactLayout(context, profileUrl);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Profile image with Hero animation
        Hero(
          tag: widget.tag,
          child: profileUrl != null
              ? Image.network(
                  profileUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _buildPlaceholder(context),
                )
              : _buildPlaceholder(context),
        ),
        // Gradient overlay
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Theme.of(context).colorScheme.surface.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build compact layout for tablet/desktop
  Widget _buildCompactLayout(BuildContext context, String? profileUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile image
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Hero(
            tag: widget.tag,
            child: AspectRatio(
              aspectRatio: 0.7,
              child: profileUrl != null
                  ? Image.network(
                      profileUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Quick info cards
        _buildInfoCard(
          context,
          icon: Icons.person,
          label: 'Known For',
          value: widget.person.knownForDepartment,
        ),
        const SizedBox(height: 12),

        if (widget.person.birthday != null)
          _buildInfoCard(
            context,
            icon: Icons.cake_outlined,
            label: 'Born',
            value: widget.person.birthday!,
          ),
      ],
    );
  }

  /// Build info card widget
  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build placeholder when profile image is not available
  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.person,
          size: 80,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
