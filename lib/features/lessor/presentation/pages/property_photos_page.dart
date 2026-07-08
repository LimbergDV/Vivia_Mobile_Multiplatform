import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/home/domain/models/property_model.dart';
import 'package:vivia_mobile/features/lessor/presentation/helpers/media_picker_helper.dart';
import 'package:vivia_mobile/features/lessor/presentation/pages/space_photos_page.dart';
import 'package:vivia_mobile/features/lessor/presentation/viewmodels/property_draft_viewmodel.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/dashed_upload_zone.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/property_app_mockup.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/property_preview_card.dart';

class PropertyPhotosPage extends StatefulWidget {
  const PropertyPhotosPage({super.key});

  @override
  State<PropertyPhotosPage> createState() => _PropertyPhotosPageState();
}

class _PropertyPhotosPageState extends State<PropertyPhotosPage> {
  final PropertyModel _previewProperty = PropertyModel(
    id: 'preview',
    title: 'Modernica Apartment',
    type: 'Departamento',
    price: 2000000,
    location: 'Chiapas, MX',
    area: 2000,
    bedrooms: 4,
    bathrooms: 1,
    imageUrl:
        'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=400',
  );

  Future<void> _onPickFromGallery() async {
    final result = await MediaPickerHelper.pickImageFromGallery();
    if (result.isSuccess && mounted) {
      context.read<PropertyDraftViewModel>().setMainPhotoPath(result.path!);
    }
  }

  Future<void> _onTakePhoto() async {
    final result = await MediaPickerHelper.takePhoto();
    if (result.isSuccess && mounted) {
      context.read<PropertyDraftViewModel>().setMainPhotoPath(result.path!);
    } else if (result.isCameraDenied && mounted) {
      _showSnack(
        'Permiso de cámara denegado. Usa la galería para subir fotos.',
      );
    }
  }

  void _onNext() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SpacePhotosPage()),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 32.0 : 20.0;

    return Consumer<PropertyDraftViewModel>(
      builder: (context, vm, _) {
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
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agrega la fotografía principal de tu propiedad, será la primera impresión que llamará a tus clientes.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
                DashedUploadZone(
                  imagePath: vm.form.mainPhotoPath,
                  onTap: _onPickFromGallery,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _onTakePhoto,
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
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
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onPickFromGallery,
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
                Text(
                  'Vistas Previas',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 12.0;
                    const mockupWidth = 170.0;
                    final cardWidth = constraints.maxWidth - gap - mockupWidth;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          height: 260,
                          child: PropertyPreviewCard(
                            property: _previewProperty,
                          ),
                        ),
                        const SizedBox(width: gap),
                        SizedBox(
                          width: mockupWidth,
                          child: PropertyAppMockup(
                            imageUrl: _previewProperty.imageUrl,
                            title: _previewProperty.title,
                            category: _previewProperty.type,
                            price: '\$4,000,000',
                            description:
                                'Sleek, modern 2-bedroom apartment with open living space, high-end finishes, and city views.',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
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
      },
    );
  }
}
