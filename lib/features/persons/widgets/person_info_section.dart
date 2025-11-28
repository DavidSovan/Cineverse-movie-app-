import 'package:flutter/material.dart';
import '../models/person_model.dart';

/// PersonInfoSection displays person's biographical information
/// (birth date, death date, place of birth) in an organized card layout.
class PersonInfoSection extends StatelessWidget {
  final Person person;

  const PersonInfoSection({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    // Check if there's any info to display
    final hasBirthday = person.birthday != null && person.birthday!.isNotEmpty;
    final hasDeathday = person.deathday != null && person.deathday!.isNotEmpty;
    final hasPlaceOfBirth =
        person.placeOfBirth != null && person.placeOfBirth!.isNotEmpty;

    if (!hasBirthday && !hasDeathday && !hasPlaceOfBirth) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (hasBirthday) ...[
              _buildInfoRow(
                context,
                icon: Icons.cake_outlined,
                label: 'Date of Birth',
                value: _formatDate(person.birthday!),
              ),
              const SizedBox(height: 12),
            ],
            if (hasDeathday) ...[
              _buildInfoRow(
                context,
                icon: Icons.event_busy_outlined,
                label: 'Date of Death',
                value: _formatDate(person.deathday!),
              ),
              const SizedBox(height: 12),
            ],
            if (hasPlaceOfBirth) ...[
              _buildInfoRow(
                context,
                icon: Icons.place,
                label: 'Place of Birth',
                value: person.placeOfBirth!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build individual info row with icon and text
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Format date string to readable format
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
