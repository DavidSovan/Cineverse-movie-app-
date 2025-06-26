import 'package:flutter/material.dart';

class ReadMoreText extends StatefulWidget {
  final String text;
  const ReadMoreText({super.key, required this.text});

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _isExpanded ? null : 3,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        TextButton(
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          child: Text(_isExpanded ? "Read Less" : "Read More"),
        ),
      ],
    );
  }
}
