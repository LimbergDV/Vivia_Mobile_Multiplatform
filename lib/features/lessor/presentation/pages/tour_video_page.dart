import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/bottom_nav_bar.dart';
import 'package:vivia_mobile/features/lessor/domain/models/new_property_form.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/dashed_upload_zone.dart';

class TourVideoPage extends StatefulWidget {
  final NewPropertyForm form;

  const TourVideoPage({super.key, required this.form});

  @override
  State<TourVideoPage> createState() => _TourVideoPageState();
}

class _TourVideoPageState extends State<TourVideoPage> {
  HomeNavItem _selectedNav = HomeNavItem.add;
  String? _selectedVideoPath;

  void _onPickVideo() {
    // TODO: image_picker — ImageSource.gallery + video
  }

  void _onRecordVideo() {
    // TODO: image_picker — ImageSource.camera + video
  }

  void _onReview() {
    final finalForm = widget.form.copyWith(
      videoPath: _selectedVideoPath,
    );

    // TODO: Navigator.push a ReviewPropertyPage(form: finalForm)
    // o llamar al ViewModel: viewModel.submitProperty(finalForm)
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
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface, size: 20),
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
      bottomNavigationBar: HomeBottomNavBar(
        selected: _selectedNav,
        onItemSelected: (item) => setState(() => _selectedNav = item),
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
              imagePath: _selectedVideoPath,
              onTap: _onPickVideo,
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _onRecordVideo,
                icon: const Icon(Icons.camera_alt_outlined,
                    color: Colors.white, size: 20),
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
                onPressed: _onReview,
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
  }
}