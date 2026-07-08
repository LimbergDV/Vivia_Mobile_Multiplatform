import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/maps/domain/models/geocode_result.dart';
import 'package:vivia_mobile/features/maps/presentation/widgets/property_location_map.dart';

/// Mapa a pantalla completa con la ubicación de una propiedad.
class MapFullscreenPage extends StatelessWidget {
  final GeocodeResult point;
  final String address;

  const MapFullscreenPage({
    super.key,
    required this.point,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ubicación')),
      body: Stack(
        children: [
          Positioned.fill(
            child: PropertyLocationMap(point: point),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Material(
              color: colorScheme.surface,
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address,
                            style: textTheme.bodyMedium
                                ?.copyWith(height: 1.4),
                          ),
                          if (point.isApproximate) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Ubicación aproximada',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
