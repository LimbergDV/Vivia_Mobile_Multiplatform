import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vivia_mobile/features/lessor/domain/models/new_property_form.dart';
import 'package:vivia_mobile/features/lessor/presentation/pages/add_property_page.dart';

class ReviewPropertyPage extends StatefulWidget {
  final NewPropertyForm form;

  const ReviewPropertyPage({super.key, required this.form});

  @override
  State<ReviewPropertyPage> createState() => _ReviewPropertyPageState();
}

class _ReviewPropertyPageState extends State<ReviewPropertyPage> {
  late final PageController _pageController;
  int _currentPage = 0;

  List<String> get _allImages {
    final images = <String>[];
    if (widget.form.mainPhotoPath != null) {
      images.add(widget.form.mainPhotoPath!);
    }
    widget.form.spacePhotos?.forEach((_, paths) {
      images.addAll(paths);
    });
    return images;
  }

  String get _formattedPrice {
    final raw = widget.form.price ?? '0';
    final number = int.tryParse(raw) ?? 0;
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );
    return '\$$formatted';
  }

  String get _locationText {
    final parts = <String>[];
    if (widget.form.colonia != null) parts.add(widget.form.colonia!);
    if (widget.form.city != null) parts.add(widget.form.city!);
    if (widget.form.state != null) parts.add(widget.form.state!);
    return parts.isNotEmpty ? parts.join(', ') : 'Ubicación no especificada';
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onEditInfo() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AddPropertyPage()),
          (route) => route.isFirst,
    );
  }

  void _onPublish() {
    // TODO: Llamar al ViewModel para publicar la propiedad
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ImageCarousel(
                images: _allImages,
                pageController: _pageController,
                currentPage: _currentPage,
                screenWidth: screenWidth,
                onPageChanged: (i) => setState(() => _currentPage = i),
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding, 20, horizontalPadding, 0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.form.title ?? 'Sin título',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (widget.form.propertyType ?? 'Propiedad').toUpperCase(),
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formattedPrice,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StatsRow(
                      rooms: widget.form.rooms ?? 0,
                      bathrooms: widget.form.bathrooms ?? 0,
                      area: widget.form.area ?? '0',
                    ),
                    const SizedBox(height: 24),
                    Divider(color: colorScheme.outlineVariant, height: 1),
                    const SizedBox(height: 24),
                    Text(
                      'Descripción',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.form.description ?? 'Sin descripción',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _GallerySection(spacePhotos: widget.form.spacePhotos),
                    const SizedBox(height: 24),
                    _LocationSection(locationText: _locationText),
                    const SizedBox(height: 32),
                    _ActionButtons(
                      onEditInfo: _onEditInfo,
                      onPublish: _onPublish,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatelessWidget {
  final List<String> images;
  final PageController pageController;
  final int currentPage;
  final double screenWidth;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onBack;

  const _ImageCarousel({
    required this.images,
    required this.pageController,
    required this.currentPage,
    required this.screenWidth,
    required this.onPageChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final imageHeight = screenWidth * 0.85;

    return SizedBox(
      height: imageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (images.isEmpty)
            Container(
              color: colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                ),
              ),
            )
          else
            PageView.builder(
              controller: pageController,
              itemCount: images.length,
              onPageChanged: onPageChanged,
              itemBuilder: (_, i) {
                return Image.file(
                  File(images[i]),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _CircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack,
                ),
                const Spacer(),
                // TODO: Reemplazar con SVGs propios
                _CircleIconButton(
                  icon: Icons.link_rounded,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _CircleIconButton(
                  icon: Icons.favorite_border_rounded,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _CircleIconButton(
                  icon: Icons.send_outlined,
                  onTap: () {},
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Vista Previa',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navegar a editar imágenes
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Editar Imágenes',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                      (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == currentPage ? 10 : 8,
                    height: i == currentPage ? 10 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == currentPage
                          ? colorScheme.primary
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int rooms;
  final int bathrooms;
  final String area;

  const _StatsRow({
    required this.rooms,
    required this.bathrooms,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        _StatItem(
          svgPath: 'assets/icons/bed_icon.svg',
          label: '$rooms Beds',
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 24),
        _StatItem(
          svgPath: 'assets/icons/bath_icon.svg',
          label: '$bathrooms bath',
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 24),
        _StatItem(
          svgPath: 'assets/icons/area_icon.svg',
          label: '$area sqft',
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String svgPath;
  final String label;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _StatItem({
    required this.svgPath,
    required this.label,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          svgPath,
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(
            colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _GallerySection extends StatelessWidget {
  final Map<String, List<String>>? spacePhotos;

  const _GallerySection({required this.spacePhotos});

  List<String> get _allPhotos {
    final photos = <String>[];
    spacePhotos?.forEach((_, paths) => photos.addAll(paths));
    return photos;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final photos = _allPhotos;
    const maxVisible = 3;
    final remaining = photos.length > maxVisible
        ? photos.length - maxVisible
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Galería',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (photos.isEmpty)
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Sin fotografías de espacios',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length > maxVisible
                  ? maxVisible
                  : photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final isLast = i == maxVisible - 1 && remaining > 0;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(photos[i]),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_outlined,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (isLast)
                          Container(
                            color: Colors.black.withOpacity(0.55),
                            child: Center(
                              child: Text(
                                '$remaining+',
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _LocationSection extends StatelessWidget {
  final String locationText;

  const _LocationSection({required this.locationText});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                locationText,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            height: 160,
            color: colorScheme.surfaceContainerHighest,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
                Icon(
                  Icons.location_on,
                  size: 36,
                  color: colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onEditInfo;
  final VoidCallback onPublish;

  const _ActionButtons({
    required this.onEditInfo,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: onEditInfo,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade400,
              side: BorderSide(color: Colors.red.shade400, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Editar Información',
              style: textTheme.labelLarge?.copyWith(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Será enviado nuevamente al formulario, ahí podrá editar la información.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onPublish,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Publicar',
              style: textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'El proceso se ejecutará en segundo plano, además de pasar por un proceso de verificación, te notificaremos cuando esté disponible.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}