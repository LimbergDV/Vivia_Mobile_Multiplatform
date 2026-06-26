import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/bottom_nav_bar.dart';
import 'package:vivia_mobile/features/lessor/domain/models/new_property_form.dart';
import 'package:vivia_mobile/features/lessor/presentation/pages/property_photos_page.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/form_section_header.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/number_selector.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/property_text_field.dart';

class PropertyDetailsPage extends StatefulWidget {
  final NewPropertyForm form;

  const PropertyDetailsPage({super.key, required this.form});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  HomeNavItem _selectedNav = HomeNavItem.add;

  int? _selectedRooms;
  int? _selectedBathrooms;
  int? _selectedParkingSpots;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _roomOptions = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11+'];
  final List<String> _bathroomOptions = ['1', '2', '3', '4', '5', '6', '7+'];
  final List<String> _parkingOptions = ['1', '2', '3', '4', '5', '6', '7+'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRooms == null) {
        _showSnack('Selecciona el número de habitaciones');
        return;
      }
      if (_selectedBathrooms == null) {
        _showSnack('Selecciona el número de baños');
        return;
      }
      if (_selectedParkingSpots == null) {
        _showSnack('Selecciona los espacios de estacionamiento');
        return;
      }

      final updatedForm = widget.form.copyWith(
        rooms: _selectedRooms,
        bathrooms: _selectedBathrooms,
        parkingSpots: _selectedParkingSpots,
        title: _titleController.text,
        description: _descriptionController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyPhotosPage(form: updatedForm),
        ),
      );
    }
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
          'Detalles De La Propiedad',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormSectionHeader(label: 'Habitaciones', iconData: Icons.bed_outlined),
              const SizedBox(height: 14),
              NumberSelector(
                selected: _selectedRooms,
                options: _roomOptions,
                onSelected: (i) => setState(() => _selectedRooms = i),
              ),
              const SizedBox(height: 28),

              FormSectionHeader(label: 'Baños', iconData: Icons.bathtub_outlined),
              const SizedBox(height: 14),
              NumberSelector(
                selected: _selectedBathrooms,
                options: _bathroomOptions,
                onSelected: (i) => setState(() => _selectedBathrooms = i),
              ),
              const SizedBox(height: 28),

              FormSectionHeader(
                label: 'Espacios De Estacionamiento',
                iconData: Icons.directions_car_outlined,
              ),
              const SizedBox(height: 14),
              NumberSelector(
                selected: _selectedParkingSpots,
                options: _parkingOptions,
                onSelected: (i) => setState(() => _selectedParkingSpots = i),
              ),
              const SizedBox(height: 28),

              FormSectionHeader(label: 'Título Breve', iconData: Icons.sell_outlined),
              const SizedBox(height: 12),
              PropertyTextField(
                controller: _titleController,
                hint: 'Añade un título breve...',
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 28),

              FormSectionHeader(
                label: 'Descripción De La Propiedad',
                iconData: Icons.sell_outlined,
              ),
              const SizedBox(height: 12),
              _DescriptionField(controller: _descriptionController),
              const SizedBox(height: 32),

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
                    'Siguiente: Fotografías De La Propiedad',
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
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const _DescriptionField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      maxLines: 5,
      minLines: 4,
      validator: (v) =>
      v == null || v.trim().isEmpty ? 'Campo requerido' : null,
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Añade una descripción...',
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.55),
          fontStyle: FontStyle.italic,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0095FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
    );
  }
}