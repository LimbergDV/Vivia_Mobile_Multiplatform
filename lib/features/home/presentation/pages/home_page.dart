import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_model.dart';
import 'package:vivia_mobile/features/home/presentation/pages/property_detail_page.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/property_viewmodel.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/bottom_nav_bar.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/category_chip_list.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/empty_properties_state.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/home_header.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/home_search_bar.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/property_filter_sheet.dart';
import 'package:vivia_mobile/shared/widgets/app_alert.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_filter.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/lessee/nearby_property_card.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/property_card.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/publish_progress_card.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/check_can_publish_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/pages/add_property_page.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/viewmodels/property_draft_viewmodel.dart';
import 'package:vivia_mobile/features/premium/domain/exceptions/premium_required_exception.dart';
import 'package:vivia_mobile/features/premium/presentation/widgets/premium_required_dialog.dart';
import 'package:vivia_mobile/features/user/presentation/viewmodels/user_viewmodel.dart';
import 'package:vivia_mobile/features/user/presentation/pages/profile_page.dart';
import 'package:vivia_mobile/shared/chat/presentation/pages/chats_page.dart';
import 'package:vivia_mobile/shared/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:vivia_mobile/shared/notifications/presentation/pages/notifications_page.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String? avatarUrl;
  final UserRole role;

  const HomePage({
    super.key,
    required this.userName,
    required this.role,
    this.avatarUrl,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeNavItem _selectedNav = HomeNavItem.home;
  int _unreadCount = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserViewModel>().init(widget.userName, widget.avatarUrl);
      context.read<PropertyViewModel>().init();
      context.read<PropertyDraftViewModel>().addListener(_onDraftStreamUpdate);
      _loadUnreadCount();
    });
  }

  Future<void> _loadUnreadCount() async {
    final count = await context.read<GetUnreadCountUseCase>().execute();
    if (mounted) setState(() => _unreadCount = count);
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
    _loadUnreadCount();
  }

  void _onDraftStreamUpdate() {
    if (!mounted) return;
    final draftVm = context.read<PropertyDraftViewModel>();
    final propertyVm = context.read<PropertyViewModel>();

    if (draftVm.publishStatus == PublishStatus.error) {
      final error = draftVm.publishError;
      draftVm.reset();
      AppAlert.error(context, error ?? 'Error al publicar. Intenta de nuevo.');
      return;
    }

    switch (draftVm.streamStatus) {
      case DraftStreamStatus.success:
        final s = draftVm.successData!;
        propertyVm.prependProperty(PropertyModel(
          id: s.id,
          title: s.title,
          type: s.propertyTypeName,
          price: s.listedPrice,
          location: '',
          area: s.areaM2,
          bedrooms: s.bedrooms,
          bathrooms: s.bathrooms,
          imageUrl: s.mainImageUrl,
        ));
        draftVm.clearStreamStatus();
        AppAlert.success(
          context,
          'Tu propiedad ya está publicada y visible.',
          title: '¡Listo!',
          duration: const Duration(seconds: 7),
        );
      case DraftStreamStatus.failed:
        final reason = draftVm.failureData!.reason;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => _DraftRejectedDialog(reason: reason),
          );
          draftVm.clearStreamStatus();
        });
      case DraftStreamStatus.validating:
      case DraftStreamStatus.idle:
        break;
    }
  }

  void _onNavSelected(HomeNavItem item) {
    if (item == HomeNavItem.add && context.read<PropertyViewModel>().isLessor) {
      _openAddProperty();
      return;
    }
    if (item == HomeNavItem.notifications) {
      _openNotifications();
      return;
    }
    if (item == HomeNavItem.messages) {
      _openChats();
      return;
    }
    if (item == HomeNavItem.profile) {
      _openProfile();
      return;
    }
    setState(() => _selectedNav = item);
  }

  /// Pre-check `GET /properties/posts` antes de abrir el formulario: si el
  /// lessor free alcanzó el límite (402), ofrece Premium en vez del formulario.
  /// Al suscribirse, retoma la acción original abriendo el formulario.
  Future<void> _openAddProperty() async {
    try {
      await context.read<CheckCanPublishUseCase>().execute();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddPropertyPage()),
      );
    } on PremiumRequiredException catch (e) {
      if (!mounted) return;
      final becamePremium =
          await PremiumRequiredDialog.show(context, message: e.message);
      if (!becamePremium || !mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddPropertyPage()),
      );
    } catch (_) {
      if (!mounted) return;
      AppAlert.error(context, 'No se pudo verificar la publicación. Intenta de nuevo.');
    }
  }

  void _openChats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatsPage()),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          userName: widget.userName,
          avatarUrl: widget.avatarUrl,
          role: widget.role,
        ),
      ),
    );
  }

  @override
  void dispose() {
    context.read<PropertyDraftViewModel>().removeListener(_onDraftStreamUpdate);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final publishing = context.select<PropertyDraftViewModel, bool>(
      (vm) => vm.streamStatus == DraftStreamStatus.validating,
    );

    final scaffold = isLandscape
        ? _LandscapeScaffold(
            role: widget.role,
            selectedNav: _selectedNav,
            searchController: _searchController,
            onNavSelected: _onNavSelected,
            notificationCount: _unreadCount,
            onNotificationTap: _openNotifications,
            onProfileTap: _openProfile,
          )
        : _PortraitScaffold(
            role: widget.role,
            selectedNav: _selectedNav,
            searchController: _searchController,
            onNavSelected: _onNavSelected,
            notificationCount: _unreadCount,
            onNotificationTap: _openNotifications,
            onProfileTap: _openProfile,
          );

    return Stack(
      children: [
        scaffold,
        if (publishing)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: const PublishProgressCard(),
          ),
      ],
    );
  }
}

