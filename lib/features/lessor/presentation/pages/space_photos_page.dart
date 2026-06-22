import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/bottom_nav_bar.dart';
import 'package:vivia_mobile/features/lessor/presentation/pages/tour_video_page.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/space_category_section.dart';

class SpacePhotosPage extends StatefulWidget {
  const SpacePhotosPage({super.key});

  @override
  State<SpacePhotosPage> createState() => _SpacePhotosPageState();
}

class _SpacePhotosPageState extends State<SpacePhotosPage> {
  HomeNavItem _selectedNav = HomeNavItem.add;

  final List<_SpaceCategory> _categories = [
    _SpaceCategory(label: 'Fachada', isExpanded: true),
    _SpaceCategory(label: 'Baños'),
    _SpaceCategory(label: 'Jardines'),
  ];

  void _toggleCategory(int index) {
    setState(() {
      for (int i = 0; i < _categories.length; i++) {
        _categories[i] = _SpaceCategory(
          label: _categories[i].label,
          isExpanded: i == index ? !_categories[i].isExpanded : false,
          imagePaths: _categories[i].imagePaths,
        );
      }
    });
  }

  void _onPickFromGallery(int index) {
    // TODO: image_picker — ImageSource.gallery
  }

  void _onTakePhoto(int index) {
    // TODO: image_picker — ImageSource.camera
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
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Fotografías De Los Espacios',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        selected: _selectedNav,
        onItemSelected: (item) => setState(() => _selectedNav = item),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isLandscape ? 32 : 20,
          16,
          isLandscape ? 32 : 20,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agrega las fotografías en las categorías pertenecientes.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),

            ...List.generate(_categories.length, (i) {
              final cat = _categories[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SpaceCategorySection(
                  label: cat.label,
                  isExpanded: cat.isExpanded,
                  imagePaths: cat.imagePaths,
                  onTap: () => _toggleCategory(i),
                  onPickFromGallery: () => _onPickFromGallery(i),
                  onTakePhoto: () => _onTakePhoto(i),
                ),
              );
            }),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TourVideoPage(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0095FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Videos De Recorridos',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpaceCategory {
  final String label;
  final bool isExpanded;
  final List<String> imagePaths;

  _SpaceCategory({
    required this.label,
    this.isExpanded = false,
    this.imagePaths = const [],
  });
}