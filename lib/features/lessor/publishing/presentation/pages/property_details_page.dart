import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/pages/property_photos_page.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/pages/review_property_page.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/viewmodels/property_draft_viewmodel.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/form_section_header.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/number_selector.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/property_text_field.dart';

class PropertyDetailsPage extends StatefulWidget {
  const PropertyDetailsPage({super.key});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  final List<String> _roomOptions = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11+',
  ];
  final List<String> _bathroomOptions = ['1', '2', '3', '4', '5', '6', '7+'];
  final List<String> _parkingOptions = ['1', '2', '3', '4', '5', '6', '7+'];

  final List<int> _yearOptions = List.generate(
    DateTime.now().year - 1950 + 1,
    (i) => DateTime.now().year - i,
  );

  @override
  void initState() {
    super.initState();
    final form = context.read<PropertyDraftViewModel>().form;
    _titleController = TextEditingController(text: form.title ?? '');
    _descriptionController = TextEditingController(
      text: form.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onNext(PropertyDraftViewModel vm) {
    if (_formKey.currentState!.validate()) {
      if (vm.form.rooms == null) {
        _showSnack('Selecciona el número de habitaciones');
        return;
      }
      if (vm.form.bathrooms == null) {
        _showSnack('Selecciona el número de baños');
        return;
      }
      if (vm.form.parkingSpots == null) {
        _showSnack('Selecciona los espacios de estacionamiento');
        return;
      }
      switch (vm.mode) {
        case PropertyFormMode.create:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PropertyPhotosPage()),
          );
        case PropertyFormMode.editPreview:
          // Fin del modo edición de vista previa: las páginas de fotos se
          // saltan y se regresa a la review, que lee el draft actualizado.
          Navigator.of(context).popUntil(
            ModalRoute.withName(ReviewPropertyPage.routeName),
          );
        case PropertyFormMode.editPublished:
          _confirmAndSave(vm);
      }
    }
  }

  String _nextButtonLabel(PropertyFormMode mode) => switch (mode) {
        PropertyFormMode.create => 'Siguiente: Fotografías De La Propiedad',
        PropertyFormMode.editPreview => 'Guardar Y Volver A La Vista Previa',
        PropertyFormMode.editPublished => 'Guardar Cambios',
      };

  Future<void> _confirmAndSave(PropertyDraftViewModel vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Guardar cambios'),
        content: const Text(
          'Se actualizará la información visible de tu publicación. '
          'Las fotografías y el video no se modifican desde aquí; '
          'puedes editarlos desde la galería de la publicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final saved = await vm.saveEdits();
    if (!mounted) return;

    if (saved) {
      final messenger = ScaffoldMessenger.of(context);
      // Cierra Details y AddProperty para volver al detalle de la propiedad.
      Navigator.of(context)
        ..pop()
        ..pop();
      vm.reset();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Propiedad actualizada'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      _showSnack('No se pudieron guardar los cambios. Intenta de nuevo.');
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
              'Detalles De La Propiedad',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
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
                  FormSectionHeader(
                    label: 'Habitaciones',
                    iconData: Icons.bed_outlined,
                  ),
                  const SizedBox(height: 14),
                  NumberSelector(
                    // rooms stores actual count (1-11); selector needs index (0-10)
                    selected: vm.form.rooms != null
                        ? (vm.form.rooms! - 1).clamp(0, 10)
                        : null,
                    options: _roomOptions,
                    onSelected: (i) => vm.setRooms(i < 10 ? i + 1 : 11),
                  ),
                  const SizedBox(height: 28),

                  FormSectionHeader(
                    label: 'Baños',
                    iconData: Icons.bathtub_outlined,
                  ),
                  const SizedBox(height: 14),
                  NumberSelector(
                    // bathrooms stores actual count (1-7); selector needs index (0-6)
                    selected: vm.form.bathrooms != null
                        ? (vm.form.bathrooms! - 1).clamp(0, 6)
                        : null,
                    options: _bathroomOptions,
                    onSelected: (i) => vm.setBathrooms(i < 6 ? i + 1 : 7),
                  ),
                  const SizedBox(height: 28),

                  FormSectionHeader(
                    label: 'Espacios De Estacionamiento',
                    iconData: Icons.directions_car_outlined,
                  ),
                  const SizedBox(height: 14),
                  NumberSelector(
                    // parkingSpots stores actual count (1-7); selector needs index (0-6)
                    selected: vm.form.parkingSpots != null
                        ? (vm.form.parkingSpots! - 1).clamp(0, 6)
                        : null,
                    options: _parkingOptions,
                    onSelected: (i) => vm.setParkingSpots(i < 6 ? i + 1 : 7),
                  ),
                  const SizedBox(height: 28),

                  FormSectionHeader(
                    label: 'Título Breve',
                    iconData: Icons.sell_outlined,
                  ),
                  const SizedBox(height: 12),
                  PropertyTextField(
                    controller: _titleController,
                    hint: 'Añade un título breve...',
                    onChanged: vm.setTitle,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Campo requerido'
                        : null,
                  ),
                  const SizedBox(height: 28),

                  FormSectionHeader(
                    label: 'Descripción De La Propiedad',
                    iconData: Icons.sell_outlined,
                  ),
                  const SizedBox(height: 12),
                  _DescriptionField(
                    controller: _descriptionController,
                    onChanged: vm.setDescription,
                  ),
                  const SizedBox(height: 28),

                  FormSectionHeader(
                    label: 'Año De Construcción (Opcional)',
                    iconData: Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 12),
                  _YearDropdown(
                    years: _yearOptions,
                    selected: vm.form.constructionYear,
                    onChanged: vm.setConstructionYear,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 20),

                  _CondominiumRow(
                    value: vm.form.isCondominium,
                    onChanged: vm.setIsCondominium,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 28),

                  FormSectionHeader(
                    label: 'Amenidades',
                    iconData: Icons.star_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _AmenitiesSection(vm: vm),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: vm.saveStatus == PublishStatus.loading
                          ? null
                          : () => _onNext(vm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0095FF),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0x800095FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: vm.saveStatus == PublishStatus.loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _nextButtonLabel(vm.mode),
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
      },
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _DescriptionField({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      maxLines: 5,
      minLines: 4,
      onChanged: onChanged,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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

class _YearDropdown extends StatelessWidget {
  final List<int> years;
  final int? selected;
  final ValueChanged<int?> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _YearDropdown({
    required this.years,
    required this.selected,
    required this.onChanged,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selected,
      isExpanded: true,
      isDense: true,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Selecciona el año (opcional)',
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.55),
          fontStyle: FontStyle.italic,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
      ),
      items: [
        DropdownMenuItem<int>(
          value: null,
          child: Text(
            'Sin especificar',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ),
        ...years.map(
          (y) => DropdownMenuItem<int>(value: y, child: Text(y.toString())),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _CondominiumRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _CondominiumRow({
    required this.value,
    required this.onChanged,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.apartment_outlined,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '¿Es condominio?',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Checkbox(
            value: value,
            activeColor: const Color(0xFF0095FF),
            onChanged: (v) => onChanged(v ?? false),
          ),
        ],
      ),
    );
  }
}

class _AmenitiesSection extends StatelessWidget {
  final PropertyDraftViewModel vm;

  const _AmenitiesSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (vm.amenitiesStatus == AmenitiesStatus.loading) {
      return Column(
        children: List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    if (vm.amenitiesStatus == AmenitiesStatus.error) {
      return Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: colorScheme.error),
          const SizedBox(width: 8),
          Text(
            'No se pudieron cargar las amenidades',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    if (vm.amenities.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: vm.amenities.map((amenity) {
          final isSelected = vm.form.amenityIds.contains(amenity.id);
          return CheckboxListTile(
            value: isSelected,
            onChanged: (_) => vm.toggleAmenity(amenity.id),
            title: Text(
              amenity.name,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            activeColor: const Color(0xFF0095FF),
            controlAffinity: ListTileControlAffinity.trailing,
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }).toList(),
      ),
    );
  }
}