Future<void> _showPropertyFilters(
  BuildContext context,
  PropertyViewModel vm,
) async {
  final result = await showModalBottomSheet<PropertyFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PropertyFilterSheet(
      initial: vm.filter,
      bounds: vm.filterBounds,
    ),
  );
  if (result != null) vm.applyFilter(result);
}

class _PortraitScaffold extends StatelessWidget {
  final UserRole role;
  final HomeNavItem selectedNav;
  final TextEditingController searchController;
  final ValueChanged<HomeNavItem> onNavSelected;
  final int notificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const _PortraitScaffold({
    required this.role,
    required this.selectedNav,
    required this.searchController,
    required this.onNavSelected,
    required this.notificationCount,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      bottomNavigationBar: HomeBottomNavBar(
        selected: selectedNav,
        onItemSelected: onNavSelected,
        showAddButton: role == UserRole.lessor,
      ),
      body: Consumer<PropertyViewModel>(
        builder: (context, vm, _) {
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: vm.refresh,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        HomeHeader(
                          notificationCount: notificationCount,
                          onNotificationTap: onNotificationTap,
                          onAvatarTap: onProfileTap,
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        HomeSearchBar(
                          controller: searchController,
                          filtersActive: vm.hasActiveFilters,
                          onChanged: vm.setSearchQuery,
                          onFilterTap: () => _showPropertyFilters(context, vm),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ]),
                    ),
                  ),

                  if (role == UserRole.lessee)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      sliver: SliverToBoxAdapter(
                        child: _NearbySection(
                          vm: vm,
                          role: role,
                          screenHeight: screenHeight,
                          textTheme: textTheme,
                          colorScheme: colorScheme,
                        ),
                      ),
                    ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: vm.typesStatus == PropertyLoadStatus.loading
                          ? _ChipSkeletonRow(colorScheme: colorScheme)
                          : CategoryChipList(
                        categories: vm.categoryTabs,
                        selected: vm.selectedCategory,
                        onSelected: vm.selectCategory,
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Todas las propiedades',
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                    ),
                  ),

                  if (vm.propertiesStatus == PropertyLoadStatus.loading)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      sliver: SliverGrid(
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.62,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, _) =>
                              _PropertySkeletonCard(colorScheme: colorScheme),
                          childCount: 4,
                        ),
                      ),
                    )
                  else if (vm.displayedProperties.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: EmptyPropertiesState(
                          title: vm.isNarrowed
                              ? '¡No hay propiedades\ncon esa búsqueda!'
                              : vm.isLessor
                                  ? '¡No tienes propiedades\npublicadas aún!'
                                  : '¡Próximamente podrás\nexplorar propiedades!',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      sliver: SliverGrid(
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.62,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) => PropertyCard(
                            property: vm.displayedProperties[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyDetailPage(
                                  property: vm.displayedProperties[index],
                                  role: role,
                                ),
                              ),
                            ),
                          ),
                          childCount: vm.displayedProperties.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LandscapeScaffold extends StatelessWidget {
  final UserRole role;
  final HomeNavItem selectedNav;
  final TextEditingController searchController;
  final ValueChanged<HomeNavItem> onNavSelected;
  final int notificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const _LandscapeScaffold({
    required this.role,
    required this.selectedNav,
    required this.searchController,
    required this.onNavSelected,
    required this.notificationCount,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 70,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  right: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
              child: _VerticalNavBar(
                selected: selectedNav,
                onItemSelected: onNavSelected,
                showAddButton: role == UserRole.lessor,
              ),
            ),
            Expanded(
              child: Consumer<PropertyViewModel>(
                builder: (context, vm, _) {
                  return RefreshIndicator(
                    onRefresh: vm.refresh,
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              HomeHeader(
                                notificationCount: notificationCount,
                                onNotificationTap: onNotificationTap,
                                onAvatarTap: onProfileTap,
                              ),
                              const SizedBox(height: 14),
                              HomeSearchBar(
                                controller: searchController,
                                filtersActive: vm.hasActiveFilters,
                                onChanged: vm.setSearchQuery,
                                onFilterTap: () =>
                                    _showPropertyFilters(context, vm),
                              ),
                              const SizedBox(height: 14),
                            ]),
                          ),
                        ),
                        if (role == UserRole.lessee)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                            sliver: SliverToBoxAdapter(
                              child: _NearbySection(
                                vm: vm,
                                role: role,
                                screenHeight: 400,
                                textTheme: textTheme,
                                colorScheme: colorScheme,
                                nearbyHeight: 180,
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          sliver: SliverToBoxAdapter(
                            child: vm.typesStatus == PropertyLoadStatus.loading
                                ? _ChipSkeletonRow(colorScheme: colorScheme)
                                : CategoryChipList(
                              categories: vm.categoryTabs,
                              selected: vm.selectedCategory,
                              onSelected: vm.selectCategory,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          sliver: SliverToBoxAdapter(
                            child: _SectionHeader(
                              title: 'Todas las propiedades',
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                          ),
                        ),
                        if (vm.propertiesStatus == PropertyLoadStatus.loading)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            sliver: SliverGrid(
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.62,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                    (context, _) => _PropertySkeletonCard(
                                    colorScheme: colorScheme),
                                childCount: 4,
                              ),
                            ),
                          )
                        else if (vm.displayedProperties.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyPropertiesState(
                              title: vm.isNarrowed
                                  ? '¡No hay propiedades\ncon esa búsqueda!'
                                  : vm.isLessor
                                      ? '¡No tienes propiedades\npublicadas aún!'
                                      : '¡Próximamente podrás\nexplorar propiedades!',
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            sliver: SliverGrid(
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.62,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                    (context, index) => PropertyCard(
                                  property: vm.displayedProperties[index],
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PropertyDetailPage(
                                        property: vm.displayedProperties[index],
                                        role: role,
                                      ),
                                    ),
                                  ),
                                ),
                                childCount: vm.displayedProperties.length,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbySection extends StatelessWidget {
  final PropertyViewModel vm;
  final UserRole role;
  final double screenHeight;
  final double? nearbyHeight;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _NearbySection({
    required this.vm,
    required this.role,
    required this.screenHeight,
    required this.textTheme,
    required this.colorScheme,
    this.nearbyHeight,
  });

  @override
  Widget build(BuildContext context) {
    final listHeight = nearbyHeight ?? screenHeight * 0.28;
    final isLoading = vm.propertiesStatus == PropertyLoadStatus.loading;
    final nearby = vm.nearbyProperties;

    if (!isLoading && nearby.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cerca de ti',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                'Ver todos',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: isLoading ? 3 : nearby.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              if (isLoading) {
                return _NearbySkeletonCard(
                  height: listHeight,
                  colorScheme: colorScheme,
                );
              }
              return NearbyPropertyCard(
                property: nearby[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PropertyDetailPage(
                      property: nearby[i],
                      role: role,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _PropertySkeletonCard extends StatelessWidget {
  final ColorScheme colorScheme;
  const _PropertySkeletonCard({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(color: colorScheme.surfaceContainerHighest),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SkeletonBox(
                      width: 70, height: 12, colorScheme: colorScheme),
                  _SkeletonBox(
                      width: 100, height: 16, colorScheme: colorScheme),
                  _SkeletonBox(
                      width: double.infinity,
                      height: 10,
                      colorScheme: colorScheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbySkeletonCard extends StatelessWidget {
  final double height;
  final ColorScheme colorScheme;
  const _NearbySkeletonCard({required this.height, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class _ChipSkeletonRow extends StatelessWidget {
  final ColorScheme colorScheme;
  const _ChipSkeletonRow({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, __) => Container(
          width: 80,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final ColorScheme colorScheme;
  const _SkeletonBox(
      {required this.width,
        required this.height,
        required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _VerticalNavBar extends StatelessWidget {
  final HomeNavItem selected;
  final ValueChanged<HomeNavItem> onItemSelected;
  final bool showAddButton;

  const _VerticalNavBar({
    required this.selected,
    required this.onItemSelected,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _VerticalNavIcon(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          isSelected: selected == HomeNavItem.home,
          onTap: () => onItemSelected(HomeNavItem.home),
        ),
        const SizedBox(height: 8),
        _VerticalNavIcon(
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications_rounded,
          isSelected: selected == HomeNavItem.notifications,
          onTap: () => onItemSelected(HomeNavItem.notifications),
        ),
        const SizedBox(height: 8),
        if (showAddButton) ...[
          GestureDetector(
            onTap: () => onItemSelected(HomeNavItem.add),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF04364A),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: colorScheme.surface, size: 24),
            ),
          ),
          const SizedBox(height: 8),
        ],
        _VerticalNavIcon(
          icon: Icons.chat_bubble_outline,
          selectedIcon: Icons.chat_bubble_rounded,
          isSelected: selected == HomeNavItem.messages,
          onTap: () => onItemSelected(HomeNavItem.messages),
        ),
        const SizedBox(height: 8),
        _VerticalNavIcon(
          icon: Icons.person_outline,
          selectedIcon: Icons.person_rounded,
          isSelected: selected == HomeNavItem.profile,
          onTap: () => onItemSelected(HomeNavItem.profile),
        ),
      ],
    );
  }
}

class _VerticalNavIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _VerticalNavIcon({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF04364A).withOpacity(0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isSelected ? selectedIcon : icon,
          size: 24,
          color: isSelected
              ? const Color(0xFF04364A)
              : colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _DraftRejectedDialog extends StatelessWidget {
  final String reason;
  const _DraftRejectedDialog({required this.reason});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(
        Icons.error_outline_rounded,
        color: colorScheme.error,
        size: 40,
      ),
      title: Text(
        'Publicación rechazada',
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Text(
        reason,
        style: textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _SectionHeader({
    required this.title,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              Text(
                'Ver Todas',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}