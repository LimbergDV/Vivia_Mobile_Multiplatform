import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vivia_mobile/features/home/domain/models/property_model.dart';
import 'package:vivia_mobile/features/home/presentation/pages/fullscreen_image_viewer.dart';
import 'package:vivia_mobile/features/home/presentation/pages/gallery_page.dart';
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

  // TODO: Replace with real data from backend
  List<String> get _images => [
    widget.property.imageUrl,
    widget.property.imageUrl,
    widget.property.imageUrl,
    widget.property.imageUrl,
  ];

  // TODO: Replace with real gallery images from backend
  List<String> get _galleryImages => [
    widget.property.imageUrl,
    widget.property.imageUrl,
    widget.property.imageUrl,
  ];

  String get _formattedPrice {
    return '\$${widget.property.price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]},',
    )}';
  }

  String get _propertyTypeLabel {
    final type = widget.property.type;
    if (type.toLowerCase().contains('departamento') ||
        type.toLowerCase().contains('pisos')) {
      return 'DEPARTAMENTO';
    }
    return type.toUpperCase();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _images.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FullscreenImageViewer(
                                imageUrls: _images,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          _images[index],
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
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_images.length, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
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
                  formattedPrice: _formattedPrice,
                  propertyTypeLabel: _propertyTypeLabel,
                  galleryImages: _galleryImages,
                  totalImageCount: 20,
                  isLandscape: isLandscape,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentBody extends StatelessWidget {
  final PropertyModel property;
  final String formattedPrice;
  final String propertyTypeLabel;
  final List<String> galleryImages;
  final int totalImageCount;
  final bool isLandscape;

  const _ContentBody({
    required this.property,
    required this.formattedPrice,
    required this.propertyTypeLabel,
    required this.galleryImages,
    required this.totalImageCount,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final horizontalPadding = isLandscape ? 32.0 : 20.0;

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
                  Icon(Icons.favorite_border,
                      color: colorScheme.onSurface, size: 24),
                  const SizedBox(width: 16),
                  Icon(Icons.send_outlined,
                      color: colorScheme.onSurface, size: 24),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            property.title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
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

          _StatsRow(property: property),
          const SizedBox(height: 24),

          _SectionTitle(label: 'Agente'),
          const SizedBox(height: 12),
          _AgentCard(
            name: 'André Gabriel',
            role: 'Dueño',
            avatarUrl: null,
          ),
          const SizedBox(height: 24),

          _SectionTitle(label: 'Descripción'),
          const SizedBox(height: 10),
          Text(
            'Sleek, modern 2-bedroom apartment with open living space, high-end finishes, and city views. Minutes from downtown, dining, and transit.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          _SectionTitle(label: 'Imágenes y videos'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GalleryPage(imageUrls: galleryImages),
                ),
              );
            },
            child: _GalleryRow(
              images: galleryImages,
              remaining: totalImageCount - galleryImages.length,
            ),
          ),
          const SizedBox(height: 24),

          _SectionTitle(label: 'Ubicación'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on,
                  color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  property.location,
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

class _StatsRow extends StatelessWidget {
  final PropertyModel property;

  const _StatsRow({required this.property});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(
          svgPath: 'assets/icons/bed_icon.svg',
          value: '${property.bedrooms}',
          label: 'habitaciones',
        ),
        const SizedBox(width: 24),
        _StatItem(
          svgPath: 'assets/icons/bath_icon.svg',
          value: '${property.bathrooms}',
          label: 'baños',
        ),
        const SizedBox(width: 24),
        _StatItem(
          svgPath: 'assets/icons/area_icon.svg',
          value: '${property.area.toInt()}',
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
          backgroundImage:
          avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
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

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (displayCount - 1)) /
                displayCount;
        final itemHeight = itemWidth * 1.05;

        return Row(
          children: List.generate(displayCount, (i) {
            final isLast = i == displayCount - 1 && remaining > 0;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: i < displayCount - 1 ? spacing : 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: itemHeight,
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