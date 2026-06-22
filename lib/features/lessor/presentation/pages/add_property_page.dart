import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/shared/bottom_nav_bar.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/form_section_header.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/property_dropdown_field.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/property_text_field.dart';
import 'package:vivia_mobile/features/lessor/presentation/widgets/property_type_toggle.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  PropertyListingType _listingType = PropertyListingType.venta;
  HomeNavItem _selectedNav = HomeNavItem.add;

  final _postalCodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();

  String? _selectedCity;
  String? _selectedState;
  String? _selectedColonia;
  String? _selectedPropertyType;

  final List<String> _cities = ['Tuxtla Gutiérrez', 'San Cristóbal', 'Tapachula', 'Comitán'];
  final List<String> _states = ['Chiapas', 'CDMX', 'Jalisco', 'Nuevo León'];
  final List<String> _colonias = ['Centro', 'Las Flores', 'El Bosque', 'Vista Hermosa'];
  final List<String> _propertyTypes = [
    'Pisos y departamentos',
    'Casa',
    'Terreno',
    'Local comercial',
    'Oficina',
  ];

  @override
  void dispose() {
    _postalCodeController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  String get _priceLabel => _listingType == PropertyListingType.venta
      ? 'Precio Total'
      : 'Precio De Renta Mensual';

  String get _priceHint => 'Escriba el precio';

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      // TODO: navegar a detalles de la propiedad
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: HomeBottomNavBar(
        selected: _selectedNav,
        onItemSelected: (item) => setState(() => _selectedNav = item),
      ),
      body: SafeArea(
        child: isLandscape
            ? _LandscapeLayout(
          formKey: _formKey,
          listingType: _listingType,
          onListingTypeChanged: (t) =>
              setState(() => _listingType = t),
          postalCodeController: _postalCodeController,
          priceController: _priceController,
          areaController: _areaController,
          selectedCity: _selectedCity,
          selectedState: _selectedState,
          selectedColonia: _selectedColonia,
          selectedPropertyType: _selectedPropertyType,
          cities: _cities,
          states: _states,
          colonias: _colonias,
          propertyTypes: _propertyTypes,
          priceLabel: _priceLabel,
          priceHint: _priceHint,
          onCityChanged: (v) => setState(() => _selectedCity = v),
          onStateChanged: (v) => setState(() => _selectedState = v),
          onColoniaChanged: (v) =>
              setState(() => _selectedColonia = v),
          onPropertyTypeChanged: (v) =>
              setState(() => _selectedPropertyType = v),
          onNext: _onNext,
        )
            : _PortraitLayout(
          formKey: _formKey,
          listingType: _listingType,
          onListingTypeChanged: (t) =>
              setState(() => _listingType = t),
          postalCodeController: _postalCodeController,
          priceController: _priceController,
          areaController: _areaController,
          selectedCity: _selectedCity,
          selectedState: _selectedState,
          selectedColonia: _selectedColonia,
          selectedPropertyType: _selectedPropertyType,
          cities: _cities,
          states: _states,
          colonias: _colonias,
          propertyTypes: _propertyTypes,
          priceLabel: _priceLabel,
          priceHint: _priceHint,
          onCityChanged: (v) => setState(() => _selectedCity = v),
          onStateChanged: (v) => setState(() => _selectedState = v),
          onColoniaChanged: (v) =>
              setState(() => _selectedColonia = v),
          onPropertyTypeChanged: (v) =>
              setState(() => _selectedPropertyType = v),
          onNext: _onNext,
        ),
      ),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final PropertyListingType listingType;
  final ValueChanged<PropertyListingType> onListingTypeChanged;
  final TextEditingController postalCodeController;
  final TextEditingController priceController;
  final TextEditingController areaController;
  final String? selectedCity;
  final String? selectedState;
  final String? selectedColonia;
  final String? selectedPropertyType;
  final List<String> cities;
  final List<String> states;
  final List<String> colonias;
  final List<String> propertyTypes;
  final String priceLabel;
  final String priceHint;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String?> onColoniaChanged;
  final ValueChanged<String?> onPropertyTypeChanged;
  final VoidCallback onNext;

  const _PortraitLayout({
    required this.formKey,
    required this.listingType,
    required this.onListingTypeChanged,
    required this.postalCodeController,
    required this.priceController,
    required this.areaController,
    required this.selectedCity,
    required this.selectedState,
    required this.selectedColonia,
    required this.selectedPropertyType,
    required this.cities,
    required this.states,
    required this.colonias,
    required this.propertyTypes,
    required this.priceLabel,
    required this.priceHint,
    required this.onCityChanged,
    required this.onStateChanged,
    required this.onColoniaChanged,
    required this.onPropertyTypeChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agregar Una Propiedad',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),

            PropertyTypeToggle(
              selected: listingType,
              onChanged: onListingTypeChanged,
            ),
            const SizedBox(height: 28),

            FormSectionHeader(
              label: 'Ubicación',
              iconData: Icons.location_on_outlined,
            ),
            const SizedBox(height: 12),

            PropertyTextField(
              controller: postalCodeController,
              hint: 'Escriba el código postal',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) =>
              v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: PropertyDropdownField<String>(
                    value: selectedCity,
                    hint: 'Ciudad',
                    items: cities
                        .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ))
                        .toList(),
                    onChanged: onCityChanged,
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PropertyDropdownField<String>(
                    value: selectedState,
                    hint: 'Estado',
                    items: states
                        .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    ))
                        .toList(),
                    onChanged: onStateChanged,
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            FormSectionHeader(
              label: 'Nombre De La Colonia',
              iconData: Icons.home_outlined,
            ),
            const SizedBox(height: 12),

            PropertyDropdownField<String>(
              value: selectedColonia,
              hint: 'Elija la colonia',
              items: colonias
                  .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c),
              ))
                  .toList(),
              onChanged: onColoniaChanged,
              validator: (v) => v == null ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 24),

            FormSectionHeader(
              label: 'Tipo De Propiedad',
              iconData: Icons.home_outlined,
            ),
            const SizedBox(height: 12),

            PropertyDropdownField<String>(
              value: selectedPropertyType,
              hint: 'Pisos y departamentos',
              items: propertyTypes
                  .map((t) => DropdownMenuItem(
                value: t,
                child: Text(t),
              ))
                  .toList(),
              onChanged: onPropertyTypeChanged,
              validator: (v) => v == null ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 24),

            FormSectionHeader(
              label: priceLabel,
              iconData: Icons.sell_outlined,
            ),
            const SizedBox(height: 12),

            PropertyTextField(
              controller: priceController,
              hint: priceHint,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) =>
              v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 24),

            FormSectionHeader(
              label: 'Area Del Terreno',
              iconData: Icons.crop_square_outlined,
            ),
            const SizedBox(height: 12),

            PropertyTextField(
              controller: areaController,
              hint: 'Escriba el área en m2',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) =>
              v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onNext,
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
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final PropertyListingType listingType;
  final ValueChanged<PropertyListingType> onListingTypeChanged;
  final TextEditingController postalCodeController;
  final TextEditingController priceController;
  final TextEditingController areaController;
  final String? selectedCity;
  final String? selectedState;
  final String? selectedColonia;
  final String? selectedPropertyType;
  final List<String> cities;
  final List<String> states;
  final List<String> colonias;
  final List<String> propertyTypes;
  final String priceLabel;
  final String priceHint;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String?> onColoniaChanged;
  final ValueChanged<String?> onPropertyTypeChanged;
  final VoidCallback onNext;

  const _LandscapeLayout({
    required this.formKey,
    required this.listingType,
    required this.onListingTypeChanged,
    required this.postalCodeController,
    required this.priceController,
    required this.areaController,
    required this.selectedCity,
    required this.selectedState,
    required this.selectedColonia,
    required this.selectedPropertyType,
    required this.cities,
    required this.states,
    required this.colonias,
    required this.propertyTypes,
    required this.priceLabel,
    required this.priceHint,
    required this.onCityChanged,
    required this.onStateChanged,
    required this.onColoniaChanged,
    required this.onPropertyTypeChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 10, 32),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agregar Una Propiedad',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PropertyTypeToggle(
                    selected: listingType,
                    onChanged: onListingTypeChanged,
                  ),
                  const SizedBox(height: 20),
                  FormSectionHeader(
                    label: 'Ubicación',
                    iconData: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 10),
                  PropertyTextField(
                    controller: postalCodeController,
                    hint: 'Código postal',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: PropertyDropdownField<String>(
                          value: selectedCity,
                          hint: 'Ciudad',
                          items: cities
                              .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                              .toList(),
                          onChanged: onCityChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PropertyDropdownField<String>(
                          value: selectedState,
                          hint: 'Estado',
                          items: states
                              .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ))
                              .toList(),
                          onChanged: onStateChanged,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FormSectionHeader(
                    label: 'Colonia',
                    iconData: Icons.home_outlined,
                  ),
                  const SizedBox(height: 10),
                  PropertyDropdownField<String>(
                    value: selectedColonia,
                    hint: 'Elija la colonia',
                    items: colonias
                        .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ))
                        .toList(),
                    onChanged: onColoniaChanged,
                  ),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormSectionHeader(
                  label: 'Tipo De Propiedad',
                  iconData: Icons.home_outlined,
                ),
                const SizedBox(height: 10),
                PropertyDropdownField<String>(
                  value: selectedPropertyType,
                  hint: 'Pisos y departamentos',
                  items: propertyTypes
                      .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t),
                  ))
                      .toList(),
                  onChanged: onPropertyTypeChanged,
                ),
                const SizedBox(height: 20),
                FormSectionHeader(
                  label: priceLabel,
                  iconData: Icons.sell_outlined,
                ),
                const SizedBox(height: 10),
                PropertyTextField(
                  controller: priceController,
                  hint: priceHint,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 20),
                FormSectionHeader(
                  label: 'Area Del Terreno',
                  iconData: Icons.crop_square_outlined,
                ),
                const SizedBox(height: 10),
                PropertyTextField(
                  controller: areaController,
                  hint: 'Área en m2',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onNext,
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
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
      ],
    );
  }
}