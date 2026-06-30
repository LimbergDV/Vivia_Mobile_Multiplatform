import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/home/domain/models/property_detail.dart';
import 'package:vivia_mobile/features/home/domain/models/property_model.dart';
import 'package:vivia_mobile/features/home/domain/usecases/delete_property_usecase.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_property_by_id_usecase.dart';
import 'package:vivia_mobile/features/home/domain/usecases/toggle_like_usecase.dart';
import 'package:vivia_mobile/features/home/presentation/pages/fullscreen_image_viewer.dart';
import 'package:vivia_mobile/features/home/presentation/pages/gallery_page.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/property_detail_viewmodel.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/property_viewmodel.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/bottom_nav_bar.dart';

class PropertyDetailPage extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailPage({super.key, required this.property});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  HomeNavItem _selectedNav = HomeNavItem.home;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final PropertyDetailViewModel _vm;

  @override
  void initState() {
    super.initState();
    final propertyVm = context.read<PropertyViewModel>();
    _vm = PropertyDetailViewModel(
      getPropertyByIdUseCase: context.read<GetPropertyByIdUseCase>(),
      toggleLikeUseCase: context.read<ToggleLikeUseCase>(),
      initialLike: widget.property.isFavorite,
      onLikeChanged: propertyVm.updatePropertyLike,
    );
    _vm.load(widget.property.id);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _vm.dispose();
    super.dispose();
  }

  // Imágenes del carrusel: las del detalle si ya cargaron, si no la de la summary.
  List<String> _images(PropertyDetail? detail) {
    final urls = detail?.imageUrls ?? const [];
    if (urls.isNotEmpty) return urls;
    return [widget.property.imageUrl];
  }

  String _formatPrice(double price) =>
      '\$${price.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+$)'),
            (m) => '${m[1]},',
          )}';

  String _typeLabel(PropertyDetail? detail) {
    final type = detail?.propertyType.name ?? widget.property.type;
    if (type.toLowerCase().contains('departamento') ||
        type.toLowerCase().contains('pisos')) {
      return 'DEPARTAMENTO';
    }
    return type.toUpperCase();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar propiedad'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta propiedad? '
          'Esta acción eliminará también todas las imágenes y videos asociados '
          'y no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context.read<DeletePropertyUseCase>().execute(widget.property.id);
      if (!mounted) return;
      context.read<PropertyViewModel>().removeProperty(widget.property.id);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  void _onNavSelected(HomeNavItem item) {
    if (item == HomeNavItem.home) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _selectedNav = item);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final imageHeight = isLandscape
        ? MediaQuery.of(context).size.height * 0.55
        : screenWidth * 0.95;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      bottomNavigationBar: HomeBottomNavBar(
        selected: _selectedNav,
        onItemSelected: _onNavSelected,
      ),
      body: AnimatedBuilder(
        animation: _vm,
        builder: (context, _) {
          final detail = _vm.detail;
          final images = _images(detail);

          final isLessor = context.read<PropertyViewModel>().isLessor;

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (_, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FullscreenImageViewer(
                                    imageUrls: images,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: colorScheme.surfaceContainerHigh,
                                child: Icon(Icons.image_outlined,
                                    size: 64,
                                    color: colorScheme.onSurfaceVariant
                                        .withOpacity(0.3)),
                              ),
                            ),
                          );
                        },
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: 30,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (i) {
                              final isActive = i == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: isActive ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? colorScheme.primary
                                      : Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: _ContentBody(
                      property: widget.property,
                      detail: detail,
                      isLoading: _vm.status == PropertyDetailStatus.loading,
                      formattedPrice: _formatPrice(
                        detail?.listedPrice ?? widget.property.price,
                      ),
                      propertyTypeLabel: _typeLabel(detail),
                      galleryImages: images,
                      isLandscape: isLandscape,
                      isLessor: isLessor,
                      isFavorite: _vm.currentLike,
                      onFavoriteTap: () => _vm.toggleLike(widget.property.id),
                      onDeleteTap: _confirmDelete,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContentBody extends StatelessWidget {
  final PropertyModel property;
  final PropertyDetail? detail;
  final bool isLoading;
  final String formattedPrice;
  final String propertyTypeLabel;
  final List<String> galleryImages;
  final bool isLandscape;
  final bool isLessor;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onDeleteTap;

  const _ContentBody({
    required this.property,
    required this.detail,
    required this.isLoading,
    required this.formattedPrice,
    required this.propertyTypeLabel,
    required this.galleryImages,
    required this.isLandscape,
    required this.isLessor,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final horizontalPadding = isLandscape ? 32.0 : 20.0;

    final title = detail?.title ?? property.title;
    final bedrooms = detail?.bedrooms ?? property.bedrooms;
    final bathrooms = detail?.bathrooms ?? property.bathrooms;
    final area = detail?.areaM2 ?? property.area;
    final description = detail?.description ?? '';
    final location = detail?.address.formatted ?? property.location;
    final lessor = detail?.lessor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.arrow_back,
                    color: colorScheme.onSurface, size: 24),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onFavoriteTap,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.send_outlined,
                      color: colorScheme.onSurface, size: 24),
                  if (isLessor) ...[
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert,
                          color: colorScheme.onSurface, size: 24),
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'delete') onDeleteTap();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              propertyTypeLabel,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            formattedPrice,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 18),

          _StatsRow(bedrooms: bedrooms, bathrooms: bathrooms, area: area),
          const SizedBox(height: 24),

          // Agente — solo cuando el backend lo entrega (token de lessee)
          if (lessor != null) ...[
            const _SectionTitle(label: 'Agente'),
            const SizedBox(height: 12),
            _AgentCard(
              name: lessor.fullName,
              role: 'Dueño',
              avatarUrl: lessor.photoUrl,
            ),
            const SizedBox(height: 24),
          ],

          const _SectionTitle(label: 'Descripción'),
          const SizedBox(height: 10),
          if (isLoading && description.isEmpty)
            _SkeletonLines(colorScheme: colorScheme)
          else
            Text(
              description.isEmpty ? 'Sin descripción disponible.' : description,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          const SizedBox(height: 24),

          // Amenidades
          if (detail != null && detail!.amenities.isNotEmpty) ...[
            const _SectionTitle(label: 'Amenidades'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: detail!.amenities
                  .map((a) => _AmenityChip(label: a.name))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          const _SectionTitle(label: 'Imágenes y videos'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GalleryPage(propertyId: property.id),
                ),
              );
            },
            child: _GalleryRow(
              images: galleryImages,
              remaining: 0,
            ),
          ),
          const SizedBox(height: 24),

          const _SectionTitle(label: 'Ubicación'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location.isEmpty ? 'Ubicación no disponible' : location,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      label,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
      ),
    );
  }
}

