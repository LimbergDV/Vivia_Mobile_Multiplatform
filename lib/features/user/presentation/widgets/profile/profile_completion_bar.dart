import 'package:flutter/material.dart';

class ProfileCompletionBar extends StatelessWidget {
  final int completionPercent;
  final bool showDot;

  const ProfileCompletionBar({
    super.key,
    required this.completionPercent,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF0095FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$completionPercent% Completado',
            style: textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (showDot)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}