import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/shared/media/presentation/helpers/media_picker_helper.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/pages/review_property_page.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/viewmodels/property_draft_viewmodel.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/dashed_upload_zone.dart';

class TourVideoPage extends StatelessWidget {
  const TourVideoPage({super.key});

  Future<void> _onPickVideo(BuildContext context) async {
    final result = await MediaPickerHelper.pickVideoFromGallery();
    if (result.isSuccess && context.mounted) {
      context.read<PropertyDraftViewModel>().setVideoPath(result.path);
    }
  }

  Future<void> _onRecordVideo(BuildContext context) async {
    final result = await MediaPickerHelper.recordVideo();
    if (result.isSuccess && context.mounted) {
      context.read<PropertyDraftViewModel>().setVideoPath(result.path);
    } else if (result.isCameraDenied && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permiso de cámara denegado. Usa la galería.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _onReview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Ruta nombrada: el modo editPreview regresa aquí con popUntil.
        settings: const RouteSettings(name: ReviewPropertyPage.routeName),
        builder: (_) => const ReviewPropertyPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

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
              'Videos De Recorridos',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(
              isLandscape ? 32 : 20,
              16,
              isLandscape ? 32 : 20,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agrega un vídeo de recorridos de la propiedad.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                DashedUploadZone(
                  imagePath: vm.form.videoPath,
                  isVideo: true,
                  onTap: () => _onPickVideo(context),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _onRecordVideo(context),
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      'Grabar Video',
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
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'El video no puede ser mayor a 3 minutos.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _onReview(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0095FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Revisar Publicación',
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
