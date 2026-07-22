import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_type_model.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/property_viewmodel.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/pages/property_details_page.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/viewmodels/property_draft_viewmodel.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/exit_form_dialog.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/form_section_header.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/property_dropdown_field.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/property_text_field.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/property_type_toggle.dart';
import 'package:vivia_mobile/shared/widgets/app_alert.dart';

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
    _priceController = TextEditingController(
      text: _groupThousands(form.price ?? ''),
    );
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
    final vm = context.read<PropertyDraftViewModel>();
    switch (vm.mode) {
      case PropertyFormMode.editPreview:
        // El draft se conserva: solo regresa a la vista previa.
        Navigator.of(context).pop();
      case PropertyFormMode.editPublished:
        final discard = await _showDiscardDialog();
        if (discard && mounted) {
          vm.reset();
          Navigator.of(context).pop();
        }
      case PropertyFormMode.create:
        final shouldExit = await showExitFormDialog(context);
        if (shouldExit && mounted) {
          vm.reset();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
    }
  }

  Future<bool> _showDiscardDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Descartar cambios?'),
        content: const Text(
          'Los cambios que hiciste a la información de la propiedad '
          'no se guardarán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Seguir editando'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return result ?? false;
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
    AppAlert.show(context, message: message, type: AppAlertType.warning);
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
                vm.mode == PropertyFormMode.create
                    ? 'Agregar Una Propiedad'
                    : 'Editar Información',
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
                  autovalidateMode: AutovalidateMode.disabled,
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
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        onChanged: vm.setStreet,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Campo requerido';
                          }
                          if (v.trim().length < 4) {
                            return 'La calle debe tener al menos 4 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: PropertyTextField(
                              controller: _exteriorNumberController,
                              hint: 'Núm. Exterior',
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
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
                        inputFormatters: const [_ThousandsInputFormatter()],
                        // Se guarda sin comas: la API recibe solo dígitos.
                        onChanged: (v) => vm.setPrice(v.replaceAll(',', '')),
                        validator: (v) {
                          final digits = (v ?? '').replaceAll(',', '');
                          if (digits.isEmpty) return 'Campo requerido';
                          if ((int.tryParse(digits) ?? 0) <= 0) {
                            return 'Ingresa un precio válido';
                          }
                          return null;
                        },
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
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo requerido';
                          if ((int.tryParse(v) ?? 0) < 35) {
                            return 'El área debe ser de al menos 35 m²';
                          }
                          return null;
                        },
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

/// Agrupa los dígitos en miles con comas: 1234567 → 1,234,567.
String _groupThousands(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return '';
  return digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

/// Da formato al precio con separadores de miles mientras se escribe.
/// El valor real (sin comas) se envía a la API desde el onChanged del campo.
class _ThousandsInputFormatter extends TextInputFormatter {
  const _ThousandsInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = _groupThousands(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
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

