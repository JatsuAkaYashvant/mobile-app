import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  const CardButton({
    required this.onPressed,
    required this.color,
    required this.title,
    super.key,
  });
  final VoidCallback onPressed;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 15),
          backgroundColor: color,
        ),
        onPressed: onPressed,
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
