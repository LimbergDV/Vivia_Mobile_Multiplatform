import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vivia_mobile/shared/widgets/app_alert.dart';
import 'package:vivia_mobile/shared/media/presentation/helpers/media_picker_helper.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_media.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/add_property_media_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/change_main_image_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/delete_property_media_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_property_media_usecase.dart';
import 'package:vivia_mobile/shared/media/presentation/pages/fullscreen_image_viewer.dart';
import 'package:vivia_mobile/shared/media/presentation/pages/video_player_page.dart';
import 'package:vivia_mobile/shared/media/presentation/viewmodels/gallery_viewmodel.dart';

class GalleryPage extends StatefulWidget {
  final String propertyId;

  const GalleryPage({super.key, required this.propertyId});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  bool _isPhotosTab = true;
  late final GalleryViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = GalleryViewModel(
      getPropertyMediaUseCase: context.read<GetPropertyMediaUseCase>(),
      addPropertyMediaUseCase: context.read<AddPropertyMediaUseCase>(),
      changeMainImageUseCase: context.read<ChangeMainImageUseCase>(),
      deletePropertyMediaUseCase: context.read<DeletePropertyMediaUseCase>(),
      authRepository: context.read<AuthRepository>(),
    );
    _vm.addListener(_showActionMessage);
    _vm.load(widget.propertyId);
  }

  @override
  void dispose() {
    _vm.removeListener(_showActionMessage);
    _vm.dispose();
    super.dispose();
  }

  void _showActionMessage() {
    final action = _vm.consumeActionMessage();
    if (action == null || !mounted) return;
    if (action.isError) {
      AppAlert.error(context, action.text);
    } else {
      AppAlert.success(context, action.text);
    }
  }

  void _openFullscreen(List<PropertyMedia> photos, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenImageViewer(
          imageUrls: photos.map((m) => m.url).toList(growable: false),
          initialIndex: index,
          media: _vm.canEdit ? photos : null,
          onDelete: _vm.canEdit ? _vm.deleteMedia : null,
          onSetMain: _vm.canEdit ? _vm.setAsMain : null,
        ),
      ),
    );
  }

  void _openVideo(PropertyMedia video) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(
          url: video.url,
          title: video.classification.trim().isEmpty
              ? null
              : video.classification,
          onDelete: _vm.canEdit ? () => _vm.deleteMedia(video) : null,
        ),
      ),
    );
  }

  Future<void> _addMedia() async {
    if (_isPhotosTab) {
      final paths = await MediaPickerHelper.pickMultipleImages();
      if (paths.isEmpty) return;
      await _vm.addPhotos(paths);
    } else {
      final result = await MediaPickerHelper.pickVideoFromGallery();
      if (!result.isSuccess) return;
      await _vm.addVideo(result.path!);
    }
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
          'Galería',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _vm,
        builder: (context, _) {
          final canAdd = _isPhotosTab ? _vm.canAddInCurrentCategory : _vm.canEdit;
          if (!canAdd || _vm.isLoading || _vm.hasError) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            onPressed: _vm.isSubmitting ? null : _addMedia,
            child: _vm.isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
          );
        },
      ),
      body: AnimatedBuilder(
        animation: _vm,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TabToggle(
                isPhotosSelected: _isPhotosTab,
                onPhotos: () => setState(() => _isPhotosTab = true),
                onVideos: () => setState(() => _isPhotosTab = false),
              ),
              const SizedBox(height: 20),
              Expanded(child: _buildBody(colorScheme, textTheme, isLandscape)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isLandscape,
  ) {
    if (_vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_vm.hasError) {
      return _StatusMessage(
        icon: Icons.error_outline_rounded,
        message: 'No pudimos cargar la galería',
        colorScheme: colorScheme,
        textTheme: textTheme,
      );
    }
    return _isPhotosTab
        ? _buildPhotosContent(colorScheme, textTheme, isLandscape)
        : _buildVideosContent(colorScheme, textTheme, isLandscape);
  }

  Widget _buildPhotosContent(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isLandscape,
  ) {
    final categories = _vm.categories;
    final photos = _vm.displayedPhotos;

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

        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final name = categories[i];
              return _CategoryChip(
                label: name == GalleryViewModel.mainClassification
                    ? 'Fachada'
                    : name,
                isActive: name == _vm.selectedCategory,
                onTap: () => _vm.selectCategory(name),
                textTheme: textTheme,
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: photos.isEmpty && _vm.displayedPendingPhotos.isEmpty
              ? _StatusMessage(
                  icon: Icons.photo_library_outlined,
                  message: 'No hay fotos en esta categoría',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                )
              : _buildImageGrid(photos, isLandscape, colorScheme),
        ),
      ],
    );
  }

  Widget _buildImageGrid(
    List<PropertyMedia> photos,
    bool isLandscape,
    ColorScheme colorScheme,
  ) {
    final crossAxisCount = isLandscape ? 4 : 3;
    final pending = _vm.displayedPendingPhotos;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.75,
      ),
      itemCount: photos.length + pending.length,
      itemBuilder: (_, i) {
        if (i >= photos.length) {
          return _PendingTile(media: pending[i - photos.length]);
        }
        return GestureDetector(
          onTap: () => _openFullscreen(photos, i),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              photos[i].url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: colorScheme.surfaceContainerHigh),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideosContent(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isLandscape,
  ) {
    final videos = _vm.videos;
    final pending = _vm.pendingVideos;

    if (videos.isEmpty && pending.isEmpty) {
      return _StatusMessage(
        icon: Icons.videocam_off_outlined,
        message: 'No hay videos disponibles',
        colorScheme: colorScheme,
        textTheme: textTheme,
      );
    }

    final crossAxisCount = isLandscape ? 3 : 2;
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 16 / 10,
      ),
      itemCount: videos.length + pending.length,
      itemBuilder: (_, i) {
        if (i >= videos.length) {
          return _PendingTile(media: pending[i - videos.length]);
        }
        return _VideoTile(
          video: videos[i],
          onTap: () => _openVideo(videos[i]),
          colorScheme: colorScheme,
          textTheme: textTheme,
        );
      },
    );
  }
}

/// Tile de un medio recién subido: muestra el archivo local con un overlay
/// "Subiendo..." / "En revisión" hasta que la moderación lo publique.
class _PendingTile extends StatelessWidget {
  final PendingMedia media;

  const _PendingTile({required this.media});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isUploading = media.state == PendingMediaState.uploading;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (media.isVideo)
            ColoredBox(color: colorScheme.surfaceContainerHigh)
          else
            Image.file(
              File(media.localPath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: colorScheme.surfaceContainerHigh),
            ),
          Container(
            color: Colors.black.withOpacity(0.45),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isUploading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  const Icon(
                    Icons.hourglass_top_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                const SizedBox(height: 6),
                Text(
                  isUploading ? 'Subiendo...' : 'En revisión',
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final TextTheme textTheme;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF0095FF);
    const unselectedBorderColor = Color(0xFF0061FF);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? selectedColor
              : unselectedBorderColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? selectedColor
                : unselectedBorderColor.withOpacity(0.04),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: isActive ? Colors.white : const Color(0xFF1A1A1A),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final PropertyMedia video;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _VideoTile({
    required this.video,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: colorScheme.surfaceContainerHigh),
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            if (video.classification.trim().isNotEmpty)
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    video.classification,
                    style: textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _StatusMessage({
    required this.icon,
    required this.message,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: colorScheme.onSurfaceVariant.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            message,
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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
