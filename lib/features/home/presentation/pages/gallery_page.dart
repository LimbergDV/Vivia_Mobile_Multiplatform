import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/home/presentation/pages/fullscreen_image_viewer.dart';

class GalleryPage extends StatefulWidget {
  final List<String> imageUrls;

  const GalleryPage({
    super.key,
    required this.imageUrls,
  });

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  bool _isPhotosTab = true;
  String _selectedCategory = 'Todas';

  static const _categoryNames = [
    'Sala',
    'Cocina',
    'Estacionamiento',
    'Fachada',
    'Baños',
  ];

  // TODO: Replace with real categorized data from backend
  Map<String, List<String>> get _categorizedImages {
    final baseUrl =
    widget.imageUrls.isNotEmpty ? widget.imageUrls[0] : '';
    return {
      'Sala': List.generate(18, (_) => baseUrl),
      'Cocina': List.generate(12, (_) => baseUrl),
      'Estacionamiento': List.generate(6, (_) => baseUrl),
      'Fachada': List.generate(24, (_) => baseUrl),
      'Baños': List.generate(8, (_) => baseUrl),
    };
  }

  List<String> get _allImages {
    return _categorizedImages.values.expand((imgs) => imgs).toList();
  }

  void _openFullscreen(List<String> images, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenImageViewer(
          imageUrls: images,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Galería',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TabToggle(
            isPhotosSelected: _isPhotosTab,
            onPhotos: () => setState(() => _isPhotosTab = true),
            onVideos: () => setState(() => _isPhotosTab = false),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isPhotosTab
                ? _buildPhotosContent(
                colorScheme, textTheme, isLandscape)
                : _buildVideosContent(colorScheme, textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosContent(
      ColorScheme colorScheme, TextTheme textTheme, bool isLandscape) {
    final allCategories = ['Todas', ..._categoryNames];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Categorías',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Chips idénticos al CategoryChipList del Home
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: allCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final name = allCategories[i];
              final isActive = name == _selectedCategory;

              const selectedColor = Color(0xFF0095FF);
              const unselectedBorderColor = Color(0xFF0061FF);

              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedCategory = name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 42,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 22),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive
                        ? selectedColor
                        : unselectedBorderColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isActive
                          ? selectedColor
                          : unselectedBorderColor
                          .withOpacity(0.04),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    name,
                    style: textTheme.labelLarge?.copyWith(
                      color: isActive
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                      height: 1.0,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: _buildImageGrid(
            _selectedCategory == 'Todas'
                ? _allImages
                : _categorizedImages[_selectedCategory] ?? [],
            isLandscape,
            colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid(List<String> images, bool isLandscape,
      ColorScheme colorScheme) {
    final crossAxisCount = isLandscape ? 4 : 3;
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.75,
      ),
      itemCount: images.length,
      itemBuilder: (_, i) {
        return GestureDetector(
          onTap: () => _openFullscreen(images, i),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              images[i],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: colorScheme.surfaceContainerHigh,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideosContent(
      ColorScheme colorScheme, TextTheme textTheme) {
    // TODO: Replace with real video data from backend
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No hay videos disponibles',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabToggle extends StatelessWidget {
  final bool isPhotosSelected;
  final VoidCallback onPhotos;
  final VoidCallback onVideos;

  const _TabToggle({
    required this.isPhotosSelected,
    required this.onPhotos,
    required this.onVideos,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TabButton(
              label: 'Fotos',
              isSelected: isPhotosSelected,
              onTap: onPhotos,
            ),
            _TabButton(
              label: 'Videos',
              isSelected: !isPhotosSelected,
              onTap: onVideos,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}