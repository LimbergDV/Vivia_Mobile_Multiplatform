import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_detail.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_model.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/delete_property_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_property_by_id_usecase.dart';
import 'package:vivia_mobile/features/lessee/reports/domain/usecases/get_report_reasons_usecase.dart';
import 'package:vivia_mobile/features/lessee/reports/domain/usecases/submit_report_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/toggle_like_usecase.dart';
import 'package:vivia_mobile/shared/media/presentation/pages/fullscreen_image_viewer.dart';
import 'package:vivia_mobile/shared/media/presentation/pages/gallery_page.dart';
import 'package:vivia_mobile/features/user/presentation/pages/profile_page.dart';
import 'package:vivia_mobile/features/lessee/reports/presentation/pages/report_reason_page.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/pages/add_property_page.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/viewmodels/property_draft_viewmodel.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/property_detail_viewmodel.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/property_viewmodel.dart';
import 'package:vivia_mobile/features/lessee/reports/presentation/viewmodels/report_viewmodel.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/bottom_nav_bar.dart';
import 'package:vivia_mobile/features/maps/domain/models/geocode_result.dart';
import 'package:vivia_mobile/features/maps/domain/usecases/geocode_address_usecase.dart';
import 'package:vivia_mobile/features/maps/presentation/pages/map_fullscreen_page.dart';
import 'package:vivia_mobile/features/maps/presentation/widgets/property_location_map.dart';
import 'package:vivia_mobile/features/user/presentation/viewmodels/user_viewmodel.dart';
import 'package:vivia_mobile/shared/chat/data/datasources/local/chat_local_datasource.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/domain/usecases/create_conversation_usecase.dart';
import 'package:vivia_mobile/shared/chat/presentation/pages/chat_page.dart';

class PropertyDetailPage extends StatefulWidget {
  final PropertyModel property;
  final UserRole role;

  const PropertyDetailPage({
    super.key,
    required this.property,
    required this.role,
  });

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  HomeNavItem _selectedNav = HomeNavItem.home;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isContacting = false;

  late final PropertyDetailViewModel _vm;

