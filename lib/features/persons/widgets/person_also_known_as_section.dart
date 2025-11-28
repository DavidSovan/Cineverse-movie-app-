import 'package:flutter/material.dart';

/// PersonAlsoKnownAsSection displays alternative names the person is known by
/// in a clean, organized Material 3 card with animated chips.
class PersonAlsoKnownAsSection extends StatelessWidget {
  final List<String> names;

  const PersonAlsoKnownAsSection({
    super.key,
    required this.names,
  });

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) {
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
              'Also Known As',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: names
                  .map(
                    (name) => _buildNameChip(context, name),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual name chip with smooth animation
  Widget _buildNameChip(BuildContext context, String name) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: InputChip(
        label: Text(
          name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
        onPressed: () {},
      ),
    );
  }
}
