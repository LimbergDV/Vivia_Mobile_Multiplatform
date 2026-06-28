import 'package:flutter/material.dart';

class EmptyPropertiesState extends StatelessWidget {
  final String title;

  const EmptyPropertiesState({
    super.key,
    this.title = '¡No tienes propiedades\npublicadas aún!',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/states/empty_state.png',
            width: screenWidth * 0.68,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.folder_off_outlined,
              size: screenWidth * 0.3,
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}