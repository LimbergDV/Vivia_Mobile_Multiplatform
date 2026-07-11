import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/new_property_form.dart';
import 'package:vivia_mobile/shared/media/presentation/helpers/media_picker_helper.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/pages/category_photos_page.dart';

enum _GalleryTab { fotos, videos }

class GalleryPage extends StatefulWidget {
  final NewPropertyForm form;

  const GalleryPage({super.key, required this.form});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  _GalleryTab _currentTab = _GalleryTab.fotos;
  String _selectedCategory = 'Todas';

  late String? _mainPhotoPath;
  late Map<String, List<String>> _spacePhotos;
  late String? _videoPath;

  @override
  void initState() {
    super.initState();
    _mainPhotoPath = widget.form.mainPhotoPath;
    _spacePhotos = {};
    widget.form.spacePhotos?.forEach((key, value) {
      _spacePhotos[key] = List<String>.from(value);
    });
    _videoPath = widget.form.videoPath;
  }

  List<String> get _categoryNames => _spacePhotos.keys.toList();

  NewPropertyForm get _updatedForm => widget.form.copyWith(
    mainPhotoPath: _mainPhotoPath,
    spacePhotos: _spacePhotos,
    videoPath: _videoPath,
  );

  Future<void> _changeMainPhoto() async {
    final result = await MediaPickerHelper.pickImageFromGallery();
    if (result.isSuccess && mounted) {
      setState(() => _mainPhotoPath = result.path);
    }
  }

  Future<void> _addVideo() async {
    final result = await MediaPickerHelper.pickVideoFromGallery();
    if (result.isSuccess && mounted) {
      setState(() => _videoPath = result.path);
    }
  }

  Future<void> _openCategory(String categoryName) async {
    final photos = _spacePhotos[categoryName] ?? [];
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPhotosPage(
          categoryName: categoryName,
          photoPaths: List<String>.from(photos),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _spacePhotos[categoryName] = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 32.0 : 20.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_updatedForm);
      },
      child: Scaffold(
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
            onPressed: () => Navigator.of(context).pop(_updatedForm),
          ),
          title: Text(
            'Galería',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            16,
            horizontalPadding,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TabToggle(
                currentTab: _currentTab,
                onChanged: (tab) => setState(() => _currentTab = tab),
              ),
              const SizedBox(height: 24),
              if (_currentTab == _GalleryTab.fotos)
                _buildFotosTab(colorScheme, textTheme)
              else
                _buildVideosTab(colorScheme, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFotosTab(ColorScheme colorScheme, TextTheme textTheme) {
    final categoriesToShow = _selectedCategory == 'Todas'
        ? _categoryNames
        : _categoryNames.where((n) => n == _selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MainPhotoSection(
          imagePath: _mainPhotoPath,
          onChangePhoto: _changeMainPhoto,
        ),
        const SizedBox(height: 24),
        Text(
          'Categorías',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _CategoryChips(
          categories: _categoryNames,
          selected: _selectedCategory,
          onSelected: (cat) => setState(() => _selectedCategory = cat),
        ),
        const SizedBox(height: 20),
        ...categoriesToShow.map((name) {
          final photos = _spacePhotos[name] ?? [];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => _openCategory(name),
              child: _CategoryCard(categoryName: name, photoPaths: photos),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVideosTab(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Puedes agregar más videos',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            GestureDetector(
              onTap: _addVideo,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF04364A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_videoPath != null)
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Icon(
                    Icons.videocam_rounded,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Video de recorrido',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _videoPath!.split('/').last,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _addVideo,
                          child: Text(
                            'Cambiar',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'No hay videos agregados',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TabToggle extends StatelessWidget {
  final _GalleryTab currentTab;
  final ValueChanged<_GalleryTab> onChanged;

  const _TabToggle({required this.currentTab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TabButton(
              label: 'Fotos',
              isSelected: currentTab == _GalleryTab.fotos,
              onTap: () => onChanged(_GalleryTab.fotos),
              textTheme: textTheme,
            ),
            _TabButton(
              label: 'Videos',
              isSelected: currentTab == _GalleryTab.videos,
              onTap: () => onChanged(_GalleryTab.videos),
              textTheme: textTheme,
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
  final TextTheme textTheme;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF04364A) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF04364A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MainPhotoSection extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onChangePhoto;

  const _MainPhotoSection({
    required this.imagePath,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 100,
              height: 80,
              child: imagePath != null
                  ? Image.file(
                      File(imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colorScheme.surfaceContainerHigh,
                        child: Icon(
                          Icons.image_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHigh,
                      child: Icon(
                        Icons.image_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Foto Principal',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onChangePhoto,
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: const Color(0xFF04364A),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cambiar',
                        style: textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF04364A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final allCategories = ['Todas', ...categories];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final name = allCategories[i];
          final isActive = name == selected;

          return GestureDetector(
            onTap: () => onSelected(name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF0095FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF0095FF)
                      : const Color(0xFFCCCCCC),
                ),
              ),
              child: Text(
                name,
                style: textTheme.labelMedium?.copyWith(
                  color: isActive ? Colors.white : const Color(0xFF04364A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String categoryName;
  final List<String> photoPaths;

  const _CategoryCard({required this.categoryName, required this.photoPaths});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final remaining = photoPaths.length > 3 ? photoPaths.length - 3 : 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: photoPaths.isEmpty
                ? Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Image.file(
                          File(photoPaths[0]),
                          fit: BoxFit.cover,
                          height: 160,
                          errorBuilder: (_, __, ___) => Container(
                            color: colorScheme.surfaceContainerHigh,
                          ),
                        ),
                      ),
                      if (photoPaths.length > 1) const SizedBox(width: 2),
                      if (photoPaths.length > 1)
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.file(
                                  File(photoPaths[1]),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: colorScheme.surfaceContainerHigh,
                                  ),
                                ),
                              ),
                              if (photoPaths.length > 2) ...[
                                const SizedBox(height: 2),
                                Expanded(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(photoPaths[2]),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color:
                                              colorScheme.surfaceContainerHigh,
                                        ),
                                      ),
                                      if (remaining > 0)
                                        Container(
                                          color: Colors.black.withOpacity(0.5),
                                          child: Center(
                                            child: Text(
                                              '$remaining+',
                                              style: textTheme.titleMedium
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFF04364A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryName,
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${photoPaths.length}',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
