import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/home/domain/enums/property_category.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/bottom_nav_bar.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/category_chip_list.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/empty_properties_state.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/home_header.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/home_search_bar.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String? avatarUrl;

  const HomePage({
    super.key,
    required this.userName,
    this.avatarUrl,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PropertyCategory _selectedCategory = PropertyCategory.todas;
  HomeNavItem _selectedNav = HomeNavItem.home;
  final TextEditingController _searchController = TextEditingController();
  final List<dynamic> _properties = [];

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
        selectedCategory: _selectedCategory,
        selectedNav: _selectedNav,
        searchController: _searchController,
        properties: _properties,
        onCategorySelected: (c) => setState(() => _selectedCategory = c),
        onNavSelected: (n) => setState(() => _selectedNav = n),
      );
    }

    return _PortraitScaffold(
      userName: widget.userName,
      avatarUrl: widget.avatarUrl,
      selectedCategory: _selectedCategory,
      selectedNav: _selectedNav,
      searchController: _searchController,
      properties: _properties,
      onCategorySelected: (c) => setState(() => _selectedCategory = c),
      onNavSelected: (n) => setState(() => _selectedNav = n),
    );
  }
}

class _PortraitScaffold extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final PropertyCategory selectedCategory;
  final HomeNavItem selectedNav;
  final TextEditingController searchController;
  final List<dynamic> properties;
  final ValueChanged<PropertyCategory> onCategorySelected;
  final ValueChanged<HomeNavItem> onNavSelected;

  const _PortraitScaffold({
    required this.userName,
    required this.avatarUrl,
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
                  CategoryChipList(
                    selected: selectedCategory,
                    onSelected: onCategorySelected,
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  _SectionHeader(
                    title: 'Todas las propiedades',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ]),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => const SizedBox(),
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
  final PropertyCategory selectedCategory;
  final HomeNavItem selectedNav;
  final TextEditingController searchController;
  final List<dynamic> properties;
  final ValueChanged<PropertyCategory> onCategorySelected;
  final ValueChanged<HomeNavItem> onNavSelected;

  const _LandscapeScaffold({
    required this.userName,
    required this.avatarUrl,
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
    final screenWidth = MediaQuery.of(context).size.width;

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
                        const SizedBox(height: 16),
                        HomeSearchBar(controller: searchController),
                        const SizedBox(height: 14),
                        CategoryChipList(
                          selected: selectedCategory,
                          onSelected: onCategorySelected,
                        ),
                        const SizedBox(height: 16),
                        _SectionHeader(
                          title: 'Todas las propiedades',
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const SizedBox(height: 14),
                      ]),
                    ),
                  ),
                  properties.isEmpty
                      ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                      ),
                      child: const EmptyPropertiesState(),
                    ),
                  )
                      : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => const SizedBox(),
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