  @override
  void initState() {
    super.initState();
    final propertyVm = context.read<PropertyViewModel>();
    _vm = PropertyDetailViewModel(
      getPropertyByIdUseCase: context.read<GetPropertyByIdUseCase>(),
      toggleLikeUseCase: context.read<ToggleLikeUseCase>(),
      geocodeAddressUseCase: context.read<GeocodeAddressUseCase>(),
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

  Future<void> _onContact(PropertyDetail detail, PropertyLessor lessor) async {
    setState(() => _isContacting = true);
    try {
      final userVm = context.read<UserViewModel>();
      final result = await context
          .read<CreateConversationUseCase>()
          .execute(
            otherUserId: lessor.id,
            otherUserRole: 'ROLE_LESSOR',
            propertyId: detail.id,
            propertyTitle: detail.title,
            requesterName: userVm.displayName.isNotEmpty
                ? userVm.displayName
                : null,
            requesterPhotoUrl: userVm.avatarUrl,
            otherUserName: lessor.fullName,
            otherUserPhotoUrl: lessor.photoUrl,
          );
      if (!mounted) return;

      final chatLocal = context.read<ChatLocalDatasource>();
      String? autoMessage;
      if (!chatLocal.hasPropertyBeenIntroduced(result.id, detail.id)) {
        chatLocal.markPropertyIntroduced(result.id, detail.id);
        autoMessage = 'Me interesa: ${detail.title}';
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            conversation: ChatConversation(
              id: result.id,
              name: lessor.fullName,
              participantOneId: result.participantOneId,
              participantTwoId: result.participantTwoId,
              propertyId: detail.id,
              propertyTitle: detail.title,
              avatarUrl: lessor.photoUrl,
              lastMessage: '',
              lastMessageAt: result.lastMessageAt,
              unreadCount: 0,
            ),
            autoMessage: autoMessage,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Error al iniciar chat: ${e.toString().replaceFirst("Exception: ", "")}'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isContacting = false);
    }
  }

  Future<void> _onEdit() async {
    final detail = _vm.detail;
    if (detail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Espera a que cargue la información de la propiedad'),
        ),
      );
      return;
    }
    // Prellena el formulario en modo editPublished (salta las páginas de
    // fotos y guarda con PATCH /properties/{id}).
    context.read<PropertyDraftViewModel>().startPublishedEdit(detail);
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddPropertyPage()),
    );
    if (!mounted) return;
    // Al volver, refrescar el detalle y las tarjetas del listado.
    _vm.load(widget.property.id);
    context.read<PropertyViewModel>().refresh();
  }

  void _onNavSelected(HomeNavItem item) {
    if (item == HomeNavItem.home) {
      Navigator.of(context).pop();
      return;
    }
    if (item == HomeNavItem.profile) {
      final userVm = context.read<UserViewModel>();
      final isLessor = context.read<PropertyViewModel>().isLessor;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProfilePage(
            userName: userVm.displayName,
            avatarUrl: userVm.avatarUrl,
            role: isLessor ? UserRole.lessor : UserRole.lessee,
          ),
        ),
      );
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
        showAddButton: context.watch<PropertyViewModel>().isLessor,
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
                        onPageChanged: (i) =>
                            setState(() => _currentPage = i),
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
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 3),
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
                      isLoading:
                      _vm.status == PropertyDetailStatus.loading,
                      formattedPrice: _formatPrice(
                        detail?.listedPrice ?? widget.property.price,
                      ),
                      propertyTypeLabel: _typeLabel(detail),
                      galleryImages: images,
                      isLandscape: isLandscape,
                      isLessor: isLessor,
                      isFavorite: _vm.currentLike,
                      isContacting: _isContacting,
                      mapStatus: _vm.mapStatus,
                      mapPoint: _vm.mapPoint,
                      onFavoriteTap: () =>
                          _vm.toggleLike(widget.property.id),
                      onDeleteTap: _confirmDelete,
                      onEditTap: _onEdit,
                      onContactTap: (!isLessor && detail?.lessor != null)
                          ? () => _onContact(detail!, detail!.lessor!)
                          : null,
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
  final PropertyMapStatus mapStatus;
  final GeocodeResult? mapPoint;
  final bool isContacting;
  final VoidCallback onFavoriteTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onEditTap;
  final VoidCallback? onContactTap;

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
    required this.mapStatus,
    required this.mapPoint,
    required this.isContacting,
    required this.onFavoriteTap,
    required this.onDeleteTap,
    required this.onEditTap,
    this.onContactTap,
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
                        if (value == 'edit') onEditTap();
                        if (value == 'delete') onDeleteTap();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                            value: 'edit', child: Text('Editar')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Eliminar',
                              style: TextStyle(color: Colors.red)),
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

          _StatsRow(bedrooms: bedrooms, bathrooms: bathrooms, area: area),
          const SizedBox(height: 24),

          if (lessor != null) ...[
            const _SectionTitle(label: 'Agente'),
            const SizedBox(height: 12),
            _AgentCard(
              name: lessor.fullName,
              role: 'Dueño',
              avatarUrl: lessor.photoUrl,
              onContactTap: onContactTap,
              isContacting: isContacting,
            ),
            const SizedBox(height: 24),
          ],

          const _SectionTitle(label: 'Descripción'),
          const SizedBox(height: 10),
          if (isLoading && description.isEmpty)
            _SkeletonLines(colorScheme: colorScheme)
          else
            Text(
              description.isEmpty
                  ? 'Sin descripción disponible.'
                  : description,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          const SizedBox(height: 24),

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
            child: _GalleryRow(images: galleryImages, remaining: 0),
          ),
          const SizedBox(height: 24),

          const _SectionTitle(label: 'Ubicación'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on,
                  color: colorScheme.primary, size: 20),
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
          const SizedBox(height: 12),

          _LocationMapCard(
            status: mapStatus,
            point: mapPoint,
            address: location,
          ),
          const SizedBox(height: 24),

          if (!isLessor)
            OutlinedButton.icon(
              onPressed: () {
                final submitUseCase = context.read<SubmitReportUseCase>();
                final getReasonsUseCase =
                context.read<GetReportReasonsUseCase>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => ReportViewModel(
                        propertyId: property.id,
                        submitUseCase: submitUseCase,
                        getReasonsUseCase: getReasonsUseCase,
                      ),
                      child: const ReportReasonPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 20),
              label: Text(
                'Reportar publicación',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Card del mapa en la sección Ubicación: skeleton mientras se
/// geocodifica, mapa con pin si hay resultado, nada si no lo hay.
class _LocationMapCard extends StatelessWidget {
  final PropertyMapStatus status;
  final GeocodeResult? point;
  final String address;

  const _LocationMapCard({
    required this.status,
    required this.point,
    required this.address,
  });

  static const _height = 200.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final child = switch (status) {
      PropertyMapStatus.loading => Container(
          key: const ValueKey('map-skeleton'),
          height: _height,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      PropertyMapStatus.unavailable => const SizedBox.shrink(),
      PropertyMapStatus.ready => Column(
          key: const ValueKey('map-ready'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PropertyLocationMap(
                  point: point!,
                  onExpand: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MapFullscreenPage(
                          point: point!,
                          address: address,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (point!.isApproximate) ...[
              const SizedBox(height: 6),
              Text(
                'Ubicación aproximada',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: child,
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
  final VoidCallback? onContactTap;
  final bool isContacting;

  const _AgentCard({
    required this.name,
    required this.role,
    this.avatarUrl,
    this.onContactTap,
    this.isContacting = false,
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
        GestureDetector(
          onTap: isContacting ? null : onContactTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: onContactTap != null
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: isContacting
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Icon(
                    Icons.chat_bubble_outline,
                    color: onContactTap != null
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
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

    if (displayCount == 0) return const SizedBox.shrink();

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