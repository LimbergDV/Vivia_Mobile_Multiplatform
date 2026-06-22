import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/home/domain/models/property_model.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/bottom_nav_bar.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/property_card.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/dashed_upload_zone.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/property_app_mockup.dart';

class PropertyPhotosPage extends StatefulWidget {
  const PropertyPhotosPage({super.key});

  @override
  State<PropertyPhotosPage> createState() => _PropertyPhotosPageState();
}

class _PropertyPhotosPageState extends State<PropertyPhotosPage> {
  HomeNavItem _selectedNav = HomeNavItem.add;
  String? _selectedImagePath;

  // TODO: reemplazar con imagen real seleccionada por el usuario
  final PropertyModel _previewProperty = PropertyModel(
    id: 'preview',
    title: 'Modernica Apartment',
    type: 'Departamento',
    price: 2000000,
    location: 'Chiapas, MX',
    area: 2000,
    bedrooms: 4,
    bathrooms: 1,
    imageUrl: '',
  );

  void _onPickFromGallery() {
    // TODO: implementar image_picker para galería
  }

  void _onTakePhoto() {
    // TODO: implementar image_picker con cámara
  }

  void _onChangePhoto() {
    // TODO: implementar cambio de imagen
    _onPickFromGallery();
  }

  void _onNext() {
    // TODO: navegar a fotografías de espacios
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
          'Fotografías De La Propiedad',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        selected: _selectedNav,
        onItemSelected: (item) => setState(() => _selectedNav = item),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isLandscape ? 32 : 20,
          16,
          isLandscape ? 32 : 20,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Descripción ────────────────────────────────────
            Text(
              'Agrega la fotografía principal de tu propiedad, será la primera impresión que llamará a tus clientes.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),

            // ── Zona de upload ──────────────────────────────────
            DashedUploadZone(
              imagePath: _selectedImagePath,
              onTap: _onPickFromGallery,
            ),
            const SizedBox(height: 14),

            // ── Botón Tomar Foto ───────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _onTakePhoto,
                icon: const Icon(Icons.camera_alt_outlined,
                    color: Colors.white, size: 20),
                label: Text(
                  'Tomar Foto',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF04364A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Botón Cambiar ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onChangePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF04364A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Cambiar',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Vistas Previas ─────────────────────────────────
            Text(
              'Vistas Previas',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card del lessor (vista de lista)
                Expanded(
                  child: PropertyCard(property: _previewProperty),
                ),
                const SizedBox(width: 14),

                // Mockup de cómo se ve en el detalle
                PropertyAppMockup(
                  imageUrl: _selectedImagePath,
                  title: 'Modernica Apartment',
                  category: 'Departamento',
                  price: '\$4,000,000',
                  description:
                  'Sleek, modern 2-bedroom apartment with open living space, high-end finishes, and city views. Minutes from downtown, dining, and transit.',
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Botón Fotografías De Los Espacios ─────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0095FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Fotografías De Los Espacios',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}