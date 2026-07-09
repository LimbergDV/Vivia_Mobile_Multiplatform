import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_type_model.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/property_viewmodel.dart';
import 'package:vivia_mobile/features/maps/domain/models/geocode_result.dart';
import 'package:vivia_mobile/features/maps/presentation/widgets/property_location_map.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/pages/property_details_page.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/viewmodels/property_draft_viewmodel.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/exit_form_dialog.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/form_section_header.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/property_dropdown_field.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/property_text_field.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/property_type_toggle.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _postalCodeController;
  late final TextEditingController _streetController;
  late final TextEditingController _exteriorNumberController;
  late final TextEditingController _interiorNumberController;
  late final TextEditingController _priceController;
  late final TextEditingController _areaController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PropertyDraftViewModel>().init();
    });
    final form = context.read<PropertyDraftViewModel>().form;
    _postalCodeController = TextEditingController(text: form.postalCode ?? '');
    _streetController = TextEditingController(text: form.street ?? '');
    _exteriorNumberController = TextEditingController(
      text: form.exteriorNumber ?? '',
    );
    _interiorNumberController = TextEditingController(
      text: form.interiorNumber ?? '',
    );
    _priceController = TextEditingController(text: form.price ?? '');
    _areaController = TextEditingController(text: form.area ?? '');
  }

  @override
  void dispose() {
    _postalCodeController.dispose();
    _streetController.dispose();
    _exteriorNumberController.dispose();
    _interiorNumberController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _onBack() async {
    final shouldExit = await showExitFormDialog(context);
    if (shouldExit && mounted) {
      context.read<PropertyDraftViewModel>().reset();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _onNext(PropertyDraftViewModel vm) {
    if (_formKey.currentState!.validate()) {
      if (vm.form.neighborhood == null) {
        _showSnack('Selecciona una colonia');
        return;
      }
      if (vm.form.propertyType == null) {
        _showSnack('Selecciona el tipo de propiedad');
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PropertyDetailsPage()),
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

    return Consumer<PropertyDraftViewModel>(
      builder: (context, vm, _) {
        final propertyTypes = context.read<PropertyViewModel>().propertyTypes;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _onBack();
          },
          child: Scaffold(
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
                onPressed: _onBack,
              ),
              title: Text(
                'Agregar Una Propiedad',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
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
                      PropertyTypeToggle(
                        selected: vm.form.isAvailableToRent
                            ? PropertyListingType.renta
                            : PropertyListingType.venta,
                        onChanged: (t) =>
                            vm.setListingType(t == PropertyListingType.renta),
                      ),
                      const SizedBox(height: 28),

                      FormSectionHeader(
                        label: 'Código Postal',
                        iconData: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),

                      _PostalCodeField(
                        controller: _postalCodeController,
                        isLoading:
                            vm.neighborhoodsStatus ==
                            NeighborhoodsStatus.loading,
                        onChanged: vm.setPostalCode,
                      ),
                      const SizedBox(height: 10),

                      // Colonia dinámica desde el endpoint
                      _DropdownWrapper(
                        child: PropertyDropdownField<NeighborhoodModel>(
                          value: vm.form.neighborhood,
                          hint: vm.neighborhoods.isEmpty
                              ? 'Ingresa un CP válido primero'
                              : 'Selecciona la colonia',
                          items: vm.neighborhoods
                              .map(
                                (n) => DropdownMenuItem(
                                  value: n,
                                  child: Text(n.name),
                                ),
                              )
                              .toList(),
                          onChanged: (n) {
                            if (n != null) vm.setNeighborhood(n);
                          },
                          validator: (_) => vm.form.neighborhood == null
                              ? 'Selecciona una colonia'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),

                      FormSectionHeader(
                        label: 'Calle',
                        iconData: Icons.signpost_outlined,
                      ),
                      const SizedBox(height: 12),

                      PropertyTextField(
                        controller: _streetController,
                        hint: 'Nombre de la calle',
                        onChanged: vm.setStreet,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Campo requerido'
                            : null,
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: PropertyTextField(
                              controller: _exteriorNumberController,
                              hint: 'Núm. Exterior',
                              onChanged: vm.setExteriorNumber,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Requerido'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PropertyTextField(
                              controller: _interiorNumberController,
                              hint: 'Núm. Interior (opcional)',
                              onChanged: vm.setInteriorNumber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _LocationPreviewCard(
                        status: vm.previewStatus,
                        point: vm.previewPoint,
                      ),
                      const SizedBox(height: 12),

                      FormSectionHeader(
                        label: 'Tipo De Propiedad',
                        iconData: Icons.home_outlined,
                      ),
                      const SizedBox(height: 12),

                      _DropdownWrapper(
                        child: PropertyDropdownField<PropertyTypeModel>(
                          value: vm.form.propertyType,
                          hint: propertyTypes.isEmpty
                              ? 'Cargando tipos...'
                              : 'Selecciona el tipo',
                          items: propertyTypes
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.name),
                                ),
                              )
                              .toList(),
                          onChanged: (t) {
                            if (t != null) vm.setPropertyType(t);
                          },
                          validator: (_) => vm.form.propertyType == null
                              ? 'Campo requerido'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),

                      FormSectionHeader(
                        label: vm.form.isAvailableToRent
                            ? 'Precio De Renta Mensual'
                            : 'Precio Total',
                        iconData: Icons.sell_outlined,
                      ),
                      const SizedBox(height: 12),

                      PropertyTextField(
                        controller: _priceController,
                        hint: 'Escriba el precio',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: vm.setPrice,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 24),

                      FormSectionHeader(
                        label: 'Área Del Terreno',
                        iconData: Icons.crop_square_outlined,
                      ),
                      const SizedBox(height: 12),

                      PropertyTextField(
                        controller: _areaController,
                        hint: 'Escriba el área en m²',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: vm.setArea,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => _onNext(vm),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0095FF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Siguiente: Detalles De La Propiedad',
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
            ),
          ),
        );
      },
    );
  }
}

class _PostalCodeField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onChanged;

  const _PostalCodeField({
    required this.controller,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5),
      ],
      onChanged: onChanged,
      validator: (v) =>
          v == null || v.length < 5 ? 'Ingresa los 5 dígitos del CP' : null,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Código postal (5 dígitos)',
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.55),
          fontStyle: FontStyle.italic,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: isLoading
            ? Padding(
                padding: const EdgeInsets.all(14),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              )
            : null,
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

class _DropdownWrapper extends StatelessWidget {
  final Widget child;

  const _DropdownWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      child: child,
    );
  }
}

/// Vista previa de la ubicación capturada. Solo confirmación visual:
/// el pin no se envía al backend al publicar.
class _LocationPreviewCard extends StatelessWidget {
  final LocationPreviewStatus status;
  final GeocodeResult? point;

  const _LocationPreviewCard({required this.status, required this.point});

  static const _height = 160.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final child = switch (status) {
      LocationPreviewStatus.idle => const SizedBox.shrink(),
      LocationPreviewStatus.loading => Container(
          key: const ValueKey('preview-skeleton'),
          height: _height,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      LocationPreviewStatus.unavailable => Container(
          key: const ValueKey('preview-unavailable'),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.location_off_outlined,
                  color: colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No pudimos ubicar esta dirección en el mapa. '
                  'Verifica la calle y el código postal.',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      LocationPreviewStatus.ready => Column(
          key: const ValueKey('preview-ready'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _height,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PropertyLocationMap(
                  point: point!,
                  interactive: false,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              point!.isApproximate
                  ? 'Ubicación aproximada de tu propiedad'
                  : 'Ubicación de tu propiedad',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: child,
    );
  }
}
