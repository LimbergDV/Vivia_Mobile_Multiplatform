import 'package:flutter/material.dart';
import 'property_image_cell.dart';

class PropertyImageGrid extends StatelessWidget {
  final List<String> images;
  final double gridHeight;

  const PropertyImageGrid({
    super.key,
    required this.images,
    required this.gridHeight,
  });

  @override
  Widget build(BuildContext context) {
    const gap = 6.0;
    final screenHeight = MediaQuery.of(context).size.height;

    final col1 = _safeGet(images, [0, 3, 6]);
    final col2 = _safeGet(images, [1, 4, 7]);
    final col3 = _safeGet(images, [2, 5, 8]);

    return Stack(
      children: [
        SizedBox(
          height: gridHeight,
          child: Padding(
            padding: const EdgeInsets.all(gap),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ImageColumn(
                    images: col1,
                    gap: gap,
                    topOffset: 0,
                    flexValues: const [38, 34, 28],
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: _ImageColumn(
                    images: col2,
                    gap: gap,
                    topOffset: screenHeight * 0.04,
                    flexValues: const [36, 34, 30],
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: _ImageColumn(
                    images: col3,
                    gap: gap,
                    topOffset: 0,
                    flexValues: const [36, 34, 30],
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: gridHeight * 0.28,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.surface.withOpacity(0.0),
                    Theme.of(context).colorScheme.surface.withOpacity(0.75),
                    Theme.of(context).colorScheme.surface,
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _safeGet(List<String> list, List<int> indices) =>
      indices.where((i) => i < list.length).map((i) => list[i]).toList();
}

class _ImageColumn extends StatelessWidget {
  final List<String> images;
  final double gap;
  final double topOffset;
  final List<int> flexValues;

  const _ImageColumn({
    required this.images,
    required this.gap,
    required this.topOffset,
    required this.flexValues,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topOffset),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: List.generate(images.length, (i) {
          final flex = i < flexValues.length ? flexValues[i] : 33;
          return Flexible(
            flex: flex,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: i < images.length - 1 ? gap : 0,
              ),
              child: PropertyImageCell(imagePath: images[i]),
            ),
          );
        }),
      ),
    );
  }
}