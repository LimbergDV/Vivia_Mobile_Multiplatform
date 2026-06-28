import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/presentation/pages/choose_option_page.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/property_image_grid.dart';

class RoleSelectorPage extends StatefulWidget {
  const RoleSelectorPage({super.key});

  static const List<String> propertyImages = [
    'assets/images/properties/house_1.webp',
    'assets/images/properties/house_2.webp',
    'assets/images/properties/house_3.webp',
    'assets/images/properties/house_4.webp',
    'assets/images/properties/house_5.webp',
    'assets/images/properties/house_6.webp',
    'assets/images/properties/house_7.webp',
    'assets/images/properties/house_8.webp',
    'assets/images/properties/house_9.webp',
  ];

  @override
  State<RoleSelectorPage> createState() => _RoleSelectorPageState();
}

class _RoleSelectorPageState extends State<RoleSelectorPage> {
  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      for (final path in RoleSelectorPage.propertyImages) {
        precacheImage(AssetImage(path), context).catchError((_) {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: orientation == Orientation.portrait
            ? _PortraitLayout(images: RoleSelectorPage.propertyImages)
            : _LandscapeLayout(images: RoleSelectorPage.propertyImages),
      ),
    );
  }
}

// ── Portrait ──────────────────────────────────────────────────────────────
class _PortraitLayout extends StatelessWidget {
  final List<String> images;
  const _PortraitLayout({required this.images});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        PropertyImageGrid(images: images, gridHeight: screenHeight * 0.52),
        const _BottomPanel(),
      ],
    );
  }
}

// ── Landscape ─────────────────────────────────────────────────────────────
class _LandscapeLayout extends StatelessWidget {
  final List<String> images;
  const _LandscapeLayout({required this.images});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: screenWidth * 0.55,
          height: screenHeight,
          child: PropertyImageGrid(images: images, gridHeight: screenHeight),
        ),
        SizedBox(
          width: screenWidth * 0.45,
          height: screenHeight,
          child: const Center(child: _BottomPanel()),
        ),
      ],
    );
  }
}

// ── Panel con logo y botones ───────────────────────────────────────────────
class _BottomPanel extends StatelessWidget {
  const _BottomPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: screenHeight * 0.02),

          SvgPicture.asset('assets/images/logo.svg', width: 52, height: 52),
          const SizedBox(height: 8),

          Text(
            'Vívia',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),

          Text(
            '¿Qué quieres hacer?',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: screenHeight * 0.025),

          // Buscar hogar → lessee
          _RoleButton(
            label: '¡Buscar un hogar!',
            backgroundColor: colorScheme.primary,
            textColor: colorScheme.onPrimary,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChooseOptionPage(role: UserRole.lessee),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.015),

          // Quiero vender → lessor
          _RoleButton(
            label: '¡Quiero vender!',
            backgroundColor: const Color(0xFF29B6F6),
            textColor: Colors.white,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChooseOptionPage(role: UserRole.lessor),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.025),
        ],
      ),
    );
  }
}

// ── Botón reutilizable ────────────────────────────────────────────────────
class _RoleButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const _RoleButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}