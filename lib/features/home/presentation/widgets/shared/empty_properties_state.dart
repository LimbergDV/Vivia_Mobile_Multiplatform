import 'package:flutter/material.dart';

class EmptyPropertiesState extends StatelessWidget {
  const EmptyPropertiesState({super.key});

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
            '¡No tienes propiedades\npublicadas aún!',
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