class _SkeletonLines extends StatelessWidget {
  final ColorScheme colorScheme;

  const _SkeletonLines({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    Widget line(double widthFactor) => FractionallySizedBox(
          widthFactor: widthFactor,
          child: Container(
            height: 12,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [line(1), line(0.95), line(0.6)],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;

  const _AmenityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int bedrooms;
  final double bathrooms;
  final double area;

  const _StatsRow({
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
  });

  String get _bathroomsLabel => bathrooms == bathrooms.truncateToDouble()
      ? bathrooms.toInt().toString()
      : bathrooms.toString();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(
          svgPath: 'assets/icons/bed_icon.svg',
          value: '$bedrooms',
          label: 'habitaciones',
        ),
        const SizedBox(width: 24),
        _StatItem(
          svgPath: 'assets/icons/bath_icon.svg',
          value: _bathroomsLabel,
          label: 'baños',
        ),
        const SizedBox(width: 24),
        _StatItem(
          svgPath: 'assets/icons/area_icon.svg',
          value: '${area.toInt()}',
          label: 'm2',
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String svgPath;
  final String value;
  final String label;

  const _StatItem({
    required this.svgPath,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          svgPath,
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(
            colorScheme.primary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AgentCard extends StatelessWidget {
  final String name;
  final String role;
  final String? avatarUrl;

  const _AgentCard({
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colorScheme.surfaceContainerHigh,
          backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
              ? NetworkImage(avatarUrl!)
              : null,
          child: (avatarUrl == null || avatarUrl!.isEmpty)
              ? Icon(Icons.person,
                  color: colorScheme.onSurfaceVariant, size: 24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                role,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chat_bubble_outline,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _GalleryRow extends StatelessWidget {
  final List<String> images;
  final int remaining;

  const _GalleryRow({
    required this.images,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = images.length > 3 ? 3 : images.length;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (displayCount == 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;

        return Row(
          children: List.generate(displayCount, (i) {
            final isLast = i == displayCount - 1 && remaining > 0;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: i < displayCount - 1 ? spacing : 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 1 / 1.05,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          images[i],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: colorScheme.surfaceContainerHigh,
                          ),
                        ),
                        if (isLast)
                          Container(
                            color: Colors.black.withOpacity(0.45),
                            child: Center(
                              child: Text(
                                '$remaining+',
                                style: textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
