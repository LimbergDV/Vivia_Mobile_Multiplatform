import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/home/domain/enums/property_category.dart';
import 'package:vivia_mobile/features/home/domain/models/property_model.dart';
import 'package:vivia_mobile/features/home/presentation/pages/property_detail_page.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/bottom_nav_bar.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/category_chip_list.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/empty_properties_state.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/home_header.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/home_search_bar.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/lessee/nearby_property_card.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/property_card.dart';
import 'package:vivia_mobile/features/lessor/presentation/pages/add_property_page.dart';

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
  PropertyCategory _selectedCategory = PropertyCategory.todas;
  HomeNavItem _selectedNav = HomeNavItem.home;
  final TextEditingController _searchController = TextEditingController();

  void _onNavSelected(HomeNavItem item) {
    if (item == HomeNavItem.add && widget.role == UserRole.lessor) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddPropertyPage()),
      );
      return;
    }
    if (item == HomeNavItem.home) {
      setState(() => _selectedNav = item);
      return;
    }
    setState(() => _selectedNav = item);
  }

  final List<PropertyModel> _properties = [
    PropertyModel(
      id: '1',
      title: 'Casa Moderna',
      type: 'Casa',
      price: 2000000,
      location: 'Chiapas, MX',
      area: 2000,
      bedrooms: 4,
      bathrooms: 1,
      imageUrl: 'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=400',
    ),
    PropertyModel(
      id: '2',
      title: 'Casa Campestre',
      type: 'Casa',
      price: 2000000,
      location: 'Chiapas, MX',
      area: 2000,
      bedrooms: 4,
      bathrooms: 1,
      imageUrl: 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=400',
    ),
    PropertyModel(
      id: '3',
      title: 'Villa Exclusiva',
      type: 'Casa',
      price: 2000000,
      location: 'New York, US',
      area: 2000,
      bedrooms: 4,
      bathrooms: 1,
      imageUrl: 'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=400',
      isFavorite: true,
    ),
    PropertyModel(
      id: '4',
      title: 'Casa Suburbana',
      type: 'Casa',
      price: 2000000,
      location: 'New York, US',
      area: 2000,
      bedrooms: 4,
      bathrooms: 1,
      imageUrl: 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=400',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return _LandscapeScaffold(
        userName: widget.userName,
        avatarUrl: widget.avatarUrl,
        role: widget.role,
        selectedCategory: _selectedCategory,
        selectedNav: _selectedNav,
        searchController: _searchController,
        properties: _properties,
        onCategorySelected: (c) => setState(() => _selectedCategory = c),
        onNavSelected: _onNavSelected,
      );
    }

    return _PortraitScaffold(
      userName: widget.userName,
      avatarUrl: widget.avatarUrl,
      role: widget.role,
      selectedCategory: _selectedCategory,
      selectedNav: _selectedNav,
      searchController: _searchController,
      properties: _properties,
      onCategorySelected: (c) => setState(() => _selectedCategory = c),
      onNavSelected: _onNavSelected,
    );
  }
}

class _PortraitScaffold extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final UserRole role;
  final PropertyCategory selectedCategory;
  final HomeNavItem selectedNav;
  final TextEditingController searchController;
  final List<PropertyModel> properties;
  final ValueChanged<PropertyCategory> onCategorySelected;
  final ValueChanged<HomeNavItem> onNavSelected;

  const _PortraitScaffold({
    required this.userName,
    required this.avatarUrl,
    required this.role,
    required this.selectedCategory,
    required this.selectedNav,
    required this.searchController,
    required this.properties,
    required this.onCategorySelected,
    required this.onNavSelected,
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
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  HomeHeader(
                    userName: userName,
                    avatarUrl: avatarUrl,
                    notificationCount: 1,
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  HomeSearchBar(controller: searchController),
                  SizedBox(height: screenHeight * 0.02),
                ]),
              ),
            ),

            if (role == UserRole.lessee && properties.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
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
                        height: screenHeight * 0.28,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: properties.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 12),
                          itemBuilder: (context, i) => NearbyPropertyCard(
                            property: properties[i],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PropertyDetailPage(
                                    property: properties[i],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverToBoxAdapter(
                child: CategoryChipList(
                  selected: selectedCategory,
                  onSelected: onCategorySelected,
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

            properties.isEmpty
                ? SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const EmptyPropertiesState(),
              ),
            )
                : SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              sliver: SliverGrid(
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) => PropertyCard(
                    property: properties[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PropertyDetailPage(
                            property: properties[index],
                          ),
                        ),
                      );
                    },
                  ),
                  childCount: properties.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandscapeScaffold extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final UserRole role;
  final PropertyCategory selectedCategory;
  final HomeNavItem selectedNav;
  final TextEditingController searchController;
  final List<PropertyModel> properties;
  final ValueChanged<PropertyCategory> onCategorySelected;
  final ValueChanged<HomeNavItem> onNavSelected;

  const _LandscapeScaffold({
    required this.userName,
    required this.avatarUrl,
    required this.role,
    required this.selectedCategory,
    required this.selectedNav,
    required this.searchController,
    required this.properties,
    required this.onCategorySelected,
    required this.onNavSelected,
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
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        HomeHeader(
                          userName: userName,
                          avatarUrl: avatarUrl,
                          notificationCount: 1,
                        ),
                        const SizedBox(height: 14),
                        HomeSearchBar(controller: searchController),
                        const SizedBox(height: 14),
                      ]),
                    ),
                  ),
                  if (role == UserRole.lessee && properties.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Cerca de ti',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Ver todos',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 180,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: properties.length,
                                separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                                itemBuilder: (context, i) =>
                                    NearbyPropertyCard(
                                      property: properties[i],
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PropertyDetailPage(
                                              property: properties[i],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: CategoryChipList(
                        selected: selectedCategory,
                        onSelected: onCategorySelected,
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
                  properties.isEmpty
                      ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: const EmptyPropertiesState(),
                  )
                      : SliverPadding(
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
                          property: properties[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyDetailPage(
                                  property: properties[index],
                                ),
                              ),
                            );
                          },
                        ),
                        childCount: properties.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalNavBar extends StatelessWidget {
  final HomeNavItem selected;
  final ValueChanged<HomeNavItem> onItemSelected;

  const _VerticalNavBar({
    required this.selected,
    required this.onItemSelected,
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