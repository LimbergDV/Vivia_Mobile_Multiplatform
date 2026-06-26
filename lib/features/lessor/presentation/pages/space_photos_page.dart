import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/lessor/domain/models/new_property_form.dart';
import 'package:vivia_mobile/features/lessor/presentation/helpers/media_picker_helper.dart';
import 'package:vivia_mobile/features/lessor/presentation/pages/tour_video_page.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/space_category_section.dart';

class SpacePhotosPage extends StatefulWidget {
  final NewPropertyForm form;

  const SpacePhotosPage({super.key, required this.form});

  @override
  State<SpacePhotosPage> createState() => _SpacePhotosPageState();
}

class _SpacePhotosPageState extends State<SpacePhotosPage> {
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
          imagePaths: List.of(_categories[i].imagePaths),
        );
      }
    });
  }

  Future<void> _onPickFromGallery(int index) async {
    final paths = await MediaPickerHelper.pickMultipleImages();
    if (paths.isNotEmpty && mounted) {
      setState(() {
        _categories[index] = _SpaceCategory(
          label: _categories[index].label,
          isExpanded: _categories[index].isExpanded,
          imagePaths: [..._categories[index].imagePaths, ...paths],
        );
      });
    }
  }

  Future<void> _onTakePhoto(int index) async {
    final result = await MediaPickerHelper.takePhoto();
    if (result.isSuccess && mounted) {
      setState(() {
        _categories[index] = _SpaceCategory(
          label: _categories[index].label,
          isExpanded: _categories[index].isExpanded,
          imagePaths: [..._categories[index].imagePaths, result.path!],
        );
      });
    } else if (result.isCameraDenied && mounted) {
      _showSnack('Permiso de cámara denegado. Usa la galería para subir fotos.');
    }
  }

  void _onDeleteImage(int categoryIndex, int imageIndex) {
    setState(() {
      final updated = List<String>.of(_categories[categoryIndex].imagePaths);
      updated.removeAt(imageIndex);
      _categories[categoryIndex] = _SpaceCategory(
        label: _categories[categoryIndex].label,
        isExpanded: _categories[categoryIndex].isExpanded,
        imagePaths: updated,
      );
    });
  }

  void _onNext() {
    final spacePhotos = <String, List<String>>{};
    for (final cat in _categories) {
      spacePhotos[cat.label] = cat.imagePaths;
    }

    final updatedForm = widget.form.copyWith(spacePhotos: spacePhotos);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TourVideoPage(form: updatedForm),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          'Fotografías De Los Espacios',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
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
                  onDeleteImage: (imageIndex) => _onDeleteImage(i, imageIndex),
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onNext,
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