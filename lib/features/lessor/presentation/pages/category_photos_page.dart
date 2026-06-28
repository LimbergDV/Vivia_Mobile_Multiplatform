import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/lessor/presentation/helpers/media_picker_helper.dart';

class CategoryPhotosPage extends StatefulWidget {
  final String categoryName;
  final List<String> photoPaths;

  const CategoryPhotosPage({
    super.key,
    required this.categoryName,
    required this.photoPaths,
  });

  @override
  State<CategoryPhotosPage> createState() => _CategoryPhotosPageState();
}

class _CategoryPhotosPageState extends State<CategoryPhotosPage> {
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    _photos = List<String>.from(widget.photoPaths);
  }

  Future<void> _addPhotos() async {
    final paths = await MediaPickerHelper.pickMultipleImages();
    if (paths.isNotEmpty && mounted) {
      setState(() => _photos.addAll(paths));
    }
  }

  Future<void> _takePhoto() async {
    final result = await MediaPickerHelper.takePhoto();
    if (result.isSuccess && mounted) {
      setState(() => _photos.add(result.path!));
    } else if (result.isCameraDenied && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Permiso de cámara denegado. Usa la galería para subir fotos.'),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _deletePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final crossAxisCount = isLandscape ? 4 : 3;
    final horizontalPadding = isLandscape ? 32.0 : 20.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_photos);
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: colorScheme.onSurface, size: 20),
            onPressed: () => Navigator.of(context).pop(_photos),
          ),
          title: Text(
            'Galería',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        body: Padding(
          padding:
          EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.categoryName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _addPhotos,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFF04364A),
                        shape: BoxShape.circle,
                      ),
                      child:
                      const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _photos.isEmpty
                    ? Center(
                  child: Text(
                    'No hay fotos en esta categoría',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
                    : GridView.builder(
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (context, i) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            File(_photos[i]),
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                            errorBuilder: (_, __, ___) => Container(
                              color: colorScheme.surfaceContainerHigh,
                              child: Icon(Icons.broken_image_outlined,
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _deletePhoto(i),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _takePhoto,
          backgroundColor: const Color(0xFF04364A),
          child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
        ),
      ),
    );
  }